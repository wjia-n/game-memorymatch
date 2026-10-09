import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../engine/memory_engine.dart';
import '../services/audio_service.dart';
import '../services/iap_service.dart';
import '../services/settings_service.dart';
import '../theme/match_bits.dart';
import '../theme/memory_themes.dart';
import 'game_screen.dart';
import 'pro_screen.dart';
import 'settings_screen.dart';

/// Main menu: deal the cards. Mode setup + pickers + stats + share.
class MenuScreen extends StatefulWidget {
  final MatchAudio audio;
  final MatchSettings settings;
  final StoreService store;
  const MenuScreen(
      {super.key, required this.audio, required this.settings, required this.store});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

const _storeUrl =
    'https://play.google.com/store/apps/details?id=com.gameswajiha.memorymatch';

class _MenuScreenState extends State<MenuScreen> {
  MatchSettings get s => widget.settings;
  MatchAudio get a => widget.audio;

  @override
  void initState() {
    super.initState();
    a.startMenuMusic();
  }

  MemoryThemeDef get _t => MemoryThemes.byId(
        s.themeId,
        custom: s.customTheme,
      );

  Future<void> _share() async {
    a.click();
    try {
      await Share.share(
        'Memory Match by WAJIHA — flip cards, find every pair! $_storeUrl',
        subject: 'Memory Match',
      );
    } catch (_) {}
  }

