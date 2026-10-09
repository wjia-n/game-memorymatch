import 'package:flutter/material.dart';

/// Card-table art direction for Memory Match.
///
/// Physical, weighty cards on warm wooden tables — embossed card backs,
/// cream card faces, brass accents. Variety comes from different woods,
/// felt cloths and card-back emboss patterns. Never neon, never futuristic.
class MemoryThemeDef {
  final String id;
  final String name;
  final Color felt; // table cloth center
  final Color woodEdge; // wooden table frame
  final Color cardBack; // deep card-back color
  final Color cardBackTrim; // embossed border
  final Color cardBackPattern; // emboss pattern color
  final Color cardFace; // cream card face
  final Color cardFaceBorder;
  final Color ink; // text on cream
  final Color accent; // brass / gold accents
  final Color accentDark;
  final List<Color> playerColors;
  final List<String> playerColorNames;

  const MemoryThemeDef({
    required this.id,
    required this.name,
    required this.felt,
    required this.woodEdge,
    required this.cardBack,
    required this.cardBackTrim,
    required this.cardBackPattern,
    required this.cardFace,
    required this.cardFaceBorder,
    required this.ink,
    required this.accent,
    required this.accentDark,
    required this.playerColors,
    required this.playerColorNames,
  });
}

class MemoryThemes {
  /// First 4 are FREE. The rest are PRO. 'custom' is the PRO creator theme.
  static const List<String> freeThemeIds = [
    'walnut',
    'mahogany',
    'forest',
    'midnight',
  ];

