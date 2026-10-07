import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/vectors.dart' as vec_utils;

class DOTDiscoverScreen extends StatefulWidget {
  final double angleA, angleB, magA, magB;
  final int steps;
  final void Function(double aA, double aB, double mA, double mB) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DOTDiscoverScreen({
    super.key,
    required this.angleA,
    required this.angleB,
    required this.magA,
    required this.magB,
    required this.steps,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<DOTDiscoverScreen> createState() => _DOTDiscoverScreenState();
}

class _DOTDiscoverScreenState extends State<DOTDiscoverScreen> {
  int _discoverSteps = 0;

  String get _feedbackType {
    final aRad = widget.angleA * pi / 180;
    final bRad = widget.angleB * pi / 180;
    final ax = widget.magA * cos(aRad);
    final ay = widget.magA * sin(aRad);
    final bx = widget.magB * cos(bRad);
    final by = widget.magB * sin(bRad);
    final dotVal = ax * bx + ay * by;

    if (dotVal.abs() < 0.1) return 'ok';
    if (dotVal > 0.5) return 'info';
    if (dotVal < -0.5) return 'warn';
    return 'info';
  }

  String get _feedbackMsg {
    final aRad = widget.angleA * pi / 180;
    final bRad = widget.angleB * pi / 180;
    final ax = widget.magA * cos(aRad);
    final ay = widget.magA * sin(aRad);
    final bx = widget.magB * cos(bRad);
    final by = widget.magB * sin(bRad);
    final dotVal = ax * bx + ay * by;
    final angle = vec_utils.vecAngle(vec_utils.Vec2(ax, ay), vec_utils.Vec2(bx, by));

    if (dotVal.abs() < 0.1) return 'Perpendicular vectors → dot product ≈ 0. The angle is ${angle.round()}°.';
    if (dotVal > 0.5) return 'Parallel vectors → dot product = |a||b|. They point in similar directions.';
    if (dotVal < -0.5) return 'Opposite vectors → dot product = −|a||b|. They point away from each other.';
    return 'Dot product depends on both angle and magnitudes. Try changing both!';
  }

  void _handleUpdate({double? aA, double? aB, double? mA, double? mB}) {
    final nextAA = aA ?? widget.angleA;
    final nextAB = aB ?? widget.angleB;
    final nextMA = mA ?? widget.magA;
    final nextMB = mB ?? widget.magB;

    if (nextAA != widget.angleA || nextAB != widget.angleB || nextMA != widget.magA || nextMB != widget.magB) {
      setState(() => _discoverSteps++);
      widget.onUpdate(nextAA, nextAB, nextMA, nextMB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aRad = widget.angleA * pi / 180;
    final bRad = widget.angleB * pi / 180;
    final ax = widget.magA * cos(aRad);
    final ay = widget.magA * sin(aRad);
    final bx = widget.magB * cos(bRad);
    final by = widget.magB * sin(bRad);
    final a = vec_utils.Vec2(ax, ay);
    final b = vec_utils.Vec2(bx, by);

    final dotVal = vec_utils.vecDot(a, b);
    final angleBetween = vec_utils.vecAngle(a, b);
    final cosTheta = cos(angleBetween * pi / 180);

    final regColor = dotVal.abs() < 0.15
        ? C.yellow
        : (dotVal > 0 ? C.green : C.pink);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DOT PRODUCT', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Explore angle and magnitude.', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  StepCounter(steps: widget.steps),
                ],
              ),
            ),
          ),
          // Visualization
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: regColor.withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  Positioned(top: 12, left: 12, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('a · b', style: inter(fontSize: 12, color: C.muted)),
                      Text(dotVal.toStringAsFixed(3), style: mono(fontSize: 17, color: regColor, fontWeight: FontWeight.w700)),
                    ],
                  )),
                  Positioned(top: 12, right: 12, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14171C).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: regColor.withValues(alpha: 0.25)),
                    ),
                    child: Text('θ = ${angleBetween.round()}°', style: inter(fontSize: 12, color: regColor)),
                  )),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CustomPaint(
                        painter: _DOTDiscoverPainter(a: a, b: b, regColor: regColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  // Live stats
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('angle θ', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text('${angleBetween.round()}°', style: mono(fontSize: 16, color: C.yellow)),
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
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('cos(θ)', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(cosTheta.toStringAsFixed(3), style: mono(fontSize: 16, color: C.blue)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vector A controls
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vector a', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: C.accentLight)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('angle', style: inter(fontSize: 12, color: C.muted)),
                            Text('${widget.angleA.round()}°', style: mono(fontSize: 14, color: C.accentLight)),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('magnitude', style: inter(fontSize: 12, color: C.muted)),
                            Text('|a| = ${widget.magA.toStringAsFixed(2)}', style: mono(fontSize: 14, color: C.accentLight)),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                            value: widget.magA,
                            min: 0.2,
                            max: 1.5,
                            onChanged: (v) => _handleUpdate(mA: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Vector B controls
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vector b', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: C.blue)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('angle', style: inter(fontSize: 12, color: C.muted)),
                            Text('${widget.angleB.round()}°', style: mono(fontSize: 14, color: C.blue)),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('magnitude', style: inter(fontSize: 12, color: C.muted)),
                            Text('|b| = ${widget.magB.toStringAsFixed(2)}', style: mono(fontSize: 14, color: C.blue)),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                            value: widget.magB,
                            min: 0.2,
                            max: 1.5,
                            onChanged: (v) => _handleUpdate(mB: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  FeedbackBar(type: _feedbackType, message: _feedbackMsg),
                  const SizedBox(height: 16),

                  if (_discoverSteps >= 6) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: SecondaryBtn(label: 'I understand — show me the math →', onPressed: widget.onNext),
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

class _DOTDiscoverPainter extends CustomPainter {
  final vec_utils.Vec2 a, b;
  final Color regColor;

  _DOTDiscoverPainter({required this.a, required this.b, required this.regColor});

  @override
  void paint(Canvas canvas, Size size) {
    final ox = size.width / 2;
    final oy = size.height / 2;
    final scale = min(size.width, size.height) * 0.32;
    final origin = Offset(ox, oy);

    Offset toScreen(vec_utils.Vec2 v) => Offset(ox + v.x * scale, oy - v.y * scale);

    // Axes
    final axisPaint = Paint()..color = Colors.white.withValues(alpha: 0.08)..strokeWidth = 1;
    canvas.drawLine(Offset(0, oy), Offset(size.width, oy), axisPaint);
    canvas.drawLine(Offset(ox, 0), Offset(ox, size.height), axisPaint);

    // Unit circle
    canvas.drawCircle(
      origin,
      scale,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Projection of a onto b (dashed line)
    final proj = vec_utils.vecProject(a, b);
    _drawDashedLine(
      canvas,
      toScreen(a),
      toScreen(proj),
      Paint()..color = regColor.withValues(alpha: 0.5)..strokeWidth = 1.5,
      4, 3,
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

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dash, double gap) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    final ux = dx / dist;
    final uy = dy / dist;
    double d = 0;
    while (d < dist) {
      final p1 = Offset(start.dx + ux * d, start.dy + uy * d);
      final p2 = Offset(start.dx + ux * min(d + dash, dist), start.dy + uy * min(d + dash, dist));
      canvas.drawLine(p1, p2, paint);
      d += dash + gap;
    }
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
  bool shouldRepaint(_DOTDiscoverPainter old) => a.x != old.a.x || a.y != old.a.y || b.x != old.b.x || b.y != old.b.y;
}