  void _startGame() {
    a.click();
    a.gameStart();
    final tier = GridTier.byId(s.gridTier);
    final mode = s.modeEnum;
    final names = s.playerNames;
    final players = <MemoryPlayer>[];
    if (mode == PlayMode.party) {
      for (int i = 0; i < s.playerCount; i++) {
        players.add(MemoryPlayer(name: names[i], isBot: false));
      }
    } else if (mode == PlayMode.vsBot) {
      players.add(MemoryPlayer(name: names[0], isBot: false));
      // The bot takes the second renameable slot — editable in Settings.
      players.add(MemoryPlayer(name: names[1], isBot: true));
    } else {
      players.add(MemoryPlayer(name: names[0], isBot: false));
    }
    final faces = s.activeFaces;
    if (faces.length < tier.pairs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Your custom face set needs at least ${tier.pairs} faces for this grid.',
                style: Match.body(14, theme: _t))),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          audio: a,
          settings: s,
          config: MemoryConfig(
            tier: tier,
            mode: mode,
            players: players,
            botDifficulty: BotDifficulty.values[s.botDifficulty],
            faces: faces,
            timedSeconds: MatchSettings.timedSecondsFor(tier.id),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild on every settings change so pickers, locks and the PRO badge
    // always reflect the current state.
    return Scaffold(
      body: ListenableBuilder(
        listenable: s,
        builder: (_, _) {
          final t = _t;
          return TableBackdrop(
            theme: t,
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        a.click();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(
                                audio: a, settings: s, store: widget.store),
                          ),
                        );
                      },
                      child: _iconBtn(t, Icons.settings_rounded),
                    ),
                    if (!s.isPro)
                      GestureDetector(
                        onTap: () {
                          a.click();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProScreen(audio: a, settings: s, store: widget.store),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: t.accent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: t.cardFace.withValues(alpha: 0.4)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  offset: const Offset(0, 3),
                                  blurRadius: 6)
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  size: 16, color: Color(0xFF3B2416)),
                              const SizedBox(width: 6),
                              Text('GO PRO',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: t.woodEdge,
                                      fontSize: 13,
                                      letterSpacing: 1)),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: t.accent),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_rounded,
                                size: 16, color: t.accent),
                            const SizedBox(width: 6),
                            Text('PRO',
                                style: Match.label(13, theme: t)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: t.accent, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          offset: const Offset(0, 8),
                          blurRadius: 18)
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/memorymatch_logo.png',
                      fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Text('Memory Match', style: Match.display(38, theme: t)),
                Text('THE CARD TABLE EDITION',
                    style: Match.label(12, theme: t)),
                const SizedBox(height: 18),
                _modePicker(t),
                const SizedBox(height: 12),
                _tierPicker(t),
                const SizedBox(height: 12),
                if (s.playMode == 3) ...[
                  _botDifficultyPicker(t),
                  const SizedBox(height: 12),
                ],
                if (s.playMode == 2) ...[
                  _playerCountPicker(t),
                  const SizedBox(height: 12),
                ],
                _themePicker(t),
                const SizedBox(height: 12),
                _facePicker(t),
                const SizedBox(height: 12),
                _cardBackPicker(t),
                const SizedBox(height: 16),
                WoodButton(
                    label: 'DEAL THE CARDS',
                    onTap: _startGame,
                    theme: t,
                    icon: Icons.style_rounded,
                    fontSize: 19),
                const SizedBox(height: 14),
                _statsBar(t),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _share,
                  icon: Icon(Icons.share_rounded,
                      color: t.accent, size: 18),
                  label: Text('Tell a friend',
                      style: Match.body(14, theme: t, color: t.accent)),
                ),
                const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _iconBtn(MemoryThemeDef t, IconData icon) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.accent.withValues(alpha: 0.6)),
        ),
        child: Icon(icon, color: t.accent, size: 22),
      );

  Widget _section(MemoryThemeDef t, String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: t.accent.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: Match.label(12, theme: t)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _modePicker(MemoryThemeDef t) {
    const modes = ['Solo · Relaxed', 'Solo · Timed', 'Party · Pass & Play', 'You vs Bot'];
    const icons = [
      Icons.spa_rounded,
      Icons.timer_rounded,
      Icons.groups_rounded,
      Icons.smart_toy_rounded
    ];
    return _section(
      t,
      'Game mode',
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 2.6, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: 4,
        itemBuilder: (_, i) {
          final sel = s.playMode == i;
          return GestureDetector(
            onTap: () {
              a.click();
              s.setMode(i);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: sel
                    ? t.accent
                    : Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                    color: sel
                        ? t.cardFace
                        : t.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[i],
                      size: 18,
                      color: sel ? t.woodEdge : t.cardFace),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(modes[i],
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: sel ? t.woodEdge : t.cardFace)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tierPicker(MemoryThemeDef t) {
    return _section(
      t,
      'Table size',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final tier in GridTier.all)
            _chip(t, tier.name, s.gridTier == tier.id,
                GridTier.isProTier(tier.id),
                () => s.setGridTier(tier.id)),
        ],
      ),
    );
  }

  Widget _botDifficultyPicker(MemoryThemeDef t) {
    const names = ['Easy', 'Medium', 'Hard'];
    return _section(
      t,
      'Bot skill',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (int i = 0; i < 3; i++)
            _chip(t, names[i], s.botDifficulty == i, i == 2,
                () => s.setBotDifficulty(i)),
        ],
      ),
    );
  }

  Widget _playerCountPicker(MemoryThemeDef t) {
    return _section(
      t,
      'Players',
      Row(
        children: [
          for (int n = 2; n <= 4; n++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    a.click();
                    s.setPlayerCount(n);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: s.playerCount == n
                          ? t.accent
                          : Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                          color: s.playerCount == n
                              ? t.cardFace
                              : t.accent.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text('$n',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: s.playerCount == n
                                  ? t.woodEdge
                                  : t.cardFace)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _themePicker(MemoryThemeDef t) {
    final items = [
      ...MemoryThemes.all,
      s.customTheme,
    ];
    return _section(
      t,
      'Table theme',
      SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final th = items[i];
            final sel = s.themeId == th.id;
            final locked = !s.isPro &&
                (th.id == 'custom' || MemoryThemes.isProTheme(th.id));
            return GestureDetector(
              onTap: () {
                a.click();
                if (locked) {
                  _proNudge('themes');
                  return;
                }
                s.setTheme(th.id);
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: th.felt,
                          border: Border.all(
                              color: sel ? t.accent : Colors.transparent,
                              width: 2.5),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(0, 3),
                                blurRadius: 5)
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 38,
                            decoration: BoxDecoration(
                              color: th.cardBack,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: th.cardBackTrim, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      if (locked)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                color: Color(0xFFC9A227),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.lock_rounded,
                                size: 10, color: Color(0xFF3B2416)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(th.name.split(' ').first,
                      style: Match.body(10, theme: t)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _facePicker(MemoryThemeDef t) {
    final styles = [
      ...CardFaceStyles.all,
      const CardFaceStyle(
          id: 'custom', name: 'My Faces', desc: 'Design your own', faces: []),
    ];
    return _section(
      t,
      'Card faces',
      SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: styles.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final st = styles[i];
            final sel = s.cardStyleId == st.id;
            final locked = !s.isPro &&
                (st.id == 'custom' || CardFaceStyles.isProStyle(st.id));
            final preview = st.id == 'custom'
                ? (s.customFaces.isNotEmpty
                    ? s.customFaces.take(4).join(' ')
                    : '✏️')
                : st.faces.take(4).join(' ');
            return GestureDetector(
              onTap: () {
                a.click();
                if (locked) {
                  _proNudge('face styles');
                  return;
                }
                s.setCardStyle(st.id);
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 56,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: t.cardFace,
                          border: Border.all(
                              color: sel ? t.accent : t.cardFaceBorder,
                              width: sel ? 2.5 : 1.5),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(0, 3),
                                blurRadius: 5)
                          ],
                        ),
                        child: Center(
                          child: Text(preview,
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      if (locked)
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                color: Color(0xFFC9A227),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.lock_rounded,
                                size: 10, color: Color(0xFF3B2416)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(st.name.split(' ').first,
                      style: Match.body(10, theme: t)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cardBackPicker(MemoryThemeDef t) {
    return _section(
      t,
      'Card back design',
      Row(
        children: [
          for (final p in CardBackPatterns.all)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    a.click();
                    final locked = !s.isPro &&
                        CardBackPatterns.isProPattern(p.id);
                    if (locked) {
                      _proNudge('card back designs');
                      return;
                    }
                    s.setCardBack(p.id);
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 64,
                            child: CardBackFace(
                                theme: t, pattern: p.id, patternSize: 26),
                          ),
                          if (!s.isPro &&
                              CardBackPatterns.isProPattern(p.id))
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                    color: Color(0xFFC9A227),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.lock_rounded,
                                    size: 10, color: Color(0xFF3B2416)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(p.name,
                          style: Match.body(10, theme: t),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(MemoryThemeDef t, String label, bool sel, bool isPro,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        a.click();
        if (isPro && !s.isPro) {
          _proNudge(label);
          return;
        }
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: sel ? t.accent : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
              color: sel ? t.cardFace : t.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: sel ? t.woodEdge : t.cardFace)),
            if (isPro && !s.isPro) ...[
              const SizedBox(width: 5),
              const Icon(Icons.lock_rounded,
                  size: 12, color: Color(0xFFC9A227)),
            ],
          ],
        ),
      ),
    );
  }

  void _proNudge(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('That $what is PRO — tap GO PRO to unlock everything.',
            style: Match.body(14, theme: _t)),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: _t.accent,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) =>
                ProScreen(audio: a, settings: s, store: widget.store)),
          ),
        ),
      ),
    );
  }

  Widget _statsBar(MemoryThemeDef t) {
    final parts = <String>[];
    if (s.bestMoves > 0) parts.add('${s.bestMoves} moves');
    if (s.bestTime > 0) parts.add('${s.bestTime}s');
    if (s.bestStreak > 0) parts.add('x${s.bestStreak} streak');
    final best = parts.isEmpty ? '—' : parts.join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(t, '${s.gamesPlayed}', 'games'),
          _stat(t, '${s.wins}', 'wins'),
          _stat(t, best, 'best'),
        ],
      ),
    );
  }

  Widget _stat(MemoryThemeDef t, String v, String l) => Column(
        children: [
          Text(v, style: Match.onCream(16, theme: t).copyWith(color: t.cardFace)),
          Text(l, style: Match.body(11, theme: t, color: t.cardFace.withValues(alpha: 0.7))),
        ],
      );
}