  static const List<MemoryThemeDef> all = [
    MemoryThemeDef(
      id: 'walnut',
      name: 'Walnut Table',
      felt: Color(0xFF2E4A3A),
      woodEdge: Color(0xFF3B2416),
      cardBack: Color(0xFF7A2230),
      cardBackTrim: Color(0xFFC9A227),
      cardBackPattern: Color(0xFFA63A4A),
      cardFace: Color(0xFFF7F1E2),
      cardFaceBorder: Color(0xFFC9A227),
      ink: Color(0xFF2E2118),
      accent: Color(0xFFC9A227),
      accentDark: Color(0xFF8A6D1A),
      playerColors: [
        Color(0xFFA31621),
        Color(0xFF1D4E9E),
        Color(0xFF1B7A4D),
        Color(0xFFD99A2B),
      ],
      playerColorNames: ['Ruby', 'Sapphire', 'Emerald', 'Amber'],
    ),
    MemoryThemeDef(
      id: 'mahogany',
      name: 'Mahogany Club',
      felt: Color(0xFF3D1F2E),
      woodEdge: Color(0xFF4A1F14),
      cardBack: Color(0xFF2E3A55),
      cardBackTrim: Color(0xFFD4AF37),
      cardBackPattern: Color(0xFF3E4E70),
      cardFace: Color(0xFFF8F1E2),
      cardFaceBorder: Color(0xFFD4AF37),
      ink: Color(0xFF2A1A10),
      accent: Color(0xFFD4AF37),
      accentDark: Color(0xFF96702A),
      playerColors: [
        Color(0xFFC0392B),
        Color(0xFF7D3C98),
        Color(0xFF1E8449),
        Color(0xFFB7950B),
      ],
      playerColorNames: ['Garnet', 'Amethyst', 'Jade', 'Topaz'],
    ),
    MemoryThemeDef(
      id: 'forest',
      name: 'Forest Felt',
      felt: Color(0xFF1E4D3B),
      woodEdge: Color(0xFF2E3B22),
      cardBack: Color(0xFF8A5A1E),
      cardBackTrim: Color(0xFFE8CE7A),
      cardBackPattern: Color(0xFFA36E2A),
      cardFace: Color(0xFFF5EFE0),
      cardFaceBorder: Color(0xFF8A6D1A),
      ink: Color(0xFF22301C),
      accent: Color(0xFFC9A227),
      accentDark: Color(0xFF8A6D1A),
      playerColors: [
        Color(0xFFB03A2E),
        Color(0xFF2E86C1),
        Color(0xFFD4AC0D),
        Color(0xFF8E44AD),
      ],
      playerColorNames: ['Claret', 'Steel', 'Ochre', 'Plum'],
    ),
    MemoryThemeDef(
      id: 'midnight',
      name: 'Midnight Library',
      felt: Color(0xFF1B2A4A),
      woodEdge: Color(0xFF1C2438),
      cardBack: Color(0xFF5A1E2E),
      cardBackTrim: Color(0xFFC0C6D4),
      cardBackPattern: Color(0xFF6E2C3E),
      cardFace: Color(0xFFF2EEE4),
      cardFaceBorder: Color(0xFFC0C6D4),
      ink: Color(0xFF1E2433),
      accent: Color(0xFFC0C6D4),
      accentDark: Color(0xFF7E8698),
      playerColors: [
        Color(0xFFD64545),
        Color(0xFF4A90D9),
        Color(0xFF3FB97F),
        Color(0xFFE0A83C),
      ],
      playerColorNames: ['Candle', 'Moonstone', 'Fern', 'Lantern'],
    ),
    MemoryThemeDef(
      id: 'cherry',
      name: 'Cherry Wood',
      felt: Color(0xFF4A2E3F),
      woodEdge: Color(0xFF5A2A1A),
      cardBack: Color(0xFF1E3A4A),
      cardBackTrim: Color(0xFFDFC084),
      cardBackPattern: Color(0xFF2A4A5C),
      cardFace: Color(0xFFF7EFE0),
      cardFaceBorder: Color(0xFFB08D3E),
      ink: Color(0xFF331F14),
      accent: Color(0xFFB08D3E),
      accentDark: Color(0xFF7A6128),
      playerColors: [
        Color(0xFFC0392B),
        Color(0xFF2471A3),
        Color(0xFF229954),
        Color(0xFFD4AC0D),
      ],
      playerColorNames: ['Poppy', 'Teal', 'Moss', 'Wheat'],
    ),
    MemoryThemeDef(
      id: 'goldenoak',
      name: 'Golden Oak',
      felt: Color(0xFF4A5A2A),
      woodEdge: Color(0xFF7A5A24),
      cardBack: Color(0xFF4A1420),
      cardBackTrim: Color(0xFFD4A94E),
      cardBackPattern: Color(0xFF5E1E2A),
      cardFace: Color(0xFFF7EBD0),
      cardFaceBorder: Color(0xFF8C6A2F),
      ink: Color(0xFF2E2118),
      accent: Color(0xFF8C6A2F),
      accentDark: Color(0xFF5F471E),
      playerColors: [
        Color(0xFFA31621),
        Color(0xFF1D4E9E),
        Color(0xFF1B7A4D),
        Color(0xFF6E2C00),
      ],
      playerColorNames: ['Ruby', 'Sapphire', 'Emerald', 'Cocoa'],
    ),
    MemoryThemeDef(
      id: 'rosewood',
      name: 'Rosewood',
      felt: Color(0xFF4A2430),
      woodEdge: Color(0xFF3F1D24),
      cardBack: Color(0xFF1D4E5A),
      cardBackTrim: Color(0xFFE09E5A),
      cardBackPattern: Color(0xFF2A6070),
      cardFace: Color(0xFFF5EFE0),
      cardFaceBorder: Color(0xFFB87333),
      ink: Color(0xFF2A1A16),
      accent: Color(0xFFB87333),
      accentDark: Color(0xFF7E4F22),
      playerColors: [
        Color(0xFFD4AC0D),
        Color(0xFF2E86C1),
        Color(0xFF229954),
        Color(0xFFAF601A),
      ],
      playerColorNames: ['Wheat', 'Steel', 'Leaf', 'Caramel'],
    ),
    MemoryThemeDef(
      id: 'ebony',
      name: 'Ebony & Silver',
      felt: Color(0xFF2A2A34),
      woodEdge: Color(0xFF1A1A1E),
      cardBack: Color(0xFF7A2230),
      cardBackTrim: Color(0xFFF0F2F8),
      cardBackPattern: Color(0xFF8E2E3C),
      cardFace: Color(0xFFF2EEE4),
      cardFaceBorder: Color(0xFF7E8698),
      ink: Color(0xFF1E1E24),
      accent: Color(0xFFC0C6D4),
      accentDark: Color(0xFF7E8698),
      playerColors: [
        Color(0xFFE74C3C),
        Color(0xFF3498DB),
        Color(0xFF2ECC71),
        Color(0xFFF39C12),
      ],
      playerColorNames: ['Flame', 'Sky', 'Mint', 'Gold'],
    ),
    MemoryThemeDef(
      id: 'ivory',
      name: 'Ivory & Gold',
      felt: Color(0xFF2E5A44),
      woodEdge: Color(0xFFEFE3C8),
      cardBack: Color(0xFF2E3A55),
      cardBackTrim: Color(0xFF9A7B1E),
      cardBackPattern: Color(0xFF3E4E70),
      cardFace: Color(0xFFFBF6E9),
      cardFaceBorder: Color(0xFF9A7B1E),
      ink: Color(0xFF2E2118),
      accent: Color(0xFF9A7B1E),
      accentDark: Color(0xFF6E5514),
      playerColors: [
        Color(0xFFA31621),
        Color(0xFF1D4E9E),
        Color(0xFF1B7A4D),
        Color(0xFFB26A00),
      ],
      playerColorNames: ['Ruby', 'Sapphire', 'Emerald', 'Honey'],
    ),
    MemoryThemeDef(
      id: 'teal',
      name: 'Teal Atelier',
      felt: Color(0xFF0F3D3A),
      woodEdge: Color(0xFF1E3A38),
      cardBack: Color(0xFF6E2A1A),
      cardBackTrim: Color(0xFFE8CE7A),
      cardBackPattern: Color(0xFF823A22),
      cardFace: Color(0xFFF0EDE2),
      cardFaceBorder: Color(0xFF8A6D1A),
      ink: Color(0xFF1E2E2C),
      accent: Color(0xFFC9A227),
      accentDark: Color(0xFF8A6D1A),
      playerColors: [
        Color(0xFFC0392B),
        Color(0xFFD4AC0D),
        Color(0xFF8E44AD),
        Color(0xFFE67E22),
      ],
      playerColorNames: ['Poppy', 'Wheat', 'Plum', 'Ember'],
    ),
    MemoryThemeDef(
      id: 'burgundy',
      name: 'Burgundy Velvet',
      felt: Color(0xFF4A1A38),
      woodEdge: Color(0xFF3A1A2E),
      cardBack: Color(0xFF1D4E5A),
      cardBackTrim: Color(0xFFF3DC8E),
      cardBackPattern: Color(0xFF2A6070),
      cardFace: Color(0xFFF8F1E2),
      cardFaceBorder: Color(0xFFD4AF37),
      ink: Color(0xFF2E1A26),
      accent: Color(0xFFD4AF37),
      accentDark: Color(0xFF96702A),
      playerColors: [
        Color(0xFFD4AC0D),
        Color(0xFF2E86C1),
        Color(0xFF229954),
        Color(0xFFCA6F1E),
      ],
      playerColorNames: ['Wheat', 'Steel', 'Leaf', 'Amber'],
    ),
    MemoryThemeDef(
      id: 'slate',
      name: 'Slate & Brass',
      felt: Color(0xFF3B4252),
      woodEdge: Color(0xFF2E3440),
      cardBack: Color(0xFF7A2230),
      cardBackTrim: Color(0xFFE8CE7A),
      cardBackPattern: Color(0xFF8E2E3C),
      cardFace: Color(0xFFECEFF4),
      cardFaceBorder: Color(0xFFC9A227),
      ink: Color(0xFF23283A),
      accent: Color(0xFFC9A227),
      accentDark: Color(0xFF8A6D1A),
      playerColors: [
        Color(0xFFBF616A),
        Color(0xFF5E81AC),
        Color(0xFFA3BE8C),
        Color(0xFFEBCB8B),
      ],
      playerColorNames: ['Aurora', 'Frost', 'Sage', 'Nord'],
    ),
    MemoryThemeDef(
      id: 'olive',
      name: 'Olive Grove',
      felt: Color(0xFF4A5228),
      woodEdge: Color(0xFF3F4226),
      cardBack: Color(0xFF5A1E2E),
      cardBackTrim: Color(0xFFE8CE7A),
      cardBackPattern: Color(0xFF6E2C3E),
      cardFace: Color(0xFFF1EAD8),
      cardFaceBorder: Color(0xFF8A6D1A),
      ink: Color(0xFF2A2E16),
      accent: Color(0xFFC9A227),
      accentDark: Color(0xFF8A6D1A),
      playerColors: [
        Color(0xFFB03A2E),
        Color(0xFF2E86C1),
        Color(0xFFD4AC0D),
        Color(0xFF935116),
      ],
      playerColorNames: ['Brick', 'River', 'Wheat', 'Umber'],
    ),
    MemoryThemeDef(
      id: 'porcelain',
      name: 'Porcelain Parlor',
      felt: Color(0xFFDCE8F0),
      woodEdge: Color(0xFFE8E0D0),
      cardBack: Color(0xFF922B21),
      cardBackTrim: Color(0xFF2E5A88),
      cardBackPattern: Color(0xFFA63A2E),
      cardFace: Color(0xFFFFFFFF),
      cardFaceBorder: Color(0xFF2E5A88),
      ink: Color(0xFF2A2118),
      accent: Color(0xFF2E5A88),
      accentDark: Color(0xFF1E3A5C),
      playerColors: [
        Color(0xFFC0392B),
        Color(0xFF1D4E9E),
        Color(0xFF1B7A4D),
        Color(0xFF8E44AD),
      ],
      playerColorNames: ['Cinnabar', 'Cobalt', 'Celadon', 'Plum'],
    ),
    MemoryThemeDef(
      id: 'charcoal',
      name: 'Charcoal Club',
      felt: Color(0xFF33302A),
      woodEdge: Color(0xFF242424),
      cardBack: Color(0xFF1D5A4A),
      cardBackTrim: Color(0xFFE09E5A),
      cardBackPattern: Color(0xFF2A6E5C),
      cardFace: Color(0xFFF0EBE0),
      cardFaceBorder: Color(0xFFB87333),
      ink: Color(0xFF242424),
      accent: Color(0xFFB87333),
      accentDark: Color(0xFF7E4F22),
      playerColors: [
        Color(0xFFE74C3C),
        Color(0xFF5DADE2),
        Color(0xFF58D68D),
        Color(0xFFF5B041),
      ],
      playerColorNames: ['Ember', 'Glacier', 'Jade', 'Honey'],
    ),
    MemoryThemeDef(
      id: 'winecellar',
      name: 'Wine Cellar',
      felt: Color(0xFF3E1E3E),
      woodEdge: Color(0xFF2E1A2E),
      cardBack: Color(0xFF2E5A3A),
      cardBackTrim: Color(0xFFE8CE7A),
      cardBackPattern: Color(0xFF3E6E4A),
      cardFace: Color(0xFFF5EFE0),
      cardFaceBorder: Color(0xFFC9A227),
      ink: Color(0xFF241824),
      accent: Color(0xFFC9A227),
      accentDark: Color(0xFF8A6D1A),
      playerColors: [
        Color(0xFFD4AC0D),
        Color(0xFF5DADE2),
        Color(0xFF58D68D),
        Color(0xFFEC7063),
      ],
      playerColorNames: ['Sauternes', 'Mist', 'Verde', 'Rosé'],
    ),
    MemoryThemeDef(
      id: 'lodge',
      name: 'Forest Lodge',
      felt: Color(0xFF2F4A2A),
      woodEdge: Color(0xFF3E3226),
      cardBack: Color(0xFF4A1420),
      cardBackTrim: Color(0xFFE8CE7A),
      cardBackPattern: Color(0xFF5E1E2A),
      cardFace: Color(0xFFF1EAD8),
      cardFaceBorder: Color(0xFFC9A227),
      ink: Color(0xFF2A2018),
      accent: Color(0xFFC9A227),
      accentDark: Color(0xFF8A6D1A),
      playerColors: [
        Color(0xFFB03A2E),
        Color(0xFF2E86C1),
        Color(0xFFE67E22),
        Color(0xFF7D6608),
      ],
      playerColorNames: ['Brick', 'River', 'Ember', 'Hay'],
    ),
    MemoryThemeDef(
      id: 'sandalwood',
      name: 'Sandalwood',
      felt: Color(0xFF5A6E3A),
      woodEdge: Color(0xFF8A6A42),
      cardBack: Color(0xFF3A1A4A),
      cardBackTrim: Color(0xFFC49A5A),
      cardBackPattern: Color(0xFF4A245A),
      cardFace: Color(0xFFF8ECD2),
      cardFaceBorder: Color(0xFF7A5A2E),
      ink: Color(0xFF2E2118),
      accent: Color(0xFF7A5A2E),
      accentDark: Color(0xFF54401E),
      playerColors: [
        Color(0xFF922B21),
        Color(0xFF1A5276),
        Color(0xFF1E8449),
        Color(0xFF7E5109),
      ],
      playerColorNames: ['Oxblood', 'Navy', 'Forest', 'Brass'],
    ),
    MemoryThemeDef(
      id: 'copper',
      name: 'Walnut & Copper',
      felt: Color(0xFF3F2B1F),
      woodEdge: Color(0xFF3B2416),
      cardBack: Color(0xFF1E4E3A),
      cardBackTrim: Color(0xFFE09E5A),
      cardBackPattern: Color(0xFF2A604A),
      cardFace: Color(0xFFF5EFE0),
      cardFaceBorder: Color(0xFFB87333),
      ink: Color(0xFF2A1E14),
      accent: Color(0xFFB87333),
      accentDark: Color(0xFF7E4F22),
      playerColors: [
        Color(0xFFA31621),
        Color(0xFF1F618D),
        Color(0xFF1E8449),
        Color(0xFFCA8A2B),
      ],
      playerColorNames: ['Ruby', 'Denim', 'Leaf', 'Bronze'],
    ),
  ];

