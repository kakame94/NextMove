import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

/// Cadastre Solitaire — entry animation.
///
/// Concentric rings, surveyor ticks, prospect dots by temperature, K center.
/// Shown once per cold launch on top of the app. Fades out at ~3.4s.
class CadastreSplashOverlay extends StatefulWidget {
  final Widget child;
  const CadastreSplashOverlay({super.key, required this.child});

  @override
  State<CadastreSplashOverlay> createState() => _CadastreSplashOverlayState();
}

class _CadastreSplashOverlayState extends State<CadastreSplashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          setState(() => _done = true);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_done)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final t = _c.value;
                  final fade = t < 0.88 ? 1.0 : (1.0 - (t - 0.88) / 0.12).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: fade,
                    child: CustomPaint(
                      painter: _CadastrePainter(t: t),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _CadastrePainter extends CustomPainter {
  final double t; // 0..1

  _CadastrePainter({required this.t});

  static const _bg = Color(0xFFF7F2E9);
  static const _ink = Color(0xFF2A2521);
  static const _inkSoft = Color(0xB32A2521);
  static const _primary = Color(0xFFC25A36);

  // Heat scale (matches PDF legend)
  static const _froid = Color(0xFF6A8FBF);
  static const _tiede = Color(0xFF93B1CC);
  static const _chaud = Color(0xFFD4A574);
  static const _treschaud = Color(0xFFD77A4A);
  static const _brulant = Color(0xFFC2533A);

  static const _dots = <_Dot>[
    _Dot('P-001', 160, 360, _froid, '18°'),
    _Dot('P-002', 640, 290, _froid, '24°'),
    _Dot('P-003', 610, 640, _tiede, '22°'),
    _Dot('P-004', 300, 740, _chaud, '31°'),
    _Dot('P-005', 200, 540, _chaud, '33°'),
    _Dot('P-006', 520, 360, _treschaud, '38°'),
    _Dot('P-007', 420, 340, _treschaud, '41°'),
    _Dot('P-008', 430, 620, _brulant, '47°'),
    _Dot('P-009', 368, 450, _brulant, '52°'),
    _Dot('P-010', 455, 455, _brulant, '58°'),
    _Dot('P-011', 440, 528, _brulant, '54°'),
    _Dot('P-012', 350, 548, _brulant, '49°'),
  ];

  double _phase(double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return ((t - start) / (end - start)).clamp(0.0, 1.0);
  }

  double _ease(double v) => 1 - math.pow(1 - v, 3).toDouble(); // easeOutCubic

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);

    // Fit a 800x900 design into available size (preserve aspect ratio).
    const dw = 800.0, dh = 900.0;
    final s = math.min(size.width / dw, size.height / dh);
    final ox = (size.width - dw * s) / 2;
    final oy = (size.height - dh * s) / 2;
    canvas.save();
    canvas.translate(ox, oy);
    canvas.scale(s);

    const cx = 400.0, cy = 480.0;
    final radii = [60.0, 130.0, 200.0, 270.0, 340.0];
    final ringOpacities = [0.75, 0.55, 0.40, 0.28, 0.20];

    // Title (Cadastre Solitaire)
    final titleOpacity = _ease(_phase(0.02, 0.18));
    _drawText(
      canvas,
      'CADASTRE  SOLITAIRE',
      const Offset(400, 130),
      fontSize: 30,
      letterSpacing: 6,
      color: _ink.withOpacity(titleOpacity),
      weight: FontWeight.w300,
      align: TextAlign.center,
    );
    _drawText(
      canvas,
      'TERRITOIRE  ·  KLARIS  ·  SOLO  ·  QUÉBEC',
      const Offset(400, 168),
      fontSize: 8,
      letterSpacing: 3,
      color: _primary.withOpacity(_ease(_phase(0.06, 0.22))),
      align: TextAlign.center,
    );

    // Coord top-left
    _drawText(
      canvas,
      '45°30′12″N · 73°33′48″O',
      const Offset(40, 40),
      fontSize: 9,
      letterSpacing: 1.5,
      color: _inkSoft.withOpacity(_ease(_phase(0.04, 0.18)) * 0.7),
      align: TextAlign.left,
      mono: true,
    );

    // Stamp top-right
    final stampOpacity = _ease(_phase(0.04, 0.20));
    if (stampOpacity > 0) {
      final stamp = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = _ink.withOpacity(0.5 * stampOpacity);
      canvas.drawRect(const Rect.fromLTWH(620, 30, 140, 60), stamp);
      _drawText(canvas, 'CADASTRE', const Offset(690, 48), fontSize: 8, letterSpacing: 2, color: _inkSoft.withOpacity(stampOpacity * 0.75), align: TextAlign.center, mono: true);
      _drawText(canvas, 'SOLITAIRE', const Offset(690, 62), fontSize: 8, letterSpacing: 2, color: _inkSoft.withOpacity(stampOpacity * 0.75), align: TextAlign.center, mono: true);
      _drawText(canvas, 'LEVÉ N° 2026', const Offset(690, 78), fontSize: 8, letterSpacing: 2, color: _primary.withOpacity(stampOpacity), align: TextAlign.center, mono: true, weight: FontWeight.w600);
    }

    // Cross axis
    final axisOpacity = _ease(_phase(0.06, 0.22)) * 0.4;
    if (axisOpacity > 0) {
      final axis = Paint()
        ..color = _ink.withOpacity(axisOpacity)
        ..strokeWidth = 0.6;
      canvas.drawLine(const Offset(400, 195), const Offset(400, 820), axis);
      canvas.drawLine(const Offset(55, 480), const Offset(745, 480), axis);
    }
    _drawText(canvas, 'FROID', const Offset(400, 210), fontSize: 7, letterSpacing: 2, color: _inkSoft.withOpacity(_ease(_phase(0.08, 0.22)) * 0.7), align: TextAlign.center, mono: true);
    _drawText(canvas, 'CHAUD', const Offset(400, 833), fontSize: 7, letterSpacing: 2, color: _inkSoft.withOpacity(_ease(_phase(0.08, 0.22)) * 0.7), align: TextAlign.center, mono: true);

    // Rings — staggered draw with arc sweep
    for (int i = 0; i < radii.length; i++) {
      final start = 0.12 + i * 0.045;
      final end = start + 0.30;
      final p = _ease(_phase(start, end));
      if (p <= 0) continue;
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = _primary.withOpacity(ringOpacities[i] * p);
      _drawDashedCircle(canvas, const Offset(cx, cy), radii[i], ringPaint, p);
    }

    // Compass ticks (32 around outer ring)
    const tickStart = 0.18;
    const tickStep = 0.012;
    final tickPaint = Paint()
      ..color = _ink.withOpacity(0.6)
      ..strokeWidth = 0.8;
    for (int i = 0; i < 32; i++) {
      final start = tickStart + i * tickStep;
      final p = _ease(_phase(start, start + 0.18));
      if (p <= 0) continue;
      final a = (i / 32) * math.pi * 2 - math.pi / 2;
      final x1 = cx + math.cos(a) * 345;
      final y1 = cy + math.sin(a) * 345;
      final x2 = cx + math.cos(a) * 362;
      final y2 = cy + math.sin(a) * 362;
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = tickPaint.color.withOpacity(0.5 * p)
          ..strokeWidth = 0.8,
      );
    }

    // Prospect dots — scatter in
    for (int i = 0; i < _dots.length; i++) {
      final d = _dots[i];
      final start = 0.38 + i * 0.02;
      final end = start + 0.18;
      final p = _ease(_phase(start, end));
      if (p <= 0) continue;
      final r = 4.5 * p;
      canvas.drawCircle(Offset(d.x, d.y), r, Paint()..color = d.color);
      if (p > 0.6) {
        _drawText(
          canvas,
          '${d.id} · ${d.temp}',
          Offset(d.x + 9, d.y - 8),
          fontSize: 6,
          letterSpacing: 0.6,
          color: _inkSoft.withOpacity(0.7 * ((p - 0.6) / 0.4)),
          align: TextAlign.left,
          mono: true,
        );
      }
    }

    // K logo center — scale spring
    final kP = _phase(0.50, 0.72);
    if (kP > 0) {
      final eased = _backOut(kP);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(eased);
      canvas.translate(-cx, -cy);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _primary;
      canvas.drawCircle(const Offset(cx, cy), 48, ring);
      final kStroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = _ink;
      canvas.drawLine(const Offset(385, 458), const Offset(385, 502), kStroke);
      canvas.drawLine(const Offset(385, 480), const Offset(412, 458), kStroke);
      canvas.drawLine(const Offset(385, 480), const Offset(412, 502), kStroke);
      canvas.drawCircle(const Offset(418, 461), 2.5, Paint()..color = _primary);
      canvas.restore();
    }

    // Tagline bottom-left
    final tagOpacity = _ease(_phase(0.70, 0.86));
    if (tagOpacity > 0) {
      _drawText(canvas, 'Où le silence', const Offset(40, 860), fontSize: 14, color: _inkSoft.withOpacity(tagOpacity), italic: true, align: TextAlign.left);
      _drawText(canvas, 'devient territoire.', const Offset(40, 882), fontSize: 14, color: _primary.withOpacity(tagOpacity), italic: true, align: TextAlign.left);
    }

    // Legend bottom-right
    final legendOpacity = _ease(_phase(0.74, 0.88));
    if (legendOpacity > 0) {
      const legend = [
        ['BRÛLANT · 50°+', _brulant],
        ['TRÈS CHAUD · 40°', _treschaud],
        ['CHAUD · 30°', _chaud],
        ['TIÈDE · 20°', _tiede],
        ['FROID · 10°', _froid],
      ];
      for (int i = 0; i < legend.length; i++) {
        final label = legend[i][0] as String;
        final color = legend[i][1] as Color;
        final y = 820.0 + i * 14;
        _drawText(canvas, label, Offset(720, y), fontSize: 7, letterSpacing: 1.2, color: _inkSoft.withOpacity(legendOpacity * 0.8), align: TextAlign.right, mono: true);
        canvas.drawCircle(Offset(732, y - 3), 3.5, Paint()..color = color.withOpacity(legendOpacity));
      }
    }

    canvas.restore();
  }

  double _backOut(double v) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final x = v - 1;
    return 1 + c3 * x * x * x + c1 * x * x;
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double r, Paint paint, double progress) {
    const dashCount = 80;
    final dashAngle = 2 * math.pi / dashCount;
    final visibleDashes = (dashCount * progress).floor();
    for (int i = 0; i < visibleDashes; i++) {
      final a1 = i * dashAngle;
      final a2 = a1 + dashAngle * 0.55;
      final path = Path()..addArc(Rect.fromCircle(center: center, radius: r), a1, a2 - a1);
      canvas.drawPath(path, paint);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    required double fontSize,
    required Color color,
    double letterSpacing = 0,
    TextAlign align = TextAlign.left,
    FontWeight weight = FontWeight.w400,
    bool italic = false,
    bool mono = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          letterSpacing: letterSpacing,
          fontWeight: weight,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamily: mono ? 'Menlo' : null,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 800);
    double dx = pos.dx;
    if (align == TextAlign.center) {
      dx = pos.dx - tp.width / 2;
    } else if (align == TextAlign.right) {
      dx = pos.dx - tp.width;
    }
    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_CadastrePainter old) => old.t != t;
}

class _Dot {
  final String id;
  final double x;
  final double y;
  final Color color;
  final String temp;
  const _Dot(this.id, this.x, this.y, this.color, this.temp);
}
