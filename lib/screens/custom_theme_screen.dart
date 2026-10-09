import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/match_bits.dart';
import '../theme/memory_themes.dart';

/// PRO: custom table-theme creator. Live preview, persisted per color.
class CustomThemeScreen extends StatefulWidget {
  final MatchAudio audio;
  final MatchSettings settings;

  const CustomThemeScreen(
      {super.key, required this.audio, required this.settings});

  @override
  State<CustomThemeScreen> createState() => _CustomThemeScreenState();
}

class _CustomThemeScreenState extends State<CustomThemeScreen> {
  MemoryThemeDef get _t => widget.settings.customTheme;

  static const List<Color> palette = [
    Color(0xFF3B2416), Color(0xFF5C3A21), Color(0xFF241309),
    Color(0xFF4A1F14), Color(0xFF6E2F1C), Color(0xFF2B1009),
    Color(0xFF1C2438), Color(0xFF2C3A55), Color(0xFF101624),
    Color(0xFF2E3B22), Color(0xFF4A5A34), Color(0xFF1A2312),
    Color(0xFFC9A227), Color(0xFFE8CE7A), Color(0xFF8A6D1A),
    Color(0xFFB87333), Color(0xFFE09E5A), Color(0xFF7E4F22),
    Color(0xFFC0C6D4), Color(0xFFE8ECF5), Color(0xFF7E8698),
    Color(0xFFF5EFE0), Color(0xFFFAF6EE), Color(0xFF2E2118),
    Color(0xFF1E4D3B), Color(0xFF0F3D2E), Color(0xFF3D1F2E),
    Color(0xFFA31621), Color(0xFF1D4E9E), Color(0xFF1B7A4D),
    Color(0xFFD99A2B), Color(0xFF7D3C98), Color(0xFF229954),
    Color(0xFF2471A3), Color(0xFFC0392B), Color(0xFFE67E22),
    Color(0xFFEFE3C8), Color(0xFFE4D3A8), Color(0xFF8A6A42),
  ];

  static const rows = [
    ('Felt cloth', 'felt'),
    ('Table wood', 'woodEdge'),
    ('Card back', 'cardBack'),
    ('Back trim', 'cardBackTrim'),
    ('Back pattern', 'cardBackPattern'),
    ('Card face', 'cardFace'),
    ('Face border', 'cardFaceBorder'),
    ('Ink', 'ink'),
    ('Accent', 'accent'),
    ('Accent dark', 'accentDark'),
    ('Player 1', 'pc0'),
    ('Player 2', 'pc1'),
    ('Player 3', 'pc2'),
    ('Player 4', 'pc3'),
  ];

  Future<void> _pick(String key, String label) async {
    final s = widget.settings;
    final current = Color(s.customColors[key]!);
    final chosen = await showDialog<Color>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF3B2416),
            border: Border.all(color: const Color(0xFFC9A227), width: 2.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pick $label',
                  style: Match.display(20, theme: _t)),
              const SizedBox(height: 14),
              SizedBox(
                width: 300,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: palette.length,
                  itemBuilder: (_, i) {
                    final c = palette[i];
                    final selected = c.value == current.value;
                    return GestureDetector(
                      onTap: () {
                        widget.audio.click();
                        Navigator.of(context).pop(c);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFE8CE7A)
                                : Colors.black.withValues(alpha: 0.4),
                            width: selected ? 3 : 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              WoodButton(
                label: 'Cancel',
                theme: _t,
                onTap: () {
                  widget.audio.click();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null) {
      await s.setCustomColor(key, chosen.value);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
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
                          Text('Table theme creator',
                              style: Match.display(22, theme: t)),
                          Text('Your table, your colors',
                              style: Match.body(12,
                                  theme: t,
                                  color: t.cardFace
                                      .withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.audio.click();
                        widget.settings.resetCustomColors();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: t.accent.withValues(alpha: 0.6)),
                        ),
                        child: Text('Reset',
                            style: Match.body(13, theme: t)),
                      ),
                    ),
                  ],
                ),
              ),
              // Live preview of the cards on the custom felt.
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 92,
                        height: 118,
                        child: CardBackFace(
                            theme: t,
                            pattern: widget.settings.cardBackId)),
                    const SizedBox(width: 14),
                    Container(
                      width: 92,
                      height: 118,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: t.cardFace,
                        border: Border.all(
                            color: t.cardFaceBorder, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.4),
                              offset: const Offset(0, 4),
                              blurRadius: 6)
                        ],
                      ),
                      child: Center(
                          child: Text('🦊',
                              style: TextStyle(
                                  fontSize: 40, color: t.ink))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(
                      color: Colors.white24, height: 1),
                  itemBuilder: (_, i) {
                    final (label, key) = rows[i];
                    final c = Color(widget.settings.customColors[key]!);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(label, style: Match.body(15, theme: t)),
                      trailing: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          border: Border.all(
                              color: t.accent, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(0, 2),
                                blurRadius: 4)
                          ],
                        ),
                      ),
                      onTap: () {
                        widget.audio.click();
                        _pick(key, label);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: WoodButton(
                  label: 'USE THIS THEME',
                  theme: t,
                  onTap: () {
                    widget.audio.click();
                    widget.settings.setTheme('custom');
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