  static MemoryThemeDef byId(String id, {MemoryThemeDef? custom}) {
    if (id == 'custom') return custom ?? all.first;
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }

  static bool isProTheme(String id) =>
      !freeThemeIds.contains(id) && id != 'custom';
}

/// Card-face picture sets. Each needs ≥18 faces (Expert grid = 18 pairs).
/// Emoji are used — copyright-safe and crisp at any size.
/// 0-3 = FREE, 4+ = PRO. 'custom' is the PRO creator set.
class CardFaceStyle {
  final String id;
  final String name;
  final String desc;
  final List<String> faces;

  const CardFaceStyle({
    required this.id,
    required this.name,
    required this.desc,
    required this.faces,
  });
}

class CardFaceStyles {
  static const List<String> freeStyleIds = ['forest', 'fruits', 'ocean', 'sweets'];

  static const List<CardFaceStyle> all = [
    CardFaceStyle(
      id: 'forest',
      name: 'Forest Friends',
      desc: 'Cozy woodland animals',
      faces: [
        '🦊', '🐼', '🦉', '🐰', '🐻', '🦌', '🦔', '🐿️',
        '🐸', '🦝', '🐭', '🦡', '🐗', '🦅', '🐢', '🦎',
        '🦇', '🦜',
      ],
    ),
    CardFaceStyle(
      id: 'fruits',
      name: 'Juicy Fruits',
      desc: 'Fresh from the orchard',
      faces: [
        '🍎', '🍊', '🍌', '🍇', '🍓', '🍉', '🍍', '🍒',
        '🥝', '🍑', '🍐', '🥭', '🍋', '🫐', '🥥', '🍈',
        '🍅', '🌰',
      ],
    ),
    CardFaceStyle(
      id: 'ocean',
      name: 'Ocean Pals',
      desc: 'Friends under the sea',
      faces: [
        '🐟', '🐙', '🐢', '🦀', '🐳', '🦈', '🐬', '🦭',
        '🐚', '🪼', '🦑', '🐡', '🐠', '🦐', '🪸', '⚓',
        '🏖️', '⛵',
      ],
    ),
    CardFaceStyle(
      id: 'sweets',
      name: 'Sweet Treats',
      desc: 'Bakery day goodies',
      faces: [
        '🧁', '🍩', '🍨', '🍪', '🍬', '🍰', '🍫', '🍦',
        '🥞', '🧇', '🍯', '🥧', '🍮', '🍭', '🥤', '🧋',
        '🍿', '🥜',
      ],
    ),
    CardFaceStyle(
      id: 'gems',
      name: 'Gemstones',
      desc: 'Polished precious stones',
      faces: [
        '💎', '🔷', '🔶', '🟥', '🟩', '🟦', '🟪', '🟨',
        '💍', '👑', '⚜️', '🏆', '🔱', '🗝️', '💰', '🪙',
        '🥇', '🥈',
      ],
    ),
    CardFaceStyle(
      id: 'space',
      name: 'Space Voyage',
      desc: 'Gentle night-sky wonders',
      faces: [
        '🚀', '🪐', '⭐', '🌙', '☄️', '👩‍🚀', '🛸', '🌍',
        '🌟', '✨', '🌌', '🔭', '🛰️', '🌠', '🌗', '🌞',
        '🌈', '🌤️',
      ],
    ),
    CardFaceStyle(
      id: 'music',
      name: 'Music Box',
      desc: 'Instruments of the parlor',
      faces: [
        '🎹', '🎸', '🥁', '🎺', '🎻', '🎷', '🎼', '🎧',
        '🎤', '🪕', '🪗', '🪇', '📯', '🎶', '🎵', '🕺',
        '💃', '🎪',
      ],
    ),
    CardFaceStyle(
      id: 'blooms',
      name: 'Garden Blooms',
      desc: 'Flowers in full color',
      faces: [
        '🌹', '🌻', '🌷', '🌼', '🌸', '🌺', '💐', '🌾',
        '🍀', '🌵', '🪷', '🌲', '🍄', '🍁', '🌿', '🌴',
        '🪻', '🥀',
      ],
    ),
    CardFaceStyle(
      id: 'farm',
      name: 'Farmyard Fun',
      desc: 'Sunny barnyard animals',
      faces: [
        '🐶', '🐱', '🐷', '🐮', '🐴', '🐥', '🦆', '🐑',
        '🐐', '🐔', '🦃', '🐰', '🐀', '🐓', '🦜', '🐦',
        '🪿', '🦚',
      ],
    ),
    CardFaceStyle(
      id: 'weather',
      name: 'Weather Wonders',
      desc: 'Sky above the table',
      faces: [
        '☀️', '⛅', '🌧️', '❄️', '⚡', '🌪️', '🌈', '🌊',
        '🔥', '💧', '🌬️', '☁️', '🌫️', '⛈️', '🌨️', '💦',
        '☔', '⛄',
      ],
    ),
  ];

