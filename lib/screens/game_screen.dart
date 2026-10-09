import 'dart:math';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import '../engine/memory_engine.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/match_bits.dart';
import '../theme/memory_themes.dart';

/// The card table. Renders [MemoryEngine] state — the engine owns all phases
/// and timers; this screen only animates and plays sounds for its events.
class GameScreen extends StatefulWidget {
  final MatchAudio audio;
  final MatchSettings settings;
  final MemoryConfig config;
  const GameScreen(
      {super.key,
      required this.audio,
      required this.settings,
      required this.config});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final MemoryEngine engine;
  bool _recorded = false;

  MatchSettings get s => widget.settings;
  MatchAudio get a => widget.audio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    engine = MemoryEngine(widget.config);
    engine.addListener(_onEngine);
    a.startGameMusic();
    a.gameStart();
  }

  MemoryThemeDef get _t => MemoryThemes.byId(
        s.themeId,
        custom: s.customTheme,
      );

  void _onEngine() {
    final e = engine.lastEvent;
    if (e.isNotEmpty) {
      engine.lastEvent = '';
      switch (e) {
        case 'flip':
          a.flip();
          break;
        case 'match':
          a.match();
          break;
        case 'miss':
          a.miss();
          Future.delayed(
              const Duration(milliseconds: 350), () => a.layDown());
          break;
        case 'win':
          _onGameOver(true);
          break;
        case 'lose':
          _onGameOver(false);
          break;
        case 'tick':
          a.tick();
          break;
        case 'turn':
          a.click();
          break;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _onGameOver(bool won) async {
    a.stopMusic();
    if (won) {
      a.win();
    } else {
      a.lose();
    }
    if (_recorded) return;
    _recorded = true;
    final statsWin = won &&
        (engine.solo || engine.winners.any((p) => !p.isBot));
    await s.recordGame(
      won: statsWin,
      moves: engine.solo && won ? engine.moves : 0,
      secs: engine.timed && won ? engine.usedSeconds : 0,
    );
    await s.recordStreak(engine.maxStreak);
    // in_app_review at a sensible moment: every 3rd finished game, win or
    // lose, and never twice within 3 games. Graceful when not from Play.
    if (s.gamesPlayed - s.reviewPromptedGames >= 3) {
      await s.markReviewPrompted();
      try {
        if (await InAppReview.instance.isAvailable()) {
          await InAppReview.instance.requestReview();
        }
      } catch (_) {}
    }
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) _showResult(won);
    }
  }

  void _showResult(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        engine: engine,
        settings: s,
        audio: a,
        theme: _t,
        won: won,
        onReplay: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => GameScreen(
                  audio: a, settings: s, config: _freshConfig()),
            ),
          );
        },
        onMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  MemoryConfig _freshConfig() {
    final c = widget.config;
    final names = s.playerNames;
    final players = <MemoryPlayer>[];
    if (c.mode == PlayMode.party) {
      for (int i = 0; i < s.playerCount; i++) {
        players.add(MemoryPlayer(name: names[i], isBot: false));
      }
    } else if (c.mode == PlayMode.vsBot) {
      players.add(MemoryPlayer(name: names[0], isBot: false));
      players.add(MemoryPlayer(name: names[1], isBot: true));
    } else {
      players.add(MemoryPlayer(name: names[0], isBot: false));
    }
    return MemoryConfig(
      tier: c.tier,
      mode: c.mode,
      players: players,
      botDifficulty: BotDifficulty.values[s.botDifficulty],
      faces: s.activeFaces,
      timedSeconds: MatchSettings.timedSecondsFor(c.tier.id),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Freeze the engine when the app backgrounds so timers and the clock
    // never run while the player is away.
    if (state == AppLifecycleState.paused) {
      engine.pause();
    } else if (state == AppLifecycleState.resumed) {
      engine.resume();
    }
  }

  void _pauseMenu() {
    a.click();
    engine.pause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PauseDialog(
        theme: _t,
        onResume: () {
          Navigator.of(context).pop();
          engine.resume();
        },
        onRestart: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => GameScreen(
                  audio: a, settings: s, config: _freshConfig()),
            ),
          );
        },
        onQuit: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    engine.removeListener(_onEngine);
    engine.dispose();
    a.startMenuMusic();
    super.dispose();
  }

  String _clockText() {
    final sTotal = (engine.timeLeftMs / 1000).ceil();
    final m = sTotal ~/ 60;
    final sec = sTotal % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final tier = engine.config.tier;
    return Scaffold(
      body: TableBackdrop(
        theme: t,
        child: SafeArea(
          child: Column(
            children: [
              _hud(t),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      final w = constraints.maxWidth / tier.cols;
                      final fontSize = (w * 0.42).clamp(22.0, 44.0);
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: tier.cols,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.74,
                        ),
                        itemCount: engine.cardCount,
                        itemBuilder: (_, i) => _CardTile(
                          key: ValueKey('card_$i'),
                          face: engine.deck[i],
                          faceUp: engine.faceUp[i] || engine.matched[i],
                          matched: engine.matched[i],
                          checking: engine.phase == Phase.checking &&
                              (i == engine.firstPick ||
                                  i == engine.secondPick),
                          pendingMatch: engine.pendingMatch,
                          theme: t,
                          backPattern: s.cardBackId,
                          fontSize: fontSize,
                          onTap: () {
                            // During the bot's turn taps are simply ignored —
                            // the buzzing "invalid" sound is for real mistakes.
                            if (engine.isBotTurn) return;
                            final ok = engine.tapCard(i);
                            if (!ok) a.invalid();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              _turnBanner(t),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hud(MemoryThemeDef t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pauseMenu,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: t.accent.withValues(alpha: 0.6)),
              ),
              child: Icon(Icons.pause_rounded, color: t.accent, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          if (engine.solo) ...[
            _hudChip(t, Icons.touch_app_rounded, '${engine.moves} moves'),
            if (engine.streak >= 2)
              _hudChip(t, Icons.local_fire_department_rounded,
                  'x${engine.streak} streak'),
            if (s.bestMoves > 0)
              _hudChip(t, Icons.emoji_events_rounded, 'best ${s.bestMoves}'),
          ] else ...[
            for (int i = 0; i < engine.config.players.length; i++)
              _scoreChip(t, engine.config.players[i], i),
          ],
          const Spacer(),
          if (engine.timed)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: engine.urgent
                    ? const Color(0xFFA31621)
                    : Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: engine.urgent ? t.cardFace : t.accent),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_rounded,
                      size: 16,
                      color: engine.urgent ? t.cardFace : t.accent),
                  const SizedBox(width: 5),
                  Text(_clockText(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: engine.urgent ? t.cardFace : t.accent)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _hudChip(MemoryThemeDef t, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: t.accent),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: t.cardFace)),
        ],
      ),
    );
  }

  Widget _scoreChip(MemoryThemeDef t, MemoryPlayer p, int i) {
    final active =
        engine.turn == i && engine.phase != Phase.gameOver;
    final color = t.playerColors[i % t.playerColors.length];
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.85)
            : Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: active ? t.cardFace : color.withValues(alpha: 0.6),
            width: active ? 2 : 1.2),
      ),
      child: Row(
        children: [
          if (p.isBot)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.smart_toy_rounded,
                  size: 14, color: Colors.white),
            ),
          Text('${p.name}: ${p.pairs}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : t.cardFace)),
        ],
      ),
    );
  }

  Widget _turnBanner(MemoryThemeDef t) {
    if (engine.solo || engine.phase == Phase.gameOver) {
      final left = engine.pairCount -
          engine.matched.where((m) => m).length ~/ 2;
      return Text('$left pairs left — find them all!',
          style: Match.body(13,
              theme: t, color: t.cardFace.withValues(alpha: 0.8)));
    }
    final p = engine.activePlayer;
    final text = p.isBot
        ? '${p.name} is peeking… 🤖'
        : '${p.name}, pick two cards! 🃏';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        text,
        key: ValueKey('${engine.turn}_${engine.phase}'),
        style: Match.body(15, theme: t, color: t.accent),
      ),
    );
  }
}

