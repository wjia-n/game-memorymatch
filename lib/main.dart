import 'package:flutter/material.dart';
import 'package:wajiha_game_core/wajiha_game_core.dart';
import 'game_screen.dart';

void main() => runApp(const MemoryMatchApp());

class MemoryMatchApp extends StatelessWidget {
  const MemoryMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: 'Memory Match',
      tagline: 'Flip cards and match every pair - solo or party mode!',
      emoji: '🃏',
      slug: 'memorymatch',
      howToPlay:
          '• Tap two cards to flip them over. 🃏\n• Match the pair and it\'s yours — plus you get another go!\n• Miss, and the cards flip back while everyone watches. 👀\n• Solo: beat your own move count. Party: most pairs wins!\n• The bot has an elephant memory… probably. 🐘🤖',
      playerOptions: const [1, 2, 3, 4],
      supportsBots: true,
      gameBuilder: (ctx, players, cb) => MemoryMatchScreen(players: players, callbacks: cb),
    );
  }
}
