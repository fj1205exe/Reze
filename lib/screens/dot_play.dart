import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/vectors.dart' as vec_utils;

class DOTPlayScreen extends StatefulWidget {
  final double angleA, angleB;
  final double magA, magB;
  final void Function(double aA, double aB, double mA, double mB) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DOTPlayScreen({
    super.key,
    required this.angleA,
    required this.angleB,
    this.magA = 1.0,
    this.magB = 1.0,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<DOTPlayScreen> createState() => _DOTPlayScreenState();
}

class _DOTPlayScreenState extends State<DOTPlayScreen> {
  int _moves = 0;

  void _handleUpdate({double? aA, double? aB}) {
    final nextAA = aA ?? widget.angleA;
    final nextAB = aB ?? widget.angleB;

    if (nextAA != widget.angleA || nextAB != widget.angleB) {
      setState(() => _moves++);
      widget.onUpdate(nextAA, nextAB, widget.magA, widget.magB);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fixed magnitudes at 1.0 (unit vectors)
    const magA = 1.0;
    const magB = 1.0;
    final aRad = widget.angleA * pi / 180;
    final bRad = widget.angleB * pi / 180;
    final ax = magA * cos(aRad);
    final ay = magA * sin(aRad);
    final bx = magB * cos(bRad);
    final by = magB * sin(bRad);
    final a = vec_utils.Vec2(ax, ay);
    final b = vec_utils.Vec2(bx, by);

    final dotVal = vec_utils.vecDot(a, b);
    final angleBetween = vec_utils.vecAngle(a, b);

    final unlocked = _moves >= 5;

    final regColor = dotVal.abs() < 0.15
        ? C.yellow
        : (dotVal > 0 ? C.green : C.pink);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'The Dot Product', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Measuring alignment.',
                      style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Adjust the angles and watch the dot product change.',
                      style: inter(fontSize: 14)),
                  const SizedBox(height: 16),

                  // Vector plane
                  Container(
                    height: 230,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: regColor.withValues(alpha: 0.3)),
                    ),
                    child: CustomPaint(
                      painter: _DotCanvasPainter(a: a, b: b, regColor: regColor),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Live calculation cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: S.borderMd,
                            border: Border.all(color: C.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dot product a · b', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(
                                dotVal.toStringAsFixed(3),
                                style: mono(fontSize: 16, fontWeight: FontWeight.w600, color: regColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: S.borderMd,
                            border: Border.all(color: C.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Angle between', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text('${angleBetween.round()}°', style: mono(fontSize: 16, color: C.txt)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Angle sliders
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vector a angle', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500, color: C.accentLight)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0°', style: inter(fontSize: 11, color: C.muted)),
                            Text('${widget.angleA.round()}°', style: mono(fontSize: 13, color: C.accentLight)),
                            Text('360°', style: inter(fontSize: 11, color: C.muted)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.accentLight,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.accentLight,
                            overlayColor: C.accentLight.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: widget.angleA,
                            min: 0,
                            max: 360,
                            onChanged: (v) => _handleUpdate(aA: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vector b angle', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500, color: C.blue)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0°', style: inter(fontSize: 11, color: C.muted)),
                            Text('${widget.angleB.round()}°', style: mono(fontSize: 13, color: C.blue)),
                            Text('360°', style: inter(fontSize: 11, color: C.muted)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.blue,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.blue,
                            overlayColor: C.blue.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: widget.angleB,
                            min: 0,
                            max: 360,
                            onChanged: (v) => _handleUpdate(aB: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_moves >= 5)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: C.accent.withValues(alpha: 0.1),
                          borderRadius: S.borderMd,
                          border: Border.all(color: C.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text('The dot product changes with angle. What else controls it?',
                          style: inter(fontSize: 14, color: C.accentLight), textAlign: TextAlign.center),
                      ),
                    ),

                  if (unlocked) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: SecondaryBtn(label: 'Discover what controls the dot product →', onPressed: widget.onNext),
                    ),
                  ] else ...[
                    PrimaryBtn(
                      label: 'Adjust sliders ${5 - _moves} more time${5 - _moves > 1 ? 's' : ''}',
                      disabled: true,
                      onPressed: null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotCanvasPainter extends CustomPainter {
  final vec_utils.Vec2 a, b;
  final Color regColor;

  _DotCanvasPainter({required this.a, required this.b, required this.regColor});

  @override
  void paint(Canvas canvas, Size size) {
    final ox = size.width / 2;
    final oy = size.height / 2;
    final scale = min(size.width, size.height) * 0.38;
    final origin = Offset(ox, oy);

    Offset toScreen(vec_utils.Vec2 v) => Offset(ox + v.x * scale, oy - v.y * scale);

    // Axes
    final axisPaint = Paint()..color = Colors.white.withValues(alpha: 0.1)..strokeWidth = 1;
    canvas.drawLine(Offset(0, oy), Offset(size.width, oy), axisPaint);
    canvas.drawLine(Offset(ox, 0), Offset(ox, size.height), axisPaint);

    // Unit circle
    canvas.drawCircle(
      origin,
      scale,
      Paint()
        ..color = C.dim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Projection line of a onto b
    final proj = vec_utils.vecProject(a, b);
    canvas.drawLine(
      toScreen(a),
      toScreen(proj),
      Paint()
        ..color = regColor.withValues(alpha: 0.4)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    // Vector B
    _drawArrow(canvas, origin, toScreen(b), C.blue);
    _drawText(canvas, 'b', toScreen(b) + const Offset(4, -8), C.blue);

    // Vector A
    _drawArrow(canvas, origin, toScreen(a), C.accentLight);
    _drawText(canvas, 'a', toScreen(a) + const Offset(4, -8), C.accentLight);

    // Center dot
    canvas.drawCircle(origin, 3, Paint()..color = Colors.white.withValues(alpha: 0.6));
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    canvas.drawLine(from, to, Paint()..color = color..strokeWidth = 2.5);

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final angle = atan2(dy, dx);
    const arrowLen = 9.0;
    const arrowAngle = pi / 6;

    final p1 = Offset(to.dx - arrowLen * cos(angle - arrowAngle), to.dy - arrowLen * sin(angle - arrowAngle));
    final p2 = Offset(to.dx - arrowLen * cos(angle + arrowAngle), to.dy - arrowLen * sin(angle + arrowAngle));

    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 11, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_DotCanvasPainter old) => a.x != old.a.x || a.y != old.a.y || b.x != old.b.x || b.y != old.b.y;
}
