import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// Geist + Geist Mono — meme echelle que le web (Klaris brand).
abstract class KlarisType {
  KlarisType._();

  static TextStyle _base(double size, {FontWeight w = FontWeight.w400, double? height, double? letter}) =>
      GoogleFonts.getFont(
        'Geist',
        fontSize: size,
        fontWeight: w,
        height: height,
        letterSpacing: letter,
      );

  static TextStyle _mono(double size, {FontWeight w = FontWeight.w500}) =>
      GoogleFonts.getFont(
        'Geist Mono',
        fontSize: size,
        fontWeight: w,
        letterSpacing: 0.05,
      );

  // Headlines — alignement avec --fs-* tokens web
  static TextStyle hero       (Color c) => _base(38, w: FontWeight.w800, height: 1.05, letter: -1.4).copyWith(color: c);
  static TextStyle h1         (Color c) => _base(32, w: FontWeight.w700, height: 1.15, letter: -0.8).copyWith(color: c);
  static TextStyle h2         (Color c) => _base(24, w: FontWeight.w700, height: 1.2,  letter: -0.5).copyWith(color: c);
  static TextStyle h3         (Color c) => _base(18, w: FontWeight.w600, height: 1.3).copyWith(color: c);
  static TextStyle bodyLarge  (Color c) => _base(17, height: 1.5).copyWith(color: c);
  static TextStyle body       (Color c) => _base(15, height: 1.5).copyWith(color: c);
  static TextStyle bodySmall  (Color c) => _base(13, height: 1.45).copyWith(color: c);
  static TextStyle caption    (Color c) => _base(12, height: 1.4).copyWith(color: c);

  // Mono (codes, scores, badges)
  static TextStyle mono       (Color c, {double size = 12}) => _mono(size).copyWith(color: c);
  static TextStyle monoBold   (Color c, {double size = 12}) => _mono(size, w: FontWeight.w700).copyWith(color: c);

  // Eyebrow (uppercase mono, espace)
  static TextStyle eyebrow    (Color c) => _mono(11, w: FontWeight.w700).copyWith(
        color: c,
        letterSpacing: 1.4,
      );
}