  static CardFaceStyle byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => all.first);

  static bool isProStyle(String id) =>
      !freeStyleIds.contains(id) && id != 'custom';

  /// Every face from every style — the pool for the custom creator.
  static List<String> get masterPool =>
      [for (final s in all) ...s.faces].toSet().toList();
}

/// Grid tiers. Hard/Expert grids need at least these many faces in the style.
class GridTier {
  final String id;
  final String name;
  final int rows;
  final int cols;
  final int pairs;

  const GridTier(
      {required this.id,
      required this.name,
      required this.rows,
      required this.cols})
      : pairs = rows * cols ~/ 2;

  static const List<GridTier> all = [
    GridTier(id: 'easy', name: 'Easy · 4×3', rows: 4, cols: 3),
    GridTier(id: 'classic', name: 'Classic · 4×4', rows: 4, cols: 4),
    GridTier(id: 'hard', name: 'Hard · 6×4', rows: 6, cols: 4),
    GridTier(id: 'expert', name: 'Expert · 6×6', rows: 6, cols: 6),
  ];

  static GridTier byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all[1]);

  static const List<String> freeTierIds = ['easy', 'classic'];
  static bool isProTier(String id) => !freeTierIds.contains(id);
}

/// Card-back emboss pattern designs painted on every card back.
/// 'diamond' + 'rings' are FREE; 'medallion' + 'weave' are PRO.
class CardBackPattern {
  final String id;
  final String name;
  const CardBackPattern({required this.id, required this.name});
}

class CardBackPatterns {
  static const List<CardBackPattern> all = [
    CardBackPattern(id: 'diamond', name: 'Diamond'),
    CardBackPattern(id: 'rings', name: 'Rings'),
    CardBackPattern(id: 'medallion', name: 'Medallion'),
    CardBackPattern(id: 'weave', name: 'Weave'),
  ];

  static const List<String> freePatternIds = ['diamond', 'rings'];

  static bool exists(String id) => all.any((p) => p.id == id);

  static bool isProPattern(String id) =>
      exists(id) && !freePatternIds.contains(id);
}
