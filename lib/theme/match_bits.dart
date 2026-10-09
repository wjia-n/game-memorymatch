import 'dart:math';

import 'package:flutter/material.dart';
import 'memory_themes.dart';

/// Shared text styles + physical card-table widgets for Memory Match.
/// Warm serif display type, chunky wooden buttons, felt-and-wood backdrops.
/// No neon, no futuristic chrome.
class Match {
  static TextStyle display(double size, {required MemoryThemeDef theme}) =>
      TextStyle(
        fontFamily: 'Georgia',
        fontFamilyFallback: const ['serif'],
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: theme.cardFace,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.55),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      );

  static TextStyle body(double size,
          {required MemoryThemeDef theme, Color? color}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? theme.cardFace,
        height: 1.35,
      );

  static TextStyle label(double size,
          {required MemoryThemeDef theme, Color? color}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.6,
        color: color ?? theme.accent,
      );

  static TextStyle onCream(double size,
          {required MemoryThemeDef theme, FontWeight w = FontWeight.bold}) =>
      TextStyle(fontSize: size, fontWeight: w, color: theme.ink);
}

/// The card table: felt cloth center in a wooden frame, with a soft vignette.
class TableBackdrop extends StatelessWidget {
  final MemoryThemeDef theme;
  final Widget child;
  const TableBackdrop({super.key, required this.theme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.woodEdge, theme.woodEdge.withValues(alpha: 0.92)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.felt, theme.felt.withValues(alpha: 0.82)],
              ),
              border: Border.all(
                  color: theme.accent.withValues(alpha: 0.65), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 10),
                  blurRadius: 26,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A chunky physical wooden button with brass trim and pressed feedback.
class WoodButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final MemoryThemeDef theme;
  final double fontSize;
  final IconData? icon;
  const WoodButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.theme,
    this.fontSize = 17,
    this.icon,
  });

  @override
  State<WoodButton> createState() => _WoodButtonState();
}

class _WoodButtonState extends State<WoodButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _pressed
                ? [t.accentDark, t.accentDark]
                : [t.accent, t.accentDark],
          ),
          border: Border.all(
              color: t.cardFace.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              offset: Offset(0, _pressed ? 1 : 4),
              blurRadius: _pressed ? 3 : 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: t.woodEdge, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: t.woodEdge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small PRO lock badge used on premium pickers.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFC9A227),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 2),
              blurRadius: 4)
        ],
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF3B2416)),
      ),
    );
  }
}

/// Embossed card back: deep color + gold trim + selectable emboss pattern.
/// Patterns: 'diamond' | 'rings' | 'medallion' | 'weave'.
class CardBackFace extends StatelessWidget {
  final MemoryThemeDef theme;
  final String pattern;
  final double? patternSize;
  const CardBackFace(
      {super.key, required this.theme, this.pattern = 'diamond', this.patternSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.cardBack, theme.cardBack.withValues(alpha: 0.85)],
        ),
        border: Border.all(color: theme.cardBackTrim, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          painter: _CardBackPainter(
              pattern: pattern,
              color: theme.cardBackPattern,
              trim: theme.cardBackTrim),
          size: Size(patternSize ?? 30, patternSize ?? 30),
        ),
      ),
    );
  }
}

class _CardBackPainter extends CustomPainter {
  final String pattern;
  final Color color;
  final Color trim;
  _CardBackPainter(
      {required this.pattern, required this.color, required this.trim});

  @override
  void paint(Canvas canvas, Size size) {
    switch (pattern) {
      case 'rings':
        _rings(canvas, size);
        break;
      case 'medallion':
        _medallion(canvas, size);
        break;
      case 'weave':
        _weave(canvas, size);
        break;
      case 'diamond':
      default:
        _diamond(canvas, size);
    }
  }

  void _diamond(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()..color = color;
    final pt = Paint()
      ..color = trim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    Path diamond(double cx, double cy, double r) => Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r, cy)
      ..close();
    final d1 = diamond(w / 2, h / 2, w * 0.42);
    canvas.drawPath(d1, p);
    canvas.drawPath(d1, pt);
    final d2 = diamond(w / 2, h / 2, w * 0.2);
    canvas.drawPath(d2, pt);
  }

  void _rings(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..color = trim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final fill = Paint()..color = color;
    canvas.drawCircle(c, size.width * 0.42, fill);
    for (final r in [0.42, 0.3, 0.18]) {
      canvas.drawCircle(c, size.width * r, p);
    }
    canvas.drawCircle(c, size.width * 0.06, p..style = PaintingStyle.fill);
  }

  void _medallion(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = trim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    // 8-petal medallion.
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      final tip = c + Offset(cos(a) * r, sin(a) * r);
      final ctrl1 = c + Offset(cos(a - 0.35) * r * 0.55, sin(a - 0.35) * r * 0.55);
      final ctrl2 = c + Offset(cos(a + 0.35) * r * 0.55, sin(a + 0.35) * r * 0.55);
      final petal = Path()
        ..moveTo(c.dx, c.dy)
        ..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, tip.dx, tip.dy)
        ..cubicTo(ctrl2.dx, ctrl2.dy, ctrl1.dx, ctrl1.dy, c.dx, c.dy)
        ..close();
      canvas.drawPath(petal, fill);
      canvas.drawPath(petal, line);
    }
    canvas.drawCircle(c, r * 0.22, Paint()..color = trim);
  }

  void _weave(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final pt = Paint()
      ..color = trim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    // Diagonal crosshatch.
    const step = 7.0;
    for (double d = -h; d < w + h; d += step) {
      canvas.drawLine(Offset(d, 0), Offset(d + h, h), p);
      canvas.drawLine(Offset(d + h, 0), Offset(d, h), p);
    }
    // Trimmed border square.
    canvas.drawRect(
        Rect.fromLTWH(1.5, 1.5, w - 3, h - 3), pt);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
