import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/audio_service.dart';
import '../services/iap_service.dart';
import '../services/settings_service.dart';
import '../theme/match_bits.dart';
import '../theme/memory_themes.dart';

/// Memory Match PRO: Free-vs-Pro comparison, real purchase, restore, tip jar.
/// All prices come from the store — never hardcoded, never placeholders.
class ProScreen extends StatefulWidget {
  final MatchAudio audio;
  final MatchSettings settings;
  final StoreService store;

  const ProScreen({
    super.key,
    required this.audio,
    required this.settings,
    required this.store,
  });

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  MemoryThemeDef get _t => MemoryThemes.byId(
        widget.settings.themeId,
        custom: widget.settings.customTheme,
      );

  @override
  void initState() {
    super.initState();
    widget.store.lastThanks.addListener(_onThanks);
  }

  
  void _onThanks() {
    final msg = widget.store.lastThanks.value;
    if (msg == null || !mounted) return;
    widget.audio.win();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: Match.body(15, theme: _t)),
        backgroundColor: _t.woodEdge,
        behavior: SnackBarBehavior.floating,
      ),
    );
    widget.store.lastThanks.value = null;
  }

  @override
  void dispose() {
    widget.store.lastThanks.removeListener(_onThanks);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final s = widget.settings;
    final store = widget.store;
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
                    Text('Memory Match PRO',
                        style: Match.display(24, theme: t)),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: s,
                  builder: (_, _) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    child: Column(
                      children: [
                                                _TipsCard(
                          theme: t,
                          store: store,
                          audio: widget.audio,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Free vs Pro comparison table — buyers see the big difference.
class _Cell extends StatelessWidget {
  final Object value; // bool | String
  final MemoryThemeDef theme;
  const _Cell({required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (value is bool) {
      final v = value as bool;
      return Text(
        v ? '✓' : '—',
        style: Match.body(15,
            theme: theme,
            color: v
                ? theme.accent
                : theme.cardFace.withValues(alpha: 0.4)),
        textAlign: TextAlign.center,
      );
    }
    return Text(
      value as String,
      style: Match.label(12, theme: theme),
      textAlign: TextAlign.center,
    );
  }
}

class _TipsCard extends StatelessWidget {
  final MemoryThemeDef theme;
  final StoreService store;
  final MatchAudio audio;
  const _TipsCard(
      {required this.theme, required this.store, required this.audio});

  @override
  Widget build(BuildContext context) {
    final tips = [
      store.coffeeProduct,
      store.chocolateProduct,
    ].whereType<ProductDetails>().toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.woodEdge.withValues(alpha: 0.9),
        border: Border.all(color: theme.accent, width: 2),
      ),
      child: Column(
        children: [
          Text('Tip the Maker', style: Match.display(20, theme: theme)),
          const SizedBox(height: 8),
          Text(
            'Memory Match is free forever. A small tip keeps new games coming!',
            style: Match.body(14, theme: theme),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (!store.storeReady)
            Text(
              store.error ?? 'Available after store setup.',
              style: Match.body(13,
                  theme: theme,
                  color: theme.cardFace.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            )
          else if (tips.isEmpty)
            Text('Tips coming soon.',
                style: Match.body(13,
                    theme: theme,
                    color: theme.cardFace.withValues(alpha: 0.6)))
          else
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final p in tips)
                  _TipChip(
                    theme: theme,
                    label:
                        '${p.id == StoreService.chocolateId ? '🍫' : '☕'} ${p.price}',
                    onTap: () {
                      audio.click();
                      store.buyTip(p);
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  final MemoryThemeDef theme;
  final String label;
  final VoidCallback onTap;
  const _TipChip(
      {required this.theme, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.black.withValues(alpha: 0.3),
          border:
              Border.all(color: theme.accent.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Text(label, style: Match.label(14, theme: theme)),
      ),
    );
  }
}
