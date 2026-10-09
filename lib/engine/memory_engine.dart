import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../theme/memory_themes.dart';

/// Rules for the physical Memory Match deck (RULES.md):
/// - 2 cards are flipped per turn; a match keeps them and grants another go.
/// - A miss flips both back after a visible pause; turn passes.
/// - Party: most pairs wins. Solo: fewest moves wins the personal best.
/// - Timed solo: beat the clock or the game is lost.
///
/// [Phase] is owned entirely by this engine. The UI only renders. Every
/// transient phase has an engine-owned timer, and the watchdog recovers any
/// phase found without a live timer — stuck states are impossible by
/// construction.
enum Phase {
  awaitingFirst, // first flip of a turn
  awaitingSecond, // one card up, waiting for the second
  checking, // two cards up; engine will settle match/miss shortly
  gameOver, // board finished or clock expired
}

enum BotDifficulty { easy, medium, hard }

enum PlayMode { soloRelaxed, soloTimed, party, vsBot }

class MemoryPlayer {
  String name;
  final bool isBot;
  int pairs = 0;
  MemoryPlayer({required this.name, required this.isBot});
}

/// Configuration for one engine run (a game session).
class MemoryConfig {
  final GridTier tier;
  final PlayMode mode;
  final List<MemoryPlayer> players;
  final BotDifficulty botDifficulty;
  final List<String> faces; // face ids (emoji) chosen for this deck
  final int timedSeconds; // only used in soloTimed
  final Random random;

  MemoryConfig({
    required this.tier,
    required this.mode,
    required this.players,
    required this.botDifficulty,
    required this.faces,
    this.timedSeconds = 180,
    Random? random,
  }) : random = random ?? Random();
}

class MemoryEngine extends ChangeNotifier {
  final MemoryConfig config;

  late List<String> deck; // face id per card index
  late List<bool> faceUp;
  late List<bool> matched;
  int firstPick = -1;
  int secondPick = -1;
  bool pendingMatch = false; // is the current [checking] pair a match?
  Phase phase = Phase.awaitingFirst;
  int turn = 0; // player index (party / vsBot)
  int moves = 0; // completed pair attempts (solo stats)
  int streak = 0; // consecutive matches by the current side
  int maxStreak = 0; // best streak this game (for stats)

  // Timed mode.
  int timeLeftMs = 0;
  bool urgent = false; // <= 10s left: UI ticks each second
  bool paused = false;

  // Events the UI observes for audio: 'flip', 'match', 'miss', 'win',
  // 'lose', 'tick', 'turn'. Consumed by the UI (set back to '').
  String lastEvent = '';

  Timer? _resolveTimer; // settles a checking phase
  Timer? _clockTimer; // timed-mode countdown
  Timer? _botTimer; // schedules bot actions
  Timer? _watchdog; // recovers stuck phases
  DateTime? _resolveDeadline; // for pause/resume bookkeeping
  int _resolveRemainingMs = 0;
  bool _disposed = false;

  bool get solo =>
      config.mode == PlayMode.soloRelaxed || config.mode == PlayMode.soloTimed;
  bool get timed => config.mode == PlayMode.soloTimed;
  int get pairCount => config.tier.pairs;
  int get cardCount => pairCount * 2;
  MemoryPlayer get activePlayer => config.players[turn];
  bool get isBotTurn => activePlayer.isBot;
  bool get inputLocked => phase == Phase.checking || phase == Phase.gameOver || paused;

  static const int _mismatchMs = 1100; // visible miss pause
  static const int _matchMs = 650; // match celebration beat
  static const int _botThinkMs = 750;

  MemoryEngine(this.config) {
    _buildDeck();
    if (timed) timeLeftMs = config.timedSeconds * 1000;
    _startWatchdog();
    if (timed) _startClock();
    _maybeBotAct();
  }

  void _buildDeck() {
    final need = pairCount;
    final pool = List<String>.of(config.faces);
    pool.shuffle(config.random);
    final chosen = pool.take(need).toList();
    deck = [...chosen, ...chosen]..shuffle(config.random);
    faceUp = List.filled(cardCount, false);
    matched = List.filled(cardCount, false);
  }

  // ------------------------------------------------------------ input
  /// Tap a card. Returns true if the tap was accepted; false when illegal
  /// (locked phase, already face-up/matched, bot's turn) — the UI plays the
  /// invalid sound for a rejected tap.
  bool tapCard(int index) {
    if (inputLocked || isBotTurn) return false;
    if (index < 0 || index >= cardCount) return false;
    if (matched[index] || faceUp[index]) return false;
    _flip(index);
    return true;
  }

