import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

/// Klaris design tokens — OKLCH palette converted to ARGB Color.
///
/// Source de verite : web tokens (`24_NextMove/clea-brand/brand-identity/tokens.css`).
/// Conversion OKLCH -> sRGB faite a la main pour matcher les valeurs web exactement.
abstract class KlarisColors {
  KlarisColors._();

  // Light mode
  static const Color background     = Color(0xFFFAF9F5);   // oklch(0.98 0.005 60)
  static const Color foreground     = Color(0xFF2A2521);   // oklch(0.20 0.02 30)
  static const Color card           = Color(0xFFFFFFFF);
  static const Color cardElev       = Color(0xFFFAF9F5);
  static const Color primary        = Color(0xFFC25A36);   // oklch(0.55 0.18 30) terracotta
  static const Color primaryFg      = Color(0xFFFEFEFE);
  static const Color primarySoft    = Color(0x1AC25A36);   // 10% opacity
  static const Color primaryStrong  = Color(0xFFA84A2A);
  static const Color muted          = Color(0xFFEEEAE2);
  static const Color mutedFg        = Color(0xFF7A7068);
  static const Color border         = Color(0xFFE2DDD3);
  static const Color destructive    = Color(0xFFD64C2E);
  static const Color success        = Color(0xFF50A04B);
  static const Color warning        = Color(0xFFE0A836);
  static const Color info           = Color(0xFF4F8FE0);

  // Heat scale (5 niveaux — scoring temperature)
  static const Color heat1 = Color(0xFF6FA1D8);  // froid bleu
  static const Color heat2 = Color(0xFF8AB4D0);
  static const Color heat3 = Color(0xFFE0A836);  // tiede ambre
  static const Color heat4 = Color(0xFFE07A45);
  static const Color heat5 = Color(0xFFD64C2E);  // brulant rouge

  // Dark mode (sci-fi)
  static const Color backgroundDark    = Color(0xFF0F1117);
  static const Color foregroundDark    = Color(0xFFF2F2F2);
  static const Color cardDark          = Color(0xFF1A1D24);
  static const Color cardElevDark      = Color(0xFF202329);
  static const Color primaryDark       = Color(0xFFE8825D);
  static const Color primaryFgDark     = Color(0xFF1A0F08);
  static const Color primarySoftDark   = Color(0x24E8825D);
  static const Color primaryStrongDark = Color(0xFFEE9670);
  static const Color mutedDark         = Color(0xFF272A30);
  static const Color mutedFgDark       = Color(0xFF999EA6);
  static const Color borderDark        = Color(0xFF353841);

  /// Returns heat color for score 0-10.
  static Color heatFor(int score) {
    final i = math.min(4, math.max(0, (score / 2.5).floor()));
    return [heat1, heat2, heat3, heat4, heat5][i];
  }

  /// Cupertino theme — light.
  static const CupertinoThemeData light = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    primaryContrastingColor: primaryFg,
    scaffoldBackgroundColor: background,
    barBackgroundColor: card,
    textTheme: CupertinoTextThemeData(
      primaryColor: primary,
      textStyle: TextStyle(color: foreground, fontSize: 16),
    ),
  );

  /// Cupertino theme — dark.
  static const CupertinoThemeData dark = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    primaryContrastingColor: primaryFgDark,
    scaffoldBackgroundColor: backgroundDark,
    barBackgroundColor: cardDark,
    textTheme: CupertinoTextThemeData(
      primaryColor: primaryDark,
      textStyle: TextStyle(color: foregroundDark, fontSize: 16),
    ),
  );
}

/// Theme-aware color resolver.
extension KlarisThemeContext on BuildContext {
  bool get isDark => CupertinoTheme.brightnessOf(this) == Brightness.dark;

  Color klBg          ()=> isDark ? KlarisColors.backgroundDark   : KlarisColors.background;
  Color klFg          ()=> isDark ? KlarisColors.foregroundDark   : KlarisColors.foreground;
  Color klCard        ()=> isDark ? KlarisColors.cardDark         : KlarisColors.card;
  Color klCardElev    ()=> isDark ? KlarisColors.cardElevDark     : KlarisColors.cardElev;
  Color klPrimary     ()=> isDark ? KlarisColors.primaryDark      : KlarisColors.primary;
  Color klPrimarySoft ()=> isDark ? KlarisColors.primarySoftDark  : KlarisColors.primarySoft;
  Color klMuted       ()=> isDark ? KlarisColors.mutedDark        : KlarisColors.muted;
  Color klMutedFg     ()=> isDark ? KlarisColors.mutedFgDark      : KlarisColors.mutedFg;
  Color klBorder      ()=> isDark ? KlarisColors.borderDark       : KlarisColors.border;
}
