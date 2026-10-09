import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/vectors.dart' as vec_utils;

const _maxAttempts = 8;
const _targetTolerance = 0.05;

class DOTChallengeScreen extends StatefulWidget {
  final double angleA, angleB, magA, magB;
  final int steps;
  final void Function(double aA, double aB, double mA, double mB) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DOTChallengeScreen({
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
  State<DOTChallengeScreen> createState() => _DOTChallengeScreenState();
}

class _DOTChallengeScreenState extends State<DOTChallengeScreen> {
  bool _started = false;
  bool _finished = false;
  late double _angleB;

  @override
  void initState() {
    super.initState();
    _angleB = widget.angleB;
  }

  double get _currentDot {
    final aRad = widget.angleA * pi / 180;
    final bRad = _angleB * pi / 180;
    final ax = widget.magA * cos(aRad);
    final ay = widget.magA * sin(aRad);
    final bx = widget.magB * cos(bRad);
    final by = widget.magB * sin(bRad);
    return ax * bx + ay * by;
  }

  bool get _succeeded => _currentDot.abs() <= _targetTolerance;
  bool get _outOfAttempts => widget.steps >= _maxAttempts;
  bool get _done => _finished || (_outOfAttempts && !_succeeded) || _succeeded;

  String get _feedbackType {
    final dotVal = _currentDot;
    if (dotVal.abs() <= _targetTolerance) return 'ok';
    if (dotVal.abs() <= 0.15) return 'info';
    return 'warn';
  }

  String get _feedbackMsg {
    final dotVal = _currentDot;
    final absVal = dotVal.abs();
    if (absVal <= _targetTolerance) return 'Perfect! The vectors are perpendicular. Dot product ≈ 0.';
    if (absVal <= 0.15) return 'Very close! Adjust the angle slightly to reach zero.';
    if (dotVal > 0) return 'The vectors are too aligned. Try rotating b by 90° from a.';
    return 'The vectors are pointing away. Rotate b closer to perpendicular.';
  }

  void _onAngleBChanged(double v) {
    if (!_started) setState(() => _started = true);
    setState(() => _angleB = v);
  }

  void _onAngleBChangeEnd(double v) {
    if (_done) return;
    widget.onUpdate(widget.angleA, v, widget.magA, widget.magB);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_currentDot.abs() <= _targetTolerance || widget.steps >= _maxAttempts) {
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aRad = widget.angleA * pi / 180;
    final bRad = _angleB * pi / 180;
    final ax = widget.magA * cos(aRad);
    final ay = widget.magA * sin(aRad);
    final bx = widget.magB * cos(bRad);
    final by = widget.magB * sin(bRad);
    final a = vec_utils.Vec2(ax, ay);
    final b = vec_utils.Vec2(bx, by);
    final dotVal = _currentDot;
    final angleBetween = vec_utils.vecAngle(a, b);

    final regColor = dotVal.abs() <= _targetTolerance
        ? C.green
        : (dotVal.abs() <= 0.15 ? C.yellow : C.pink);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: S.headerPad,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.yellow.withValues(alpha: 0.25)),
                          ),
                          child: Text('CHALLENGE', style: spaceGrotesk(fontSize: 12, color: C.yellow)),
                        ),
                        const SizedBox(height: 4),
                        Text('Find perpendicular.',
                          style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  _attemptCounter(widget.steps),
                ],
              ),
            ),
          ),

          // Visualization
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _succeeded
                      ? C.green.withValues(alpha: 0.3)
                      : (_outOfAttempts && !_succeeded
                          ? C.pink.withValues(alpha: 0.2)
                          : C.border),
                ),
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
                  if (_started && !_done)
                    Positioned(top: 12, right: 12, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14171C).withValues(alpha: 0.9),
                        borderRadius: S.borderSm,
                        border: Border.all(color: C.yellow.withValues(alpha: 0.25)),
                      ),
                      child: Text('${_maxAttempts - widget.steps} left', style: mono(fontSize: 12, color: C.yellow)),
                    )),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CustomPaint(
                        painter: _DOTChallengePainter(a: a, b: b, regColor: regColor),
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
                  // Success / failure cards
                  if (_done && _succeeded)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: C.green.withValues(alpha: 0.1),
                          borderRadius: S.borderMd,
                          border: Border.all(color: C.green.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Perpendicular found in ${widget.steps} attempt${widget.steps == 1 ? '' : 's'}!',
                              style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: C.green)),
                            const SizedBox(height: 4),
                            Text('The angle between vectors is ${angleBetween.round()}°, close to 90°.',
                              style: inter(fontSize: 12, color: C.greenLight)),
                          ],
                        ),
                      ),
                    ),
                  if (_done && !_succeeded)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 14,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: C.pink.withValues(alpha: 0.08),
                          borderRadius: S.borderMd,
                          border: Border.all(color: C.pink.withValues(alpha: 0.25)),
                        ),
                        child: Text('Out of attempts. Hint: perpendicular vectors have θ = 90°.',
                          style: inter(fontSize: 14, color: C.pink)),
                      ),
                    ),

                  // Stats
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Dot product', style: inter(fontSize: 12, color: C.muted)),
                                  Text('target: 0', style: mono(fontSize: 10, color: C.yellow)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dotVal.toStringAsFixed(3),
                                style: mono(fontSize: 16, color: _succeeded ? C.green : regColor),
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
                              Text('Angle θ', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text('${angleBetween.round()}°', style: mono(fontSize: 16, color: C.yellow)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Angle slider for vector b
                  if (!_done)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: C.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rotate vector b', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: C.blue)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('angle', style: inter(fontSize: 12, color: C.muted)),
                              Text('${_angleB.round()}°', style: mono(fontSize: 14, color: C.blue)),
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
                            ),
                            child: Slider(
                              value: _angleB,
                              min: 0,
                              max: 360,
                              onChanged: _onAngleBChanged,
                              onChangeEnd: _onAngleBChangeEnd,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Feedback
                  if (_started && !_done)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 14,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FeedbackBar(type: _feedbackType, message: _feedbackMsg),
                      ),
                    ),

                  if (!_done && !_started)
                    PrimaryBtn(
                      label: 'Start',
                      onPressed: () => setState(() => _started = true),
                    )
                  else if (_done)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: widget.onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _succeeded ? C.green : C.accent,
                            foregroundColor: _succeeded ? C.bg : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: S.borderMd),
                            elevation: 0,
                          ),
                          child: Text('See results', style: spaceGrotesk(
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: _succeeded ? C.bg : Colors.white, letterSpacing: 0.05,
                          )),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attemptCounter(int steps) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: C.surface2,
        borderRadius: S.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Attempts ', style: inter(fontSize: 12, color: C.muted)),
          Text('$steps', style: mono(fontSize: 13, color: C.txt)),
          Text('/$_maxAttempts', style: mono(fontSize: 13, color: C.muted)),
        ],
      ),
    );
  }
}

class _DOTChallengePainter extends CustomPainter {
  final vec_utils.Vec2 a, b;
  final Color regColor;

  _DOTChallengePainter({required this.a, required this.b, required this.regColor});

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
        ..color = C.dim
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

    // Vector A (fixed)
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
  bool shouldRepaint(_DOTChallengePainter old) => a.x != old.a.x || a.y != old.a.y || b.x != old.b.x || b.y != old.b.y;
}
