import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/follow_up.dart';
import '../utils/vectors.dart' as vec_utils;

const _maxSteps = 6;

class VECChallengeScreen extends StatefulWidget {
  final double ax, ay;
  final double targetMag;
  final int steps;
  final void Function(double x, double y) onUpdateA;
  final void Function(bool success, int steps) onComplete;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const VECChallengeScreen({
    super.key,
    required this.ax,
    required this.ay,
    required this.targetMag,
    required this.steps,
    required this.onUpdateA,
    required this.onComplete,
    required this.onBack,
    required this.onRetry,
  });

  @override
  State<VECChallengeScreen> createState() => _VECChallengeScreenState();
}

class _VECChallengeScreenState extends State<VECChallengeScreen> {
  int _lockIns = 0;
  bool _hasSucceeded = false;
  bool _hasMoved = false;
  bool _followUpDone = false;
  late double _ax;
  late double _ay;

  @override
  void initState() {
    super.initState();
    _ax = widget.ax;
    _ay = widget.ay;
  }

  double get _currentMag => vec_utils.vecMagnitude(vec_utils.Vec2(_ax, _ay));
  double get _delta => (_currentMag - widget.targetMag).abs();
  bool get _magClose => _delta < 0.05;
  bool get _exhausted => _lockIns >= _maxSteps && !_hasSucceeded;
  bool get _done => _hasSucceeded || _exhausted;

  void _lockIn() {
    if (_done || !_hasMoved) return;
    setState(() {
      _lockIns++;
      _hasMoved = false;
      if (_magClose) _hasSucceeded = true;
    });
    widget.onUpdateA(_ax, _ay);
  }

  String get _feedbackMsg {
    if (_hasSucceeded) return 'Perfect!';
    if (_exhausted) return 'Out of lock-ins. Think about how x and y affect magnitude.';
    if (_delta < 0.3) return 'Close! Fine-tune it';
    if (_currentMag < widget.targetMag) return 'Too short — increase a component';
    return 'Too long — decrease a component';
  }

  String get _feedbackType {
    if (_hasSucceeded) return 'ok';
    if (_exhausted) return 'warn';
    if (_delta < 0.3) return 'info';
    return 'warn';
  }

  @override
  Widget build(BuildContext context) {
    final a = vec_utils.Vec2(_ax, _ay);

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
                        Text('Match the target magnitude.',
                          style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  StepCounter(steps: _lockIns, max: _maxSteps),
                ],
              ),
            ),
          ),

          // Canvas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: S.borderMd,
                border: Border.all(
                  color: _done && _hasSucceeded
                      ? C.green.withValues(alpha: 0.3)
                      : _done && !_hasSucceeded
                          ? C.pink.withValues(alpha: 0.2)
                          : C.border,
                ),
              ),
              child: CustomPaint(
                painter: _VectorChallengePainter(
                  a: a,
                  targetMag: widget.targetMag,
                  succeeded: _magClose,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                children: [
                  // Target & current display
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: S.borderMd,
                            border: Border.all(color: C.yellow.withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text('|a| = ${widget.targetMag.toStringAsFixed(2)}',
                                  style: mono(fontSize: 16, fontWeight: FontWeight.w600, color: C.yellow)),
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
                            border: Border.all(color: _hasSucceeded ? C.green.withValues(alpha: 0.3) : C.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text('|a| = ${_currentMag.toStringAsFixed(2)}',
                                  style: mono(fontSize: 16, fontWeight: FontWeight.w600, color: _hasSucceeded ? C.green : C.accentLight)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Delta bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderSm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Difference', style: inter(fontSize: 12, color: C.muted)),
                        Text('Δ = ${_delta.toStringAsFixed(3)}',
                            style: mono(fontSize: 13, color: _delta < 0.05 ? C.green : _delta < 0.3 ? C.yellow : C.pink)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Result banners
                  if (_done && _hasSucceeded)
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
                            Text('Target matched in $_lockIns lock-in${_lockIns == 1 ? '' : 's'}.',
                                style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: C.green)),
                            const SizedBox(height: 4),
                            Text('You understand magnitude.', style: inter(fontSize: 12, color: C.greenLight)),
                          ],
                        ),
                      ),
                    ),

                  if (_done && !_hasSucceeded)
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
                        child: Text('Ran out of adjustments. Think about how x and y components contribute to magnitude.',
                            style: inter(fontSize: 14, color: C.pink)),
                      ),
                    ),

                  if (!_done)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: S.borderMd,
                        border: Border.all(color: C.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adjust vector a', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: C.accentLight)),
                          const SizedBox(height: 8),
                          _buildSlider('x', _ax, -2.0, 2.0, C.accentLight, (v) => setState(() { _ax = v; _hasMoved = true; })),
                          _buildSlider('y', _ay, -2.0, 2.0, C.accentLight, (v) => setState(() { _ay = v; _hasMoved = true; })),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _hasMoved ? _lockIn : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: C.yellow,
                                disabledBackgroundColor: C.surface3,
                                foregroundColor: C.bg,
                                shape: RoundedRectangleBorder(borderRadius: S.borderSm),
                                elevation: 0,
                              ),
                              child: Text(
                                'LOCK IN  (${_maxSteps - _lockIns} left)',
                                style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600,
                                    color: _hasMoved ? C.bg : C.muted),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!_done)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: FeedbackBar(type: _feedbackType, message: _feedbackMsg),
                    ),

                  if (_hasSucceeded && !_followUpDone)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: FollowUpCard(
                        data: const FollowUpData(
                          question: 'If you double both x and y components of a vector, what happens to its magnitude?',
                          options: [
                            'It stays the same',
                            'It doubles',
                            'It quadruples',
                          ],
                          correctIndex: 1,
                          explanation: 'Magnitude = sqrt(x² + y²). Doubling both gives sqrt((2x)² + (2y)²) = 2·sqrt(x² + y²). Scaling components by k scales magnitude by k.',
                        ),
                        onDismiss: () => setState(() => _followUpDone = true),
                      ),
                    ),
                  if (_done && (_followUpDone || !_hasSucceeded))
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => widget.onComplete(_hasSucceeded, _lockIns),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasSucceeded ? C.green : C.accent,
                            foregroundColor: _hasSucceeded ? C.bg : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: S.borderMd),
                            elevation: 0,
                          ),
                          child: Text('See results', style: spaceGrotesk(
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: _hasSucceeded ? C.bg : Colors.white, letterSpacing: 0.05,
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

  Widget _buildSlider(String label, double val, double min, double max, Color color, ValueChanged<double> onChange) {
    return Row(
      children: [
        SizedBox(width: 14, child: Text(label, style: mono(fontSize: 12, color: C.muted))),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: C.surface3,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: val.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChange,
            ),
          ),
        ),
        SizedBox(width: 44, child: Text(val.toStringAsFixed(2), textAlign: TextAlign.right, style: mono(fontSize: 12, color: C.txt))),
      ],
    );
  }
}

