import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../engine/memory_engine.dart';
import '../theme/memory_themes.dart';

/// Persisted settings + stats for Memory Match. Survives app restarts.
///
/// Stores: audio toggles, player profile (4 renameable slots as ONE JSON
/// string — Android stores StringLists as unordered StringSets, so StringList
/// is never used for ordered data), theme/card-style choices (incl. custom
/// theme colors + custom face set as JSON), mode setup, Pro state, stats.
class MatchSettings extends ChangeNotifier {
  static const _kMusic = 'mm_music_on';
  static const _kSfx = 'mm_sfx_on';
  static const _kVolume = 'mm_volume';
  static const _kNames = 'mm_player_names'; // legacy unordered StringSet key
  static const _kNamesJsonLegacy =
      'mm_player_names_json'; // pre-release JSON key
  /// Order-safe player-name storage: a single JSON string. Never setStringList.
  static const _kNamesJson = 'memorymatch_player_names_json';
  static const _kTheme = 'mm_theme_id';
  static const _kCardStyle = 'mm_card_style_id';
  static const _kCardBack = 'mm_cardback_id';
  static const _kGridTier = 'mm_grid_tier';
  static const _kMode = 'mm_play_mode'; // 0 soloRelaxed,1 soloTimed,2 party,3 vsBot
  static const _kPlayerCount = 'mm_player_count';
  static const _kBotDifficulty = 'mm_bot_difficulty'; // 0 easy,1 medium,2 hard
  static const _kWins = 'mm_wins';
  static const _kGames = 'mm_games_played';
  static const _kBestMoves = 'mm_best_moves'; // fewest moves to clear (0 none)
  static const _kBestTime = 'mm_best_time'; // fastest timed clear, secs (0 none)
  static const _kBestStreak = 'mm_best_streak'; // best match streak (0 none)
  static const _kIsPro = 'mm_is_pro';
  static const _kReviewPrompted = 'mm_review_prompted_games';
  static const _kCustomPrefix = 'mm_custom_';
  /// Custom face set: ONE JSON string of emoji (order preserved).
  static const _kCustomFaces = 'mm_custom_faces_json';

