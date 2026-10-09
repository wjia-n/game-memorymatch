import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/iap_service.dart';
import '../services/settings_service.dart';
import '../theme/match_bits.dart';
import '../theme/memory_themes.dart';
import 'custom_theme_screen.dart';
import 'pro_screen.dart';

/// Settings: renameable player profile, appearance, audio, custom creators.
class SettingsScreen extends StatefulWidget {
  final MatchAudio audio;
  final MatchSettings settings;
  final StoreService store;
  const SettingsScreen(
      {super.key, required this.audio, required this.settings, required this.store});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  MatchSettings get s => widget.settings;
  MatchAudio get a => widget.audio;

  late final List<TextEditingController> _nameCtrls;
  late final List<FocusNode> _nameFocus;

  @override
  void initState() {
    super.initState();
    // Controllers are seeded from the persisted names. Every keystroke saves
    // (onChanged) AND focus loss commits (focus listener) — so names survive
    // even when the keyboard never fires "done" (e.g. IME composition).
    _nameCtrls = [
      for (int i = 0; i < 4; i++)
        TextEditingController(text: s.playerNames[i])
    ];
    _nameFocus = [for (int i = 0; i < 4; i++) FocusNode()];
    for (int i = 0; i < 4; i++) {
      _nameFocus[i].addListener(() {
        if (!_nameFocus[i].hasFocus) s.setPlayerName(i, _nameCtrls[i].text);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _nameCtrls) {
      c.dispose();
    }
    for (final f in _nameFocus) {
      f.dispose();
    }
    super.dispose();
  }

  MemoryThemeDef get _t => MemoryThemes.byId(
        s.themeId,
        custom: s.customTheme,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: s,
        builder: (_, _) {
          final t = _t;
          return TableBackdrop(
            theme: t,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            a.click();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: t.accent.withValues(alpha: 0.6)),
                            ),
                            child: Icon(Icons.arrow_back_rounded,
                                color: t.accent, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Settings', style: Match.display(26, theme: t)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _namesCard(t),
                          const SizedBox(height: 12),
                          _audioCard(t),
                          const SizedBox(height: 12),
                          _customCard(t),
                          const SizedBox(height: 12),
                          _aboutCard(t),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(MemoryThemeDef t, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: Match.label(12, theme: t)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  /// Renameable player profile: 4 slots, order-safe JSON persistence.
  Widget _namesCard(MemoryThemeDef t) {
    return _card(t, 'Players', [
      for (int i = 0; i < 4; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.playerColors[i].withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.cardFace),
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: ValueKey('name_$i'),
                  controller: _nameCtrls[i],
                  focusNode: _nameFocus[i],
                  style: TextStyle(color: t.cardFace, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: MatchSettings.defaultNames[i],
                    hintStyle: TextStyle(
                        color: t.cardFace.withValues(alpha: 0.4)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: t.accent.withValues(alpha: 0.4)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  // Save on every keystroke; the focus listener commits
                  // again on focus loss.
                  onChanged: (v) => s.setPlayerName(i, v),
                  onSubmitted: (v) {
                    s.setPlayerName(i, v);
                    _nameFocus[i].unfocus();
                  },
                ),
              ),
            ],
          ),
        ),
      Text('Names show on score chips and the winner screen.',
          style: Match.body(12,
              theme: t, color: t.cardFace.withValues(alpha: 0.65))),
    ]);
  }

  Widget _audioCard(MemoryThemeDef t) {
    return _card(t, 'Sound', [
      _switchRow(
          t, 'Music', Icons.music_note_rounded, s.musicOn, (v) {
        a.click();
        s.setMusic(v);
        a.configure(musicOn: v, sfxOn: s.sfxOn, volume: s.volume);
        if (v) a.startMenuMusic();
      }),
      _switchRow(t, 'Sound effects', Icons.volume_up_rounded, s.sfxOn,
          (v) {
        s.setSfx(v);
        a.configure(musicOn: s.musicOn, sfxOn: v, volume: s.volume);
        if (v) a.click();
      }),
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(Icons.graphic_eq_rounded, color: t.accent, size: 20),
          Expanded(
            child: Slider(
              value: s.volume,
              activeColor: t.accent,
              inactiveColor: t.accent.withValues(alpha: 0.3),
              onChanged: (v) {
                s.setVolume(v);
                a.configure(
                    musicOn: s.musicOn, sfxOn: s.sfxOn, volume: v);
              },
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _switchRow(MemoryThemeDef t, String label, IconData icon, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: t.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label, style: Match.body(15, theme: t))),
          Switch(
            value: value,
            activeThumbColor: t.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _customCard(MemoryThemeDef t) {
    return _card(t, 'Custom creators', [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.palette_rounded, color: t.accent),
        title: Text('Table theme creator',
            style: Match.body(15, theme: t)),
        subtitle: Text('Design your own card table',
            style: Match.body(12,
                theme: t, color: t.cardFace.withValues(alpha: 0.65))),
        trailing: s.isPro
            ? Icon(Icons.chevron_right_rounded, color: t.accent)
            : const ProBadge(),
        onTap: () {
          a.click();
          if (!s.isPro) {
            _goPro();
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CustomThemeScreen(audio: a, settings: s),
            ),
          );
        },
      ),
      const Divider(color: Colors.white24, height: 1),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.style_rounded, color: t.accent),
        title:
            Text('Card face creator', style: Match.body(15, theme: t)),
        subtitle: Text(
            s.customFaces.isEmpty
                ? 'Pick your own set of pictures'
                : '${s.customFaces.length} faces chosen',
            style: Match.body(12,
                theme: t, color: t.cardFace.withValues(alpha: 0.65))),
        trailing: s.isPro
            ? Icon(Icons.chevron_right_rounded, color: t.accent)
            : const ProBadge(),
        onTap: () {
          a.click();
          if (!s.isPro) {
            _goPro();
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _FaceCreatorScreen(audio: a, settings: s),
            ),
          );
        },
      ),
    ]);
  }

  void _goPro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProScreen(audio: a, settings: s, store: widget.store)),
    );
  }

  Widget _aboutCard(MemoryThemeDef t) {
    return _card(t, 'About', [
      Row(
        children: [
          Image.asset('assets/wajiha_logo.png',
              width: 34, height: 34, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Memory Match · v1.0\nMade with ♥ by WAJIHA',
              style: Match.body(13, theme: t),
            ),
          ),
        ],
      ),
    ]);
  }
}

