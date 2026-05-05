import 'package:flutter/cupertino.dart';
import '../theme/klaris_colors.dart';

/// Mascotte robot Klaris — meme proportions que la version web.
/// CustomPainter (pas de SVG package = zero dependance + animation propre).
class KlarisMascot extends StatefulWidget {
  final double size;
  final bool animated;
  const KlarisMascot({super.key, this.size = 200, this.animated = true});

  @override
  State<KlarisMascot> createState() => _KlarisMascotState();
}

class _KlarisMascotState extends State<KlarisMascot> with TickerProviderStateMixin {
  late final AnimationController _float;
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _blink = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    _float.dispose();
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = context.klCard();
    final borderColor = context.klBorder();
    final primary = context.klPrimary();
    final fg = context.klFg();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_float, _blink]),
        builder: (_, __) {
          final dy = widget.animated ? (_float.value * 8) - 4 : 0.0;
          // Eye blink: open most of cycle, closed briefly at 0.92-0.98.
          final eyeOpenness = widget.animated
              ? (_blink.value > 0.92 && _blink.value < 0.98 ? 0.1 : 1.0)
              : 1.0;
          return Transform.translate(
            offset: Offset(0, dy),
            child: CustomPaint(
              painter: _MascotPainter(
                bodyColor: cardColor,
                borderColor: borderColor,
                visorColor: primary,
                eyeColor: KlarisColors.primaryFg,
                cheekColor: KlarisColors.success,
                fgColor: fg,
                eyeOpenness: eyeOpenness,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final Color bodyColor;
  final Color borderColor;
  final Color visorColor;
  final Color eyeColor;
  final Color cheekColor;
  final Color fgColor;
  final double eyeOpenness;

  _MascotPainter({
    required this.bodyColor,
    required this.borderColor,
    required this.visorColor,
    required this.eyeColor,
    required this.cheekColor,
    required this.fgColor,
    required this.eyeOpenness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 400.0; // Scale factor (mascot designed in 400x400 viewBox)

    final fillBody = Paint()..color = bodyColor..style = PaintingStyle.fill;
    final strokeBorder = Paint()..color = borderColor..strokeWidth = 2 * s..style = PaintingStyle.stroke;
    final fillVisor = Paint()..color = visorColor..style = PaintingStyle.fill;
    final fillEye = Paint()..color = eyeColor..style = PaintingStyle.fill;
    final fillCheek = Paint()..color = cheekColor..style = PaintingStyle.fill;

    // Antenna
    canvas.drawLine(Offset(200 * s, 92 * s), Offset(200 * s, 60 * s), strokeBorder..strokeWidth = 3 * s);
    canvas.drawCircle(Offset(200 * s, 56 * s), 8 * s, Paint()..color = visorColor);

    // Head
    final head = RRect.fromRectAndRadius(
      Rect.fromLTWH(120 * s, 100 * s, 160 * s, 130 * s),
      Radius.circular(40 * s),
    );
    canvas.drawRRect(head, fillBody);
    canvas.drawRRect(head, strokeBorder..strokeWidth = 2 * s);

    // Visor
    final visor = RRect.fromRectAndRadius(
      Rect.fromLTWH(138 * s, 128 * s, 124 * s, 64 * s),
      Radius.circular(22 * s),
    );
    canvas.drawRRect(visor, fillVisor);

    // Eyes (clignement par scaleY)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(170 * s, 160 * s), width: 16 * s, height: 20 * s * eyeOpenness),
      fillEye,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(230 * s, 160 * s), width: 16 * s, height: 20 * s * eyeOpenness),
      fillEye,
    );

    // Smile
    final smile = Path()
      ..moveTo(180 * s, 178 * s)
      ..quadraticBezierTo(200 * s, 188 * s, 220 * s, 178 * s);
    canvas.drawPath(smile, Paint()
      ..color = eyeColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.round);

    // Cheek lights
    canvas.drawCircle(Offset(142 * s, 208 * s), 4 * s, fillCheek);
    canvas.drawCircle(Offset(258 * s, 208 * s), 4 * s, fillCheek);

    // Neck
    canvas.drawRect(Rect.fromLTWH(180 * s, 230 * s, 40 * s, 14 * s), Paint()..color = borderColor);

    // Body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(100 * s, 244 * s, 200 * s, 110 * s),
      Radius.circular(24 * s),
    );
    canvas.drawRRect(body, fillBody);
    canvas.drawRRect(body, strokeBorder);

    // Chest SMS bubble
    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(160 * s, 268 * s, 80 * s, 56 * s),
      Radius.circular(14 * s),
    );
    canvas.drawRRect(bubble, Paint()..color = visorColor.withValues(alpha: 0.15));
    canvas.drawRRect(bubble, Paint()
      ..color = visorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s);
    // Three dots
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset((182 + i * 18) * s, 296 * s),
        3 * s,
        Paint()..color = visorColor,
      );
    }

    // Status LEDs
    final leds = [KlarisColors.success, KlarisColors.warning, KlarisColors.info];
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset((120 + i * 12) * s, 262 * s),
        3 * s,
        Paint()..color = leds[i].withValues(alpha: 0.9),
      );
    }

    // Floor shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(200 * s, 370 * s), width: 140 * s, height: 12 * s),
      Paint()..color = const Color(0x26000000),
    );
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) => old.eyeOpenness != eyeOpenness;
}