  static const defaultNames = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];

  static String encodePlayerNames(List<String> names) => jsonEncode(names);

  static String _cleanName(int i, Object? v) {
    final s = v is String ? v.trim() : '';
    return s.isEmpty ? defaultNames[i] : s;
  }

  /// Decode persisted names; falls back to defaults on missing/corrupt data.
  static List<String> decodePlayerNames(String? raw) {
    if (raw == null) return List.of(defaultNames);
    try {
      final d = jsonDecode(raw);
      if (d is List && d.length == 4) {
        return [for (int i = 0; i < 4; i++) _cleanName(i, d[i])];
      }
    } catch (_) {}
    return List.of(defaultNames);
  }

  static List<String> decodeFaces(String? raw) {
    if (raw == null) return const [];
    try {
      final d = jsonDecode(raw);
      if (d is List) {
        return [for (final e in d) if (e is String && e.isNotEmpty) e]
            .toSet()
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  bool musicOn = true;
  bool sfxOn = true;
  double volume = 0.8;
  List<String> playerNames = List.of(defaultNames);
  String themeId = 'walnut';
  String cardStyleId = 'forest';
  String cardBackId = 'diamond';
  String gridTier = 'classic';
  int playMode = 0; // 0 soloRelaxed, 1 soloTimed, 2 party, 3 vsBot
  int playerCount = 2; // party size
  int botDifficulty = 1; // medium default
  int wins = 0;
  int gamesPlayed = 0;
  int bestMoves = 0;
  int bestTime = 0;
  int bestStreak = 0;
  bool isPro = false;
  int reviewPromptedGames = 0;

  Map<String, int> customColors = Map.of(_defaultCustomColors);
  List<String> customFaces = [];

  static const Map<String, int> _defaultCustomColors = {
    'felt': 0xFF2E4A3A,
    'woodEdge': 0xFF3B2416,
    'cardBack': 0xFF7A2230,
    'cardBackTrim': 0xFFC9A227,
    'cardBackPattern': 0xFFA63A4A,
    'cardFace': 0xFFF7F1E2,
    'cardFaceBorder': 0xFFC9A227,
    'ink': 0xFF2E2118,
    'accent': 0xFFC9A227,
    'accentDark': 0xFF8A6D1A,
    'pc0': 0xFFA31621,
    'pc1': 0xFF1D4E9E,
    'pc2': 0xFF1B7A4D,
    'pc3': 0xFFD99A2B,
  };

  MemoryThemeDef get customTheme {
    Color c(String k) => Color(customColors[k] ?? 0xFF000000);
    return MemoryThemeDef(
      id: 'custom',
      name: 'My Creation',
      felt: c('felt'),
      woodEdge: c('woodEdge'),
      cardBack: c('cardBack'),
      cardBackTrim: c('cardBackTrim'),
      cardBackPattern: c('cardBackPattern'),
      cardFace: c('cardFace'),
      cardFaceBorder: c('cardFaceBorder'),
      ink: c('ink'),
      accent: c('accent'),
      accentDark: c('accentDark'),
      playerColors: [c('pc0'), c('pc1'), c('pc2'), c('pc3')],
      playerColorNames: const ['One', 'Two', 'Three', 'Four'],
    );
  }

  /// Faces used for the current game (custom set if selected and valid).
  List<String> get activeFaces {
    if (cardStyleId == 'custom' && customFaces.isNotEmpty) {
      return customFaces;
    }
    return CardFaceStyles.byId(cardStyleId).faces;
  }

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    musicOn = p.getBool(_kMusic) ?? true;
    sfxOn = p.getBool(_kSfx) ?? true;
    volume = p.getDouble(_kVolume) ?? 0.8;
    final namesRaw = p.getString(_kNamesJson) ??
        p.getString(_kNamesJsonLegacy); // pre-release key migration
    if (namesRaw != null) {
      playerNames = decodePlayerNames(namesRaw);
    } else {
      final legacy = p.getStringList(_kNames);
      playerNames = (legacy != null && legacy.length == 4)
          ? [for (int i = 0; i < 4; i++) _cleanName(i, legacy[i])]
          : List.of(defaultNames);
    }
    themeId = p.getString(_kTheme) ?? 'walnut';
    cardStyleId = p.getString(_kCardStyle) ?? 'forest';
    cardBackId = p.getString(_kCardBack) ?? 'diamond';
    if (!CardBackPatterns.exists(cardBackId)) cardBackId = 'diamond';
    gridTier = p.getString(_kGridTier) ?? 'classic';
    playMode = (p.getInt(_kMode) ?? 0).clamp(0, 3);
    playerCount = (p.getInt(_kPlayerCount) ?? 2).clamp(2, 4);
    botDifficulty = (p.getInt(_kBotDifficulty) ?? 1).clamp(0, 2);
    wins = p.getInt(_kWins) ?? 0;
    gamesPlayed = p.getInt(_kGames) ?? 0;
    bestMoves = p.getInt(_kBestMoves) ?? 0;
    bestTime = p.getInt(_kBestTime) ?? 0;
    bestStreak = p.getInt(_kBestStreak) ?? 0;
    isPro = p.getBool(_kIsPro) ?? false;
    reviewPromptedGames = p.getInt(_kReviewPrompted) ?? 0;
    for (final k in _defaultCustomColors.keys) {
      customColors[k] = p.getInt('$_kCustomPrefix$k') ?? _defaultCustomColors[k]!;
    }
    customFaces = decodeFaces(p.getString(_kCustomFaces));
    _enforceFreeLimits(silent: true);
    notifyListeners();
  }

  Future<void> _save() async {
    final p = _prefs;
    if (p == null) return;
    await p.setBool(_kMusic, musicOn);
    await p.setBool(_kSfx, sfxOn);
    await p.setDouble(_kVolume, volume);
    await p.setString(_kNamesJson, encodePlayerNames(playerNames));
    await p.remove(_kNames);
    await p.remove(_kNamesJsonLegacy);
    await p.setString(_kTheme, themeId);
    await p.setString(_kCardStyle, cardStyleId);
    await p.setString(_kCardBack, cardBackId);
    await p.setString(_kGridTier, gridTier);
    await p.setInt(_kMode, playMode);
    await p.setInt(_kPlayerCount, playerCount);
    await p.setInt(_kBotDifficulty, botDifficulty);
    await p.setInt(_kWins, wins);
    await p.setInt(_kGames, gamesPlayed);
    await p.setInt(_kBestMoves, bestMoves);
    await p.setInt(_kBestTime, bestTime);
    await p.setInt(_kBestStreak, bestStreak);
    await p.setBool(_kIsPro, isPro);
    await p.setInt(_kReviewPrompted, reviewPromptedGames);
    await p.setString(_kCustomFaces, jsonEncode(customFaces));
    for (final e in customColors.entries) {
      await p.setInt('$_kCustomPrefix${e.key}', e.value);
    }
  }

  /// Free-tier limits: clamp pro-only choices when not Pro.
  void _enforceFreeLimits({bool silent = false}) {
    if (isPro) return;
    var changed = false;
    if (themeId == 'custom' || MemoryThemes.isProTheme(themeId)) {
      themeId = 'walnut';
      changed = true;
    }
    if (cardStyleId == 'custom' || CardFaceStyles.isProStyle(cardStyleId)) {
      cardStyleId = 'forest';
      changed = true;
    }
    if (CardBackPatterns.isProPattern(cardBackId)) {
      cardBackId = 'diamond';
      changed = true;
    }
    if (GridTier.isProTier(gridTier)) {
      gridTier = 'classic';
      changed = true;
    }
    if (botDifficulty > 1) {
      botDifficulty = 1;
      changed = true;
    }
    if (changed && !silent) {
      notifyListeners();
      _save();
    }
  }

  Future<void> setPro(bool v) async {
    isPro = v;
    if (!v) _enforceFreeLimits();
    notifyListeners();
    await _save();
  }

  Future<void> setCustomColor(String key, int argb) async {
    if (!isPro) return;
    if (!_defaultCustomColors.containsKey(key)) return;
    customColors[key] = argb;
    notifyListeners();
    await _save();
  }

  Future<void> resetCustomColors() async {
    customColors = Map.of(_defaultCustomColors);
    notifyListeners();
    await _save();
  }

  /// Custom face set (PRO): exactly [count] unique faces from the master pool.
  Future<void> setCustomFaces(List<String> faces) async {
    if (!isPro) return;
    final clean = faces.toSet().where((f) => f.isNotEmpty).toList();
    if (clean.isEmpty) return;
    customFaces = clean;
    notifyListeners();
    await _save();
  }

  Future<void> setMusic(bool v) async {
    musicOn = v;
    notifyListeners();
    await _save();
  }

  Future<void> setSfx(bool v) async {
    sfxOn = v;
    notifyListeners();
    await _save();
  }

  Future<void> setVolume(double v) async {
    volume = v.clamp(0.0, 1.0);
    notifyListeners();
    await _save();
  }

  Future<void> setPlayerName(int index, String name) async {
    if (index < 0 || index > 3) return;
    final clean = name.trim();
    playerNames[index] = clean.isEmpty ? defaultNames[index] : clean;
    notifyListeners();
    await _save();
  }

  Future<void> setTheme(String id) async {
    if (!isPro && (id == 'custom' || MemoryThemes.isProTheme(id))) return;
    themeId = id;
    notifyListeners();
    await _save();
  }

  Future<void> setCardStyle(String id) async {
    if (!isPro && (id == 'custom' || CardFaceStyles.isProStyle(id))) return;
    cardStyleId = id;
    notifyListeners();
    await _save();
  }

  Future<void> setCardBack(String id) async {
    if (!CardBackPatterns.exists(id)) return;
    if (!isPro && CardBackPatterns.isProPattern(id)) return;
    cardBackId = id;
    notifyListeners();
    await _save();
  }

  /// Record a match streak; keeps the all-time best.
  Future<void> recordStreak(int streak) async {
    if (streak > bestStreak) {
      bestStreak = streak;
      notifyListeners();
      await _save();
    }
  }

  Future<void> setGridTier(String id) async {
    if (!isPro && GridTier.isProTier(id)) return;
    gridTier = id;
    notifyListeners();
    await _save();
  }

  Future<void> setMode(int mode) async {
    playMode = mode.clamp(0, 3);
    notifyListeners();
    await _save();
  }

  Future<void> setPlayerCount(int n) async {
    playerCount = n.clamp(2, 4);
    notifyListeners();
    await _save();
  }

  Future<void> setBotDifficulty(int d) async {
    d = d.clamp(0, 2);
    if (!isPro && d > 1) return;
    botDifficulty = d;
    notifyListeners();
    await _save();
  }

  Future<void> markReviewPrompted() async {
    reviewPromptedGames = gamesPlayed;
    await _save();
  }

  /// Record a finished game.
  /// [won]: solo win or (party) a human won. [moves]/[secs] feed bests.
  Future<void> recordGame(
      {required bool won, int moves = 0, int secs = 0}) async {
    gamesPlayed++;
    if (won) {
      wins++;
      if (moves > 0 && (bestMoves == 0 || moves < bestMoves)) {
        bestMoves = moves;
      }
      if (secs > 0 && (bestTime == 0 || secs < bestTime)) bestTime = secs;
    }
    notifyListeners();
    await _save();
  }

  PlayMode get modeEnum => PlayMode.values[playMode];

  /// Timed-mode clock length per grid tier (seconds).
  static int timedSecondsFor(String tierId) {
    switch (tierId) {
      case 'easy':
        return 120;
      case 'classic':
        return 180;
      case 'hard':
        return 300;
      default:
        return 420;
    }
  }
}
