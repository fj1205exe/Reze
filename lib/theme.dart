import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const bg = Color(0xFF0B0D10);
  static const surface = Color(0xFF14171C);
  static const surface2 = Color(0xFF1B1F26);
  static const surface3 = Color(0xFF2A2F38);
  static const txt = Color(0xFFF5F7FA);
  static const muted = Color(0xFF9CA3AF);
  static const accent = Color(0xFF8B5CF6);
  static const accentLight = Color(0xFFA78BFA);
  static const blue = Color(0xFF38BDF8);
  static const green = Color(0xFF4ADE80);
  static const yellow = Color(0xFFFBBF24);
  static const pink = Color(0xFFFB7185);
  static const greenLight = Color(0xFF86EFAC);
  static const teal = Color(0xFF6EE7B7);
  static const purple = Color(0xFFA78BFA);

  static final border = Colors.white.withValues(alpha: 0.06);
  static final dim = Colors.white.withValues(alpha: 0.04);
}

class S {
  static const rSm = 8.0;
  static const rMd = 12.0;
  static const rLg = 16.0;
  static final borderSm = BorderRadius.circular(rSm);
  static final borderMd = BorderRadius.circular(rMd);
  static final borderLg = BorderRadius.circular(rLg);

  static const screenPad = EdgeInsets.fromLTRB(16, 4, 16, 32);
  static const headerPad = EdgeInsets.fromLTRB(20, 12, 20, 12);
  static const cardPad = EdgeInsets.all(14);
  static const sectionPad = EdgeInsets.all(16);

  static const gap4 = SizedBox(height: 4);
  static const gap8 = SizedBox(height: 8);
  static const gap10 = SizedBox(height: 10);
  static const gap12 = SizedBox(height: 12);
  static const gap14 = SizedBox(height: 14);
  static const gap16 = SizedBox(height: 16);
  static const gap20 = SizedBox(height: 20);
  static const gap24 = SizedBox(height: 24);
  static const gap32 = SizedBox(height: 32);

  static BoxDecoration card({Color? fill, BorderRadius? radius}) => BoxDecoration(
    color: fill ?? C.surface,
    borderRadius: radius ?? borderMd,
    border: Border.all(color: C.border),
  );
}

TextStyle spaceGrotesk({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w500,
  Color color = C.txt,
  double letterSpacing = 0,
}) {
  return GoogleFonts.spaceGrotesk(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

TextStyle inter({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = C.muted,
  double? height,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

TextStyle mono({
  double fontSize = 13,
  FontWeight fontWeight = FontWeight.w500,
  Color color = C.accentLight,
}) {
  return GoogleFonts.jetBrainsMono(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

ThemeData mlabTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.dark(
      surface: C.bg,
      primary: C.accent,
      secondary: C.blue,
      error: C.pink,
      onPrimary: C.txt,
      onSurface: C.txt,
      onError: C.txt,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      elevation: 0,
    ),
  );
}