/// PRO card-face creator: pick any set of pictures from the master pool.
/// Persisted as ONE JSON string (order-safe).
class _FaceCreatorScreen extends StatefulWidget {
  final MatchAudio audio;
  final MatchSettings settings;
  const _FaceCreatorScreen({required this.audio, required this.settings});

  @override
  State<_FaceCreatorScreen> createState() => _FaceCreatorScreenState();
}

class _FaceCreatorScreenState extends State<_FaceCreatorScreen> {
  late Set<String> _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.settings.customFaces.toSet();
  }

  MemoryThemeDef get _t => MemoryThemes.byId(
        widget.settings.themeId,
        custom: widget.settings.customTheme,
      );

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final pool = CardFaceStyles.masterPool;
    return Scaffold(
      body: TableBackdrop(
        theme: t,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.audio.click();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: t.accent.withValues(alpha: 0.6)),
                        ),
                        child: Icon(Icons.arrow_back_rounded,
                            color: t.accent, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Card face creator',
                              style: Match.display(22, theme: t)),
                          Text('${_picked.length} picked · need 6–18',
                              style: Match.body(12,
                                  theme: t,
                                  color: t.cardFace
                                      .withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8),
                  itemCount: pool.length,
                  itemBuilder: (_, i) {
                    final f = pool[i];
                    final sel = _picked.contains(f);
                    return GestureDetector(
                      onTap: () {
                        widget.audio.click();
                        setState(() {
                          if (sel) {
                            _picked.remove(f);
                          } else if (_picked.length < 18) {
                            _picked.add(f);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: sel
                              ? t.accent
                              : t.cardFace.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: sel ? t.cardFace : t.cardFaceBorder,
                              width: sel ? 2.5 : 1.5),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.35),
                                offset: const Offset(0, 2),
                                blurRadius: 4)
                          ],
                        ),
                        child: Center(
                          child: Text(f,
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: WoodButton(
                  label: 'SAVE MY FACES',
                  theme: t,
                  onTap: _picked.length >= 6
                      ? () {
                          widget.audio.click();
                          widget.settings
                              .setCustomFaces(_picked.toList());
                          widget.settings.setCardStyle('custom');
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Your faces are on the table!',
                                    style: Match.body(14, theme: t))),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