  void _flip(int index) {
    if (phase == Phase.awaitingFirst) {
      firstPick = index;
      faceUp[index] = true;
      phase = Phase.awaitingSecond;
      _emit('flip');
      _botSees(index);
    } else if (phase == Phase.awaitingSecond) {
      if (index == firstPick) return; // tapping the same card: ignore quietly
      secondPick = index;
      faceUp[index] = true;
      moves++;
      phase = Phase.checking;
      pendingMatch = deck[firstPick] == deck[secondPick];
      _emit('flip');
      _botSees(index);
      final ms = pendingMatch ? _matchMs : _mismatchMs;
      _scheduleResolve(ms);
    }
    notifyListeners();
    // Bot acts through these same flips: chain its second pick immediately
    // instead of waiting for the watchdog.
    _maybeBotAct();
  }

  // ------------------------------------------------------------ resolution
  void _scheduleResolve(int ms) {
    _resolveTimer?.cancel();
    _resolveRemainingMs = ms;
    _resolveDeadline = DateTime.now().add(Duration(milliseconds: ms));
    _resolveTimer = Timer(Duration(milliseconds: ms), _settle);
  }

  void _settle() {
    if (_disposed || phase != Phase.checking) return;
    _resolveTimer = null;
    _resolveDeadline = null;
    final a = firstPick, b = secondPick;
    if (pendingMatch) {
      matched[a] = true;
      matched[b] = true;
      faceUp[a] = false; // matched cards stay visible via [matched]
      faceUp[b] = false;
      config.players[turn].pairs++;
      streak++;
      if (streak > maxStreak) maxStreak = streak;
      _emit('match');
      firstPick = -1;
      secondPick = -1;
      pendingMatch = false;
      if (_boardComplete) {
        _finish(won: true);
        return;
      }
      // Match grants another go: same player, back to awaitingFirst.
      phase = Phase.awaitingFirst;
    } else {
      faceUp[a] = false;
      faceUp[b] = false;
      streak = 0; // a miss breaks the streak
      _emit('miss');
      firstPick = -1;
      secondPick = -1;
      pendingMatch = false;
      if (!solo) {
        turn = (turn + 1) % config.players.length;
        _emit('turn');
      }
      phase = Phase.awaitingFirst;
    }
    notifyListeners();
    _maybeBotAct();
  }

  bool get _boardComplete => matched.every((m) => m);

  void _finish({required bool won}) {
    phase = Phase.gameOver;
    _resolveTimer?.cancel();
    _clockTimer?.cancel();
    _botTimer?.cancel();
    _emit(won ? 'win' : 'lose');
    notifyListeners();
  }