class _VectorChallengePainter extends CustomPainter {
  final vec_utils.Vec2 a;
  final double targetMag;
  final bool succeeded;

  _VectorChallengePainter({
    required this.a,
    required this.targetMag,
    required this.succeeded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ox = size.width / 2;
    final oy = size.height / 2;
    final scale = min(size.width, size.height) * 0.28;
    final origin = Offset(ox, oy);

    Offset toScreen(vec_utils.Vec2 v) => Offset(ox + v.x * scale, oy - v.y * scale);

    // Axes
    final axisPaint = Paint()..color = Colors.white.withValues(alpha: 0.1)..strokeWidth = 1;
    canvas.drawLine(Offset(0, oy), Offset(size.width, oy), axisPaint);
    canvas.drawLine(Offset(ox, 0), Offset(ox, size.height), axisPaint);

    // Target magnitude circle (dashed)
    final targetRadius = targetMag * scale;
    _drawDashedCircle(canvas, origin, targetRadius, C.yellow.withValues(alpha: 0.5));

    // Current magnitude circle
    final currentMag = vec_utils.vecMagnitude(a);
    final currentRadius = currentMag * scale;
    canvas.drawCircle(
      origin,
      currentRadius,
      Paint()
        ..color = (succeeded ? C.green : C.accentLight).withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Vector A
    final tip = toScreen(a);
    canvas.drawLine(origin, tip, Paint()..color = (succeeded ? C.green : C.accentLight)..strokeWidth = 2.5);

    // Arrowhead
    final dx = tip.dx - origin.dx;
    final dy = tip.dy - origin.dy;
    final angle = atan2(dy, dx);
    const arrowLen = 9.0;
    const arrowAngle = pi / 6;
    final p1 = Offset(tip.dx - arrowLen * cos(angle - arrowAngle), tip.dy - arrowLen * sin(angle - arrowAngle));
    final p2 = Offset(tip.dx - arrowLen * cos(angle + arrowAngle), tip.dy - arrowLen * sin(angle + arrowAngle));
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = (succeeded ? C.green : C.accentLight)..style = PaintingStyle.fill);

    // Labels
    _drawText(canvas, 'a', tip + const Offset(4, -8), succeeded ? C.green : C.accentLight);
    _drawText(canvas, 'target', Offset(ox + targetRadius + 4, oy - 12), C.yellow);

    // Origin
    canvas.drawCircle(origin, 3, Paint()..color = Colors.white.withValues(alpha: 0.5));
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const segments = 40;
    for (var i = 0; i < segments; i += 2) {
      final startAngle = (i / segments) * 2 * pi;
      final sweepAngle = (1.0 / segments) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 11, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_VectorChallengePainter old) =>
      a.x != old.a.x || a.y != old.a.y || targetMag != old.targetMag || succeeded != old.succeeded;
}
