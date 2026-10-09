import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/iap_service.dart';
import '../services/settings_service.dart';
import '../theme/match_bits.dart';
import '../theme/memory_themes.dart';
import 'menu_screen.dart';

/// Launch flow:
/// 1. WAJIHA company splash (official logo, untouched).
/// 2. Game splash: logo + name + animated loading line + "Credits: WAJIHA".
class SplashScreen extends StatefulWidget {
  final MatchAudio audio;
  final MatchSettings settings;
  final StoreService store;
  const SplashScreen(
      {super.key,
      required this.audio,
      required this.settings,
      required this.store});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loader;
  bool _companyDone = false;

  @override
  void initState() {
    super.initState();
    _loader = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _run();
  }

  Future<void> _run() async {
    widget.audio.prewarm();
    widget.audio.startMenuMusic();
    // Company moment first.
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() => _companyDone = true);
    // Then the game splash with the loading line.
    _loader.forward();
    await Future.delayed(const Duration(milliseconds: 2100));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MenuScreen(
          audio: widget.audio,
          settings: widget.settings,
          store: widget.store,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MemoryThemes.byId(
      widget.settings.themeId,
      custom: widget.settings.customTheme,
    );
    if (!_companyDone) return _CompanySplash(theme: theme);
    return _GameSplash(theme: theme, loader: _loader);
  }
}

/// Company splash: the official WAJIHA logo, shown untouched.
class _CompanySplash extends StatelessWidget {
  final MemoryThemeDef theme;
  const _CompanySplash({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          builder: (_, v, _) => Opacity(
            opacity: v,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/wajiha_logo.png',
                  width: 170,
                  height: 170,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
                Text('W A J I H A', style: Match.label(20, theme: theme)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Game splash: logo + name + animated loading line + credits.
class _GameSplash extends StatelessWidget {
  final MemoryThemeDef theme;
  final AnimationController loader;
  const _GameSplash({required this.theme, required this.loader});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableBackdrop(
        theme: theme,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: theme.accent, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        offset: const Offset(0, 10),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/memorymatch_logo.png',
                      fit: BoxFit.cover),
                ),
                const SizedBox(height: 22),
                Text('Memory Match', style: Match.display(46, theme: theme)),
                const SizedBox(height: 6),
                Text(
                  'THE CARD TABLE EDITION',
                  style: Match.label(13, theme: theme),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 220,
                  child: AnimatedBuilder(
                    animation: loader,
                    builder: (_, _) => Column(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.black.withValues(alpha: 0.45),
                            border: Border.all(
                                color:
                                    theme.accent.withValues(alpha: 0.5)),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: loader.value.clamp(0.02, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: LinearGradient(
                                  colors: [theme.accent, theme.accentDark],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loader.value < 1
                              ? 'Shuffling the deck…'
                              : 'Ready!',
                          style: Match.body(13,
                              theme: theme,
                              color: theme.cardFace
                                  .withValues(alpha: 0.75)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/wajiha_logo.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Credits: WAJIHA',
                      style: Match.label(14, theme: theme),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