/// A physical playing card with a real 3D-ish flip animation.
/// Never pops: every flip tweens through the edge-on pose.
class _CardTile extends StatefulWidget {
  final String face;
  final bool faceUp;
  final bool matched;
  final bool checking;
  final bool pendingMatch;
  final MemoryThemeDef theme;
  final String backPattern;
  final double fontSize;
  final VoidCallback onTap;

  const _CardTile({
    super.key,
    required this.face,
    required this.faceUp,
    required this.matched,
    required this.checking,
    required this.pendingMatch,
    required this.theme,
    required this.backPattern,
    required this.fontSize,
    required this.onTap,
  });

  @override
  State<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<_CardTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;
  late final AnimationController _pop;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    if (widget.faceUp) _flip.value = 1;
    if (widget.matched) _pop.value = 1;
  }

  @override
  void didUpdateWidget(covariant _CardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.faceUp != oldWidget.faceUp) {
      if (widget.faceUp) {
        _flip.forward();
      } else {
        _flip.reverse();
      }
    }
    if (widget.matched && !oldWidget.matched) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flip, _pop]),
        builder: (_, _) {
          final v = _flip.value;
          final showingFace = v > 0.5;
          final angle = (1 - v) * 3.14159;
          final popScale = 1 + 0.18 * sin(_pop.value * pi);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018) // perspective: real card weight
              ..rotateY(angle)
              ..scale(popScale),
            child: showingFace ? _faceSide(t) : _backSide(t),
          );
        },
      ),
    );
  }

  Widget _backSide(MemoryThemeDef t) =>
      CardBackFace(theme: t, pattern: widget.backPattern);

  Widget _faceSide(MemoryThemeDef t) {
    final glow = widget.checking && widget.pendingMatch;
    final dim = widget.matched;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dim
              ? [
                  t.accent.withValues(alpha: 0.75),
                  t.accentDark.withValues(alpha: 0.75)
                ]
              : [t.cardFace, t.cardFace.withValues(alpha: 0.94)],
        ),
        border: Border.all(
            color: glow ? t.accent : t.cardFaceBorder,
            width: glow ? 3.5 : 2),
        boxShadow: [
          BoxShadow(
            color: glow
                ? t.accent.withValues(alpha: 0.8)
                : Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 4),
            blurRadius: glow ? 14 : 6,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.face,
          style: TextStyle(fontSize: widget.fontSize),
        ),
      ),
    );
  }
}

