import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_kit/liquid_glass_kit.dart';

class AppColors {
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF12121A);
  static const surfaceElevated = Color(0xFF171720);
  static const border = Color(0x1AFFFFFF);
  static const borderStrong = Color(0x24FFFFFF);
  static const violet = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF06B6D4);
  static const green = Color(0xFF22C55E);
  static const heading = Color(0xFFF8FAFC);
  static const body = Color(0xFFA0A0B0);

  // Compatibility aliases used by existing widgets.
  static const primary = violet;
  static const primaryDeep = Color(0xFF6D28D9);
  static const secondary = cyan;
  static const accent = Color(0xFF38BDF8);
  static const ink = Color(0xFF111118);
  static const lightSurface = Color(0xFFF7F7FB);
  static const darkSurface = background;

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet, cyan],
  );
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primaryDeep,
      secondary: AppColors.cyan,
      surface: const Color(0xFFFBFBFE),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF4F3F9),
      surfaceContainer: const Color(0xFFEFEFF6),
      surfaceContainerHighest: const Color(0xFFE8E7F0),
      onSurface: const Color(0xFF16161F),
      onSurfaceVariant: const Color(0xFF676775),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      textTheme: _textTheme(Brightness.light),
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF16161F),
        elevation: 0,
        centerTitle: false,
      ),
      extensions: <ThemeExtension<dynamic>>[
        LiquidGlassThemeData(
          quality: LiquidGlassQuality.high,
          blurSigma: 22,
          baseOpacity: 0.10,
          baseColor: Colors.white,
          borderColor: AppColors.violet.withValues(alpha: .10),
          borderWidth: 1.0,
          borderRadius: 24,
          accentColor: AppColors.violet,
        ),
      ],
      dividerTheme: const DividerThemeData(color: Color(0x1A111118)),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white.withValues(alpha: .72),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: _inputBorder(const Color(0x1A111118)),
        enabledBorder: _inputBorder(const Color(0x1A111118)),
        focusedBorder: _inputBorder(AppColors.primaryDeep, width: 1.3),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0x1A111118)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryDeep,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF20202A),
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          side: const BorderSide(color: Color(0x22111118)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.violet,
      secondary: AppColors.cyan,
      surface: AppColors.surface,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surfaceElevated,
      surfaceContainerHighest: const Color(0xFF1B1B26),
      onSurface: AppColors.heading,
      onSurfaceVariant: AppColors.body,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _textTheme(Brightness.dark),
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      extensions: <ThemeExtension<dynamic>>[
        LiquidGlassThemeData(
          quality: LiquidGlassQuality.high,
          blurSigma: 24,
          baseOpacity: 0.07,
          baseColor: Colors.black,
          borderColor: Colors.white.withValues(alpha: .10),
          borderWidth: 1.0,
          borderRadius: 24,
          accentColor: AppColors.violet,
        ),
      ],
      dividerTheme: const DividerThemeData(color: AppColors.border),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.violet, width: 1.3),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          side: const BorderSide(color: AppColors.borderStrong),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 76,
        height: .98,
        fontWeight: FontWeight.w800,
        letterSpacing: -4.2,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 58,
        height: 1.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -3.0,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 42,
        height: 1.05,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.8,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 31,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.1,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -.5,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        height: 1.72,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 1.55,
      ),
    );
  }
}
