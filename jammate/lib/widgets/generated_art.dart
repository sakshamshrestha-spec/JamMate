import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colours and icons used to draw default pictures in code.
/// The same name always gives the same picture.
class ArtPalette {
  static const List<List<Color>> gradients = [
    [Color(0xFFE84C5C), Color(0xFFFF8A5B)],
    [Color(0xFF5B5BD6), Color(0xFF9B6BFF)],
    [Color(0xFF0F9D8A), Color(0xFF4FD1C5)],
    [Color(0xFF2B7DE9), Color(0xFF6CC3F5)],
    [Color(0xFFFF7A59), Color(0xFFFFB347)],
    [Color(0xFF8E3FD1), Color(0xFFD16BA5)],
    [Color(0xFF283248), Color(0xFF506080)],
  ];

  static const List<IconData> icons = [
    Icons.music_note,
    Icons.graphic_eq,
    Icons.album,
    Icons.headphones,
    Icons.mic,
    Icons.piano,
    Icons.queue_music,
    Icons.audiotrack,
  ];

  static int hash(String s) {
    int h = 7;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  static List<Color> gradientFor(String seed) =>
      gradients[hash(seed) % gradients.length];

  static IconData iconFor(String seed) =>
      icons[(hash(seed) ~/ 7) % icons.length];
}

/// A good-looking default picture: gradient + soft circles + sound waves + icon.
class GeneratedArt extends StatelessWidget {
  final String seed;
  final List<Color>? colors;
  final bool showIcon;
  final IconData? icon;

  const GeneratedArt({
    super.key,
    required this.seed,
    this.colors,
    this.showIcon = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors ?? ArtPalette.gradientFor(seed);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: c,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final s = box.biggest.shortestSide;
          final iconSize = s.isFinite ? (s * 0.34).clamp(16.0, 56.0).toDouble() : 32.0;
          return CustomPaint(
            painter: _ArtPainter(),
            child: showIcon
                ? Center(
                    child: Icon(icon ?? ArtPalette.iconFor(seed),
                        size: iconSize, color: const Color(0xE6FFFFFF)),
                  )
                : const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x1FFFFFFF);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1),
        size.shortestSide * 0.5, p);
    p.color = const Color(0x14FFFFFF);
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.95),
        size.shortestSide * 0.42, p);

    // Sound-wave bars along the bottom.
    final bar = Paint()..color = const Color(0x26FFFFFF);
    const w = 6.0;
    const gap = 5.0;
    final count = (size.width / (w + gap)).floor();
    for (int i = 0; i < count; i++) {
      final h = size.height *
          (0.05 +
              0.10 * (math.sin(i * 0.9) + 1) / 2 +
              0.06 * (math.sin(i * 0.37 + 1) + 1) / 2);
      final x = i * (w + gap) + gap;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h - size.height * 0.04, w, h),
          const Radius.circular(3),
        ),
        bar,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