  // ------------------------------------------------------------ clock
  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_disposed || paused) return;
      timeLeftMs -= 250;
      final wasUrgent = urgent;
      urgent = timeLeftMs <= 10000 && timeLeftMs > 0;
      if (urgent && timeLeftMs ~/ 1000 != (timeLeftMs + 250) ~/ 1000) {
        _emit('tick');
      }
      if (timeLeftMs <= 0) {
        timeLeftMs = 0;
        _finish(won: _boardComplete);
      } else if (wasUrgent != urgent) {
        notifyListeners();
      }
    });
  }

  // ------------------------------------------------------------ pause/resume
  void pause() {
    if (paused || _disposed) return;
    paused = true;
    if (_resolveTimer != null && _resolveDeadline != null) {
      _resolveRemainingMs =
          _resolveDeadline!.difference(DateTime.now()).inMilliseconds;
      _resolveTimer!.cancel();
      _resolveTimer = null;
    }
    _botTimer?.cancel();
    _botTimer = null;
    notifyListeners();
  }

  void resume() {
    if (!paused || _disposed) return;
    paused = false;
    if (phase == Phase.checking && _resolveTimer == null) {
      _scheduleResolve(_resolveRemainingMs.clamp(120, _mismatchMs));
    }
    notifyListeners();
    _maybeBotAct();
  }

  // ------------------------------------------------------------ bot
  /// Bot memory: face id -> card indices it has seen (not yet matched).
  final Map<String, List<int>> _botMemory = {};

  void _botSees(int index) {
    if (matched[index]) return;
    final face = deck[index];
    final list = _botMemory.putIfAbsent(face, () => []);
    if (!list.contains(index)) list.add(index);
    if (config.botDifficulty == BotDifficulty.medium && list.length > 6) {
      // medium bot forgets: keeps a short working memory
      list.removeAt(0);
    }
  }

  void _forgetMatched() {
    final dead = <String>[];
    for (final e in _botMemory.entries) {
      e.value.removeWhere((i) => matched[i]);
      if (e.value.isEmpty) dead.add(e.key);
    }
    for (final k in dead) {
      _botMemory.remove(k);
    }
  }

  bool _botActs() => !_disposed && !paused && isBotTurn && !_boardComplete;

  void _maybeBotAct() {
    if (!_botActs()) return;
    if (phase != Phase.awaitingFirst && phase != Phase.awaitingSecond) return;
    _botTimer?.cancel();
    _botTimer = Timer(const Duration(milliseconds: _botThinkMs), () {
      if (!_botActs()) return;
      if (phase == Phase.awaitingFirst) {
        _flip(_botPickFirst());
      } else if (phase == Phase.awaitingSecond) {
        _flip(_botPickSecond());
      }
    });
  }

  int _hiddenRandom(Set<int> exclude) {
    final hidden = <int>[];
    for (int i = 0; i < cardCount; i++) {
      if (!matched[i] && !faceUp[i] && !exclude.contains(i)) hidden.add(i);
    }
    if (hidden.isEmpty) {
      for (int i = 0; i < cardCount; i++) {
        if (!matched[i] && !faceUp[i]) hidden.add(i);
      }
    }
    return hidden[config.random.nextInt(hidden.length)];
  }

  int _botPickFirst() {
    final d = config.botDifficulty;
    _forgetMatched();
    if (d == BotDifficulty.easy) return _hiddenRandom({});
    // medium/hard: if we know a full pair, take one of its cards.
    for (final e in _botMemory.entries) {
      final live = e.value.where((i) => !matched[i] && !faceUp[i]).toList();
      if (live.length >= 2) return live.first;
    }
    return _hiddenRandom({});
  }

  int _botPickSecond() {
    final d = config.botDifficulty;
    final want = deck[firstPick];
    if (d == BotDifficulty.hard) {
      final known = (_botMemory[want] ?? [])
          .where((i) => i != firstPick && !matched[i] && !faceUp[i])
          .toList();
      if (known.isNotEmpty) return known.first;
      return _hiddenRandom({firstPick});
    }
    if (d == BotDifficulty.medium) {
      // medium knows its short memory but slips sometimes
      if (config.random.nextDouble() < 0.55) {
        final known = (_botMemory[want] ?? [])
            .where((i) => i != firstPick && !matched[i] && !faceUp[i])
            .toList();
        if (known.isNotEmpty) return known.first;
      }
      return _hiddenRandom({firstPick});
    }
    return _hiddenRandom({firstPick});
  }

  // ------------------------------------------------------------ watchdog
  /// Runs every second: any phase found without its expected live timer gets
  /// repaired, so the game can never freeze.
  void _startWatchdog() {
    _watchdog = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || paused) return;
      if (phase == Phase.checking && _resolveTimer == null) {
        // Resolution timer died — settle immediately instead of hanging.
        _settle();
      } else if ((phase == Phase.awaitingFirst ||
              phase == Phase.awaitingSecond) &&
          isBotTurn &&
          _botTimer == null) {
        // Bot timer died — nudge the bot to act.
        _maybeBotAct();
      } else if (timed &&
          phase != Phase.gameOver &&
          (_clockTimer == null || !_clockTimer!.isActive)) {
        // Clock died — restart it.
        _startClock();
      }
    });
  }

  void _emit(String e) => lastEvent = e;

  /// Time used (seconds) in a timed win — for stats.
  int get usedSeconds => timed
      ? config.timedSeconds - (timeLeftMs ~/ 1000)
      : 0;

  /// Party winner: player with most pairs (ties = shared win).
  List<MemoryPlayer> get winners {
    if (solo) return [config.players.first];
    var best = 0;
    for (final p in config.players) {
      if (p.pairs > best) best = p.pairs;
    }
    return [for (final p in config.players) if (p.pairs == best) p];
  }

  @override
  void dispose() {
    _disposed = true;
    _resolveTimer?.cancel();
    _clockTimer?.cancel();
    _botTimer?.cancel();
    _watchdog?.cancel();
    super.dispose();
  }
}
