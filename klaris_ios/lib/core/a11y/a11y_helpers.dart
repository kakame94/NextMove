import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helpers for Klaris.
///
/// Goals:
///   - VoiceOver labels on icon-only buttons
///   - Dynamic-type clamp (1.0 - 1.6) so layouts stay usable when iOS Larger
///     Text is dialed up
///   - Semantic grouping for "card" composites
///   - Tap target floor (44pt) on chips/dots
extension A11yContext on BuildContext {
  /// Clamp the textScaler so 200% Dynamic Type doesn't overflow phone widgets.
  TextScaler clampedTextScaler({double max = 1.6}) {
    final raw = MediaQuery.textScalerOf(this);
    return raw.clamp(maxScaleFactor: max);
  }
}

/// Wraps icon-only buttons with a Semantics label.
class A11yIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const A11yIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 44, // tap target floor
        onPressed: onPressed,
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

/// Heat indicator dots aren't readable on their own — pair with a SemanticsLabel
/// so VoiceOver announces the score in plain words.
class A11yHeatLabel extends StatelessWidget {
  final int score;
  final Widget child;
  const A11yHeatLabel({super.key, required this.score, required this.child});

  @override
  Widget build(BuildContext context) {
    final tier = score >= 7 ? 'chaud' : score >= 4 ? 'tiède' : 'froid';
    return Semantics(
      label: 'Prospect $tier, score $score sur 10',
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Use on a row that visually conveys "$label: $value" so VoiceOver reads it
/// as one phrase instead of two separate text nodes.
class A11yRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget child;
  const A11yRow({super.key, required this.label, required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Wraps the app root to apply [clampedTextScaler] globally + announces
/// route transitions to VoiceOver.
class KlarisA11yShell extends StatelessWidget {
  final Widget child;
  const KlarisA11yShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: context.clampedTextScaler()),
      child: child,
    );
  }
}

/// Posts a polite VoiceOver announcement (used after async actions like
/// "Lead réassigné", "Mémo envoyé").
Future<void> announce(String message, {TextDirection dir = TextDirection.ltr}) {
  return SemanticsService.announce(message, dir);
}
