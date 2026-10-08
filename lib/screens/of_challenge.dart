import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/overfitting.dart' as of_utils;

const _maxAttempts = 5;

class OFChallengeScreen extends StatefulWidget {
  final int degree;
  final int steps;
  final ValueChanged<int> onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OFChallengeScreen({
    super.key,
    required this.degree,
    required this.steps,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OFChallengeScreen> createState() => _OFChallengeScreenState();
}

class _OFChallengeScreenState extends State<OFChallengeScreen> {
  bool _started = false;
  bool _finished = false;

  double get _targetMSE {
    final sweetCoeffs = of_utils.fitPolynomial(of_utils.trainPoints, of_utils.sweetSpot);
    return of_utils.calcPolyMSE(sweetCoeffs, of_utils.testPoints) * 1.5;
  }

  double get _currentTestMSE {
    final coeffs = of_utils.fitPolynomial(of_utils.trainPoints, widget.degree);
    return of_utils.calcPolyMSE(coeffs, of_utils.testPoints);
  }

  double get _currentTrainMSE {
    final coeffs = of_utils.fitPolynomial(of_utils.trainPoints, widget.degree);
    return of_utils.calcPolyMSE(coeffs, of_utils.trainPoints);
  }

  bool get _succeeded => _currentTestMSE <= _targetMSE;
  bool get _outOfAttempts => widget.steps >= _maxAttempts;
  bool get _done => _finished || (_outOfAttempts && !_succeeded) || _succeeded;

  String get _feedbackType {
    final trainMSE = _currentTrainMSE;
    final testMSE = _currentTestMSE;
    if (testMSE <= _targetMSE) return 'ok';
    if (trainMSE < 0.001 && testMSE > _targetMSE) return 'warn';
    if (trainMSE > 0.002 && testMSE > 0.003) return 'info';
    return 'info';
  }

  String get _feedbackMsg {
    final trainMSE = _currentTrainMSE;
    final testMSE = _currentTestMSE;
    if (testMSE <= _targetMSE) return 'Good generalization! The model balances bias and variance.';
    if (trainMSE < 0.001 && testMSE > _targetMSE) return 'Train error is low but test error is high — the model is overfitting.';
    if (trainMSE > 0.002 && testMSE > 0.003) return 'Both errors are high — the model is too simple (underfitting).';
    return '${_maxAttempts - widget.steps} attempts remaining. Find the degree with lowest test error.';
  }

  void _handleSelect(int d) {
    if (_done || !_started) return;
    if (d == widget.degree) return;
    widget.onUpdate(d);

    // Check if succeeded or ran out
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final coeffs = of_utils.fitPolynomial(of_utils.trainPoints, d);
      final testMSE = of_utils.calcPolyMSE(coeffs, of_utils.testPoints);
      if (testMSE <= _targetMSE || widget.steps >= _maxAttempts) {
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final degree = widget.degree;
    final coeffs = of_utils.fitPolynomial(of_utils.trainPoints, degree);
    final curvePoints = of_utils.sampleOFCurve(coeffs, 90);
    final trainMSE = of_utils.calcPolyMSE(coeffs, of_utils.trainPoints);
    final testMSE = of_utils.calcPolyMSE(coeffs, of_utils.testPoints);

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
                        Text('Find the best degree.',
                          style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  _attemptCounter(widget.steps),
                ],
              ),
            ),
          ),

          // Plot
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
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
                      Text('degree', style: inter(fontSize: 12, color: C.muted)),
                      Text('$degree', style: mono(fontSize: 17, color: C.purple, fontWeight: FontWeight.w700)),
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
                        painter: _OFChallengePainter(
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
                            Text('Best degree found in ${widget.steps} attempt${widget.steps == 1 ? '' : 's'}!',
                              style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: C.green)),
                            const SizedBox(height: 4),
                            Text('Degree $degree balances bias and variance.',
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
                        child: Text('Ran out of attempts. The sweet spot is usually between degree 2-4.',
                          style: inter(fontSize: 14, color: C.pink)),
                      ),
                    ),

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
                              Text('Train MSE', style: inter(fontSize: 12, color: C.muted)),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Test MSE', style: inter(fontSize: 12, color: C.muted)),
                                  Text('< ${_targetMSE.toStringAsFixed(4)}', style: mono(fontSize: 10, color: C.yellow)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                testMSE.toStringAsFixed(4),
                                style: mono(fontSize: 16, color: _succeeded ? C.green : (testMSE > _targetMSE * 2 ? C.pink : C.yellow)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Degree picker
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
                          Text('Pick a degree', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: List.generate(12, (i) {
                              final d = i + 1;
                              final isActive = d == degree;
                              return InkWell(
                                onTap: () => _handleSelect(d),
                                borderRadius: S.borderSm,
                                child: Container(
                                  width: 44,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? curveColor.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.03),
                                    borderRadius: S.borderSm,
                                    border: Border.all(
                                      color: isActive ? curveColor.withValues(alpha: 0.5) : Colors.transparent,
                                    ),
                                  ),
                                  child: Text(
                                    '$d',
                                    style: mono(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? curveColor : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              );
                            }),
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

class _OFChallengePainter extends CustomPainter {
  final List<double> coeffs;
  final List<Map<String, double>> curvePoints;
  final int degree;
  final Color curveColor;

  _OFChallengePainter({
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

    // Test points (yellow diamonds) with residuals
    for (final pt in of_utils.testPoints) {
      final px = toX(pt.x);
      final py = toY(pt.y);
      final predY = toY(of_utils.evalPoly(pt.x, coeffs).clamp(-0.2, 1.2));

      _drawDashedLine(
        canvas,
        Offset(px, py),
        Offset(px, predY.clamp(padT, padT + ih)),
        Paint()..color = C.yellow.withValues(alpha: 0.4)..strokeWidth = 1,
        2, 2,
      );

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(pi / 4);
      canvas.drawRect(
        const Rect.fromLTWH(-3.5, -3.5, 7, 7),
        Paint()..color = C.yellow.withValues(alpha: 0.9),
      );
      canvas.restore();
    }

    // Train points
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
  bool shouldRepaint(_OFChallengePainter old) => degree != old.degree;
}
