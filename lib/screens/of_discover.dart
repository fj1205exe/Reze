import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/overfitting.dart' as of_utils;

class OFDiscoverScreen extends StatefulWidget {
  final int degree;
  final int steps;
  final ValueChanged<int> onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OFDiscoverScreen({
    super.key,
    required this.degree,
    required this.steps,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OFDiscoverScreen> createState() => _OFDiscoverScreenState();
}

class _OFDiscoverScreenState extends State<OFDiscoverScreen> {
  int _discoverSteps = 0;

  String get _feedbackType {
    final d = widget.degree;
    if (d == 1) return 'info';
    if (d >= 2 && d <= 4) return 'ok';
    return 'warn';
  }

  String get _feedbackMsg {
    final d = widget.degree;
    if (d == 1) return 'Low degree = high bias (underfitting)';
    if (d >= 2 && d <= 4) return 'Sweet spot: lowest test error';
    if (d >= 5 && d <= 8) return 'High degree = high variance (overfitting)';
    return 'The gap between train and test error is the generalization gap';
  }

  void _handleDegreeChange(int newDegree) {
    if (newDegree != widget.degree) {
      setState(() => _discoverSteps++);
      widget.onUpdate(newDegree);
    }
  }

  @override
  Widget build(BuildContext context) {
    final degree = widget.degree;
    final coeffs = of_utils.fitPolynomial(of_utils.trainPoints, degree);
    final curvePoints = of_utils.sampleOFCurve(coeffs, 90);
    final trainMSE = of_utils.calcPolyMSE(coeffs, of_utils.trainPoints);
    final testMSE = of_utils.calcPolyMSE(coeffs, of_utils.testPoints);

    final isOverfit = degree >= 5;
    final isGood = degree >= 2 && degree <= 4;
    final curveColor = degree == 1 ? C.blue : (isGood ? C.green : C.pink);

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
                        Text('OVERFITTING', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Explore model complexity.', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  StepCounter(steps: widget.steps),
                ],
              ),
            ),
          ),
          // Plot
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOverfit
                      ? C.pink.withValues(alpha: 0.3)
                      : isGood
                          ? C.green.withValues(alpha: 0.25)
                          : C.border,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: 12, left: 12, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('degree', style: inter(fontSize: 12, color: C.muted)),
                      Text('$degree', style: mono(fontSize: 17, color: C.purple, fontWeight: FontWeight.w700)),
                    ],
                  )),
                  Positioned(top: 12, right: 12, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14171C).withValues(alpha: 0.9),
                      borderRadius: S.borderSm,
                      border: Border.all(color: curveColor.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: curveColor)),
                        const SizedBox(width: 6),
                        Text(
                          degree == 1 ? 'underfitting' : (isGood ? 'good fit' : 'overfitting'),
                          style: inter(fontSize: 12, color: curveColor),
                        ),
                      ],
                    ),
                  )),
                  // Legend
                  Positioned(
                    bottom: 8, left: 14,
                    child: Row(
                      children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('train', style: inter(fontSize: 11, color: C.muted)),
                        const SizedBox(width: 12),
                        Transform.rotate(
                          angle: pi / 4,
                          child: Container(width: 7, height: 7, color: C.yellow),
                        ),
                        const SizedBox(width: 4),
                        Text('test', style: inter(fontSize: 11, color: C.muted)),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CustomPaint(
                        painter: _OFDiscoverPainter(
                          coeffs: coeffs,
                          curvePoints: curvePoints,
                          degree: degree,
                          curveColor: curveColor,
                        ),
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
                  // Train / Test MSE cards
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
                              Text('Train error', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(trainMSE.toStringAsFixed(4), style: mono(fontSize: 16, color: C.purple)),
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
                              Text('Test error', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(
                                testMSE.toStringAsFixed(4),
                                style: mono(fontSize: 16, color: isGood ? C.green : (isOverfit ? C.pink : C.blue)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Degree slider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Polynomial degree', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text('n = $degree', style: mono(fontSize: 14, color: C.purple)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('simple', style: inter(fontSize: 12, color: C.muted)),
                            Text('complex', style: inter(fontSize: 12, color: C.muted)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: curveColor,
                            inactiveTrackColor: C.surface3,
                            thumbColor: curveColor,
                            overlayColor: curveColor.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: degree.toDouble(),
                            min: 1,
                            max: 15,
                            divisions: 14,
                            onChanged: (v) => _handleDegreeChange(v.round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  FeedbackBar(type: _feedbackType, message: _feedbackMsg),
                  const SizedBox(height: 16),

                  if (_discoverSteps >= 5) ...[
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

class _OFDiscoverPainter extends CustomPainter {
  final List<double> coeffs;
  final List<Map<String, double>> curvePoints;
  final int degree;
  final Color curveColor;

  _OFDiscoverPainter({
    required this.coeffs,
    required this.curvePoints,
    required this.degree,
    required this.curveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const padL = 28.0;
    const padR = 14.0;
    const padT = 16.0;
    const padB = 24.0;
    final iw = w - padL - padR;
    final ih = h - padT - padB;

    double toX(double xNorm) => padL + xNorm * iw;
    double toY(double yNorm) => padT + (1 - yNorm) * ih;

    // Grid lines
    final gridPaint = Paint()..color = C.dim..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(padL, padT + ih * f), Offset(padL + iw, padT + ih * f), gridPaint);
    }

    // Clip curve
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(padL, padT - 2, iw, ih + 4));

    // Fitted curve
    final curvePath = Path();
    for (int i = 0; i < curvePoints.length; i++) {
      final px = toX(curvePoints[i]['x']!);
      final py = toY(curvePoints[i]['y']!);
      if (i == 0) {
        curvePath.moveTo(px, py);
      } else {
        curvePath.lineTo(px, py);
      }
    }
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = curveColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();

    // Test points (yellow diamonds) with residual dashed lines
    for (final pt in of_utils.testPoints) {
      final px = toX(pt.x);
      final py = toY(pt.y);
      final predY = toY(of_utils.evalPoly(pt.x, coeffs).clamp(-0.2, 1.2));

      // Dashed residual
      _drawDashedLine(
        canvas,
        Offset(px, py),
        Offset(px, predY.clamp(padT, padT + ih)),
        Paint()..color = C.yellow.withValues(alpha: 0.4)..strokeWidth = 1,
        2, 2,
      );

      // Diamond marker
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(pi / 4);
      canvas.drawRect(
        const Rect.fromLTWH(-3.5, -3.5, 7, 7),
        Paint()..color = C.yellow.withValues(alpha: 0.9),
      );
      canvas.restore();
    }

    // Train points (white circles)
    for (final pt in of_utils.trainPoints) {
      canvas.drawCircle(
        Offset(toX(pt.x), toY(pt.y)),
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dash, double gap) {
    final dy = end.dy - start.dy;
    final dist = dy.abs();
    if (dist < 1) return;
    final step = (dy > 0 ? 1.0 : -1.0);
    double d = 0;
    while (d < dist) {
      final y1 = start.dy + step * d;
      final y2 = start.dy + step * min(d + dash, dist);
      canvas.drawLine(Offset(start.dx, y1), Offset(start.dx, y2), paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_OFDiscoverPainter old) => degree != old.degree;
}
