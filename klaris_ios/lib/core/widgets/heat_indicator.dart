import 'package:flutter/cupertino.dart';
import '../theme/klaris_colors.dart';

/// Heat scoring badge — 5 dots, 1 enlarged for current temperature.
/// Same logic as web (heat-1 cold blue → heat-5 hot red).
class HeatIndicator extends StatelessWidget {
  final int score; // 0-10
  final double dotSize;
  final double activeDotSize;

  const HeatIndicator({
    super.key,
    required this.score,
    this.dotSize = 6,
    this.activeDotSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    final activeIdx = (score / 2.5).floor().clamp(0, 4);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(5, (i) {
        final isActive = i == activeIdx;
        final size = isActive ? activeDotSize : dotSize;
        final color = [
          KlarisColors.heat1,
          KlarisColors.heat2,
          KlarisColors.heat3,
          KlarisColors.heat4,
          KlarisColors.heat5,
        ][i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

/// Compact heat label — score/10 + colored dot.
class HeatLabel extends StatelessWidget {
  final int score;
  const HeatLabel({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = KlarisColors.heatFor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$score/10',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              fontFamily: 'GeistMono',
            ),
          ),
        ],
      ),
    );
  }
}
