import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'generated_art.dart';

/// Shows a photo from assets/images if it exists. Otherwise a good-looking
/// picture is drawn in code, so the app looks nice with no image files.
class AppImage extends StatelessWidget {
  final String name;
  final double width;
  final double? height;
  final double radius;

  const AppImage({
    super.key,
    required this.name,
    this.width = double.infinity,
    this.height,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/images/$name',
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => GeneratedArt(seed: name),
        ),
      ),
    );
  }
}

/// Round profile picture. Without a photo it shows a coloured circle
/// with the person's first letter.
class Avatar extends StatelessWidget {
  final String name; // image file name, e.g. "milan.jpg"
  final String? label; // text used for the letter (defaults to name)
  final double size;
  final bool ring;
  final bool online;

  const Avatar({
    super.key,
    required this.name,
    this.label,
    this.size = 44,
    this.ring = false,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = (label ?? name).trim();
    final letter = text.isEmpty ? '?' : text[0].toUpperCase();
    final colors = ArtPalette.gradientFor(name);

    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ring ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: ring ? AppShadows.card : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/$name',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            alignment: Alignment.center,
            child: Text(letter,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.4)),
          ),
        ),
      ),
    );

    if (!online) return circle;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.27,
            height: size * 0.27,
            decoration: BoxDecoration(
              color: AppColors.online,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
