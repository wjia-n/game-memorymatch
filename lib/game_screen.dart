import 'package:flutter/material.dart';
import 'package:wajiha_game_core/wajiha_game_core.dart';

/// Memory Match - reference for solo score-chase + party turn-taking games.
class MemoryMatchScreen extends StatefulWidget {
  final List<Player> players;
  final GameCallbacks callbacks;

  const MemoryMatchScreen({super.key, required this.players, required this.callbacks});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  static const _faces = ['🦊', '🐼', '🦁', '🐸', '🐵', '🦄', '🐙', '🐝'];
  late List<String> cards;
  late List<bool> matched;
  final Set<int> _shown = {};
  int? first;
  bool lock = false;
  int turn = 0;
  int moves = 0;
  bool over = false;

  @override
  void initState() {
    super.initState();
    cards = [..._faces, ..._faces]..shuffle();
    matched = List.filled(16, false);
    widget.callbacks.setActivePlayer(0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeBotMove());
  }

  bool get solo => widget.players.length == 1;

  void _tap(int i) {
    if (over || lock || matched[i] || _shown.contains(i)) return;
    if (widget.players[turn].isBot) return;
    _flip(i);
  }

  void _flip(int i) {
    Sfx.tap();
    setState(() {
      _shown.add(i);
      if (first == null) {
        first = i;
        return;
      }
      moves++;
      final a = first!;
      first = null;
      if (cards[a] == cards[i]) {
        _onMatch(a, i);
      } else {
        lock = true;
        Future.delayed(const Duration(milliseconds: 750), () {
          if (!mounted || over) return;
          setState(() {
            _shown.remove(a);
            _shown.remove(i);
            lock = false;
          });
          if (!solo) {
            turn = (turn + 1) % widget.players.length;
            widget.callbacks.setActivePlayer(turn);
          }
          _maybeBotMove();
        });
      }
    });
  }

  void _onMatch(int a, int b) {
    matched[a] = true;
    matched[b] = true;
    _shown.remove(a);
    _shown.remove(b);
    Sfx.move();
    widget.players[turn].score += 1;
    widget.callbacks.refreshHud();
    if (matched.every((m) => m)) {
      _finish();
    } else {
      // matched pair: same player goes again
      _maybeBotMove();
    }
  }

  void _maybeBotMove() {
    if (over || lock || !widget.players[turn].isBot) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted || over || lock) return;
      final hidden = <int>[for (var i = 0; i < 16; i++) if (!matched[i] && !_shown.contains(i)) i];
      hidden.shuffle();
      if (hidden.isEmpty) return;
      if (first == null) {
        _flip(hidden.first);
      } else {
        final want = cards[first!];
        final pair = hidden.firstWhere((i) => cards[i] == want, orElse: () => hidden.first);
        _flip(pair);
      }
    });
  }

  void _finish() {
    over = true;
    Sfx.win();
    if (solo) {
      widget.callbacks.finish(
        headline: 'All pairs found! 🎉',
        subline: 'Finished in $moves moves. Can you beat that?',
      );
    } else {
      final ranked = [...widget.players]..sort((a, b) => b.score.compareTo(a.score));
      widget.callbacks.finish(winner: ranked.first, headline: '${ranked.first.name} wins! 🏆');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ThemeController.of(context).theme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!solo && !over)
            TurnBanner(
              player: widget.players[turn],
              action: widget.players[turn].isBot ? ' is peeking… 🤖' : ', pick two cards! 🃏',
            ),
          if (solo)
            Text('$moves moves', style: TextStyle(color: t.muted, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: 16,
              itemBuilder: (_, i) => _card(i, t),
            ),
          ),
          const SizedBox(height: 8),
          Text('Find all 8 pairs 🧠', style: TextStyle(color: t.muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _card(int i, GameTheme t) {
    final faceUp = matched[i] || _shown.contains(i);
    return GestureDetector(
      onTap: () => _tap(i),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: faceUp ? 1 : 0),
        duration: const Duration(milliseconds: 280),
        builder: (_, v, _) {
          final showingFace = v > 0.5;
          return Transform(
            transform: Matrix4.rotationY((1 - v) * 3.14159),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                gradient: showingFace
                    ? null
                    : LinearGradient(colors: [t.primary, t.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                color: showingFace ? t.surface : null,
                borderRadius: t.radius,
                border: Border.all(
                  color: matched[i] ? const Color(0xFF7BF1A8) : t.primary.withValues(alpha: 0.3),
                  width: matched[i] ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              alignment: Alignment.center,
              child: showingFace
                  ? Text(cards[i], style: const TextStyle(fontSize: 34))
                  : Text('💛', style: TextStyle(fontSize: 26, color: Colors.white.withValues(alpha: 0.85))),
            ),
          );
        },
      ),
    );
  }
}