class _PauseDialog extends StatelessWidget {
  final MemoryThemeDef theme;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;
  const _PauseDialog(
      {required this.theme,
      required this.onResume,
      required this.onRestart,
      required this.onQuit});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Dialog(
      backgroundColor: t.woodEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: t.accent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Paused', style: Match.display(30, theme: t)),
            const SizedBox(height: 8),
            Text('Take a breath. The cards will wait.',
                style: Match.body(14, theme: t)),
            const SizedBox(height: 20),
            WoodButton(label: 'RESUME', onTap: onResume, theme: t),
            const SizedBox(height: 10),
            WoodButton(label: 'RESTART', onTap: onRestart, theme: t),
            const SizedBox(height: 10),
            WoodButton(label: 'LEAVE TABLE', onTap: onQuit, theme: t),
          ],
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final MemoryEngine engine;
  final MatchSettings settings;
  final MatchAudio audio;
  final MemoryThemeDef theme;
  final bool won;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  const _ResultDialog({
    required this.engine,
    required this.settings,
    required this.audio,
    required this.theme,
    required this.won,
    required this.onReplay,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final headline = engine.solo
        ? (won ? 'Table cleared! 🎉' : 'Out of time! ⏰')
        : _partyHeadline();
    final sub = _subline();
    return Dialog(
      backgroundColor: t.woodEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: t.accent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won ? '🏆' : '🃏', style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            Text(headline,
                style: Match.display(28, theme: t),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(sub,
                style: Match.body(15, theme: t),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            WoodButton(
                label: 'PLAY AGAIN',
                onTap: () {
                  audio.click();
                  onReplay();
                },
                theme: t),
            const SizedBox(height: 10),
            WoodButton(
                label: 'BACK TO MENU',
                onTap: () {
                  audio.click();
                  onMenu();
                },
                theme: t),
          ],
        ),
      ),
    );
  }

  String _partyHeadline() {
    final ws = engine.winners;
    if (ws.length > 1) {
      return 'It\'s a tie! 🤝';
    }
    return '${ws.first.name} wins! 🏆';
  }

  String _subline() {
    if (engine.solo) {
      final streakBit = settings.bestStreak > 0
          ? ' Best streak: ${settings.bestStreak}.'
          : '';
      if (engine.timed) {
        return won
            ? 'Cleared in ${engine.usedSeconds}s with ${engine.moves} moves.$streakBit'
            : 'You found ${engine.config.players.first.pairs} of ${engine.pairCount} pairs. Try a smaller table or go again!';
      }
      final best = settings.bestMoves;
      return 'Finished in ${engine.moves} moves.'
          '${best > 0 ? ' Personal best: $best.' : ''}$streakBit';
    }
    final rows = engine.config.players
        .map((p) => '${p.name}: ${p.pairs} pair${p.pairs == 1 ? '' : 's'}')
        .join(' · ');
    return rows;
  }
}
