import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xff5b58d8);
  static const mint = Color(0xffb088e8);
  static const pageBg = Color(0xfff8f7fc);
  static const accent = Color(0xffb088e8);
  static const brandDark = Color(0xff3b38c2);

  static const cardBg = Colors.white;
  static const darkCard = Color(0xff3b38c2);
  static const textPrimary = Color(0xff1e1b4b);
  static const textSecondary = Color(0xff8b85c1);
  static const textTertiary = Color(0xffb0acd8);
  static const divider = Color(0xffece9f8);
  static const inputFill = Color(0xfff4f1fd);
  static const inputBorder = Color(0xffddd8f0);
  static const tabInactive = Color(0xff9ca3af);
  static const success = Color(0xff5a9a7a);
  static const warning = Color(0xffc9956a);
  static const error = Color(0xffff6b6b);
  static const calendarSelected = primary;
  static const secondaryBtnBorder = Color(0xffe5e1f4);
  static const mintSoft = Color(0xffeeecff);

  static const primaryGradientEnd = Color(0xffb088e8);

  /// CSS `linear-gradient(135deg, …)`：左上 → 右下。
  static const AlignmentGeometry gradient135Begin = Alignment.topLeft;
  static const AlignmentGeometry gradient135End = Alignment.bottomRight;

  static const topGradient = LinearGradient(
    colors: [primary, Color(0xff7a6de6), mint],
    stops: [0.0, 0.38, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heroAmbientGradient({
    AlignmentGeometry begin = Alignment.topLeft,
  }) {
    return LinearGradient(
      begin: begin,
      end: Alignment.bottomRight,
      colors: const [
        primary,
        Color(0xff7a6de6),
        mint,
        Color(0x8cb088e8),
        Color(0x33b088e8),
        Color(0x00f8f7fc),
      ],
      stops: const [0.0, 0.16, 0.32, 0.5, 0.72, 1.0],
    );
  }

  static const btnGradient = LinearGradient(
    colors: [primary, mint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const radiusLarge = 22.0;
  static const radiusCard = 22.0;
  static const radiusInput = 14.0;
  static const radiusBtn = 12.0;
  static const radiusTag = 8.0;
  static const radiusNav = 22.0;

  static const maxContentWidth = 1180.0;
  static const desktopBreakpoint = 900.0;
  static const tabletBreakpoint = 600.0;

  static const cardShadow = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const fontFamily = 'PingFang SC, Microsoft YaHei, Noto Sans SC, sans-serif';

  static BoxDecoration cardDecoration({
    Color? color,
    double radius = radiusCard,
    bool bordered = true,
  }) =>
      BoxDecoration(
        color: color ?? cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: bordered ? Border.all(color: divider) : null,
        boxShadow: const [cardShadow],
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBg,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: pageBg,
        ),
        dividerColor: divider,
        dialogTheme: DialogThemeData(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFill,
          labelStyle: const TextStyle(fontSize: 14, color: textSecondary),
          hintStyle: const TextStyle(color: textTertiary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),
      );
}
