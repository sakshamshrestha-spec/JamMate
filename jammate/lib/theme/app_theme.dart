import 'package:flutter/material.dart';

/// All colours used in JamMate.
class AppColors {
  static const Color coral = Color(0xFFE84C5C);
  static const Color coralLight = Color(0xFFFDE8EA);
  static const Color orange = Color(0xFFFF7A59);
  static const Color background = Color(0xFFF6F6F8);
  static const Color text = Color(0xFF1E1E24);
  static const Color muted = Color(0xFF8B8B97);
  static const Color line = Color(0xFFEAEAF0);
  static const Color online = Color(0xFF2ECC71);
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 22, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 5)),
  ];
}

class AppGradients {
  static const List<Color> brandColors = [Color(0xFFE84C5C), Color(0xFFFF7A59)];

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: brandColors,
  );

  /// Dark fade used on top of photos so white text is readable.
  static const LinearGradient shade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xB8000000)],
  );
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.coral)
        .copyWith(primary: AppColors.coral, surface: Colors.white);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: AppColors.text,
            displayColor: AppColors.text,
          ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
