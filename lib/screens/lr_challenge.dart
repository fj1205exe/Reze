import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/lr.dart' as lr;

const _maxSteps = 10;
const _targetMSE = 0.05;

class LRChallengeScreen extends StatefulWidget {
  final double slope;
  final double intercept;
  final int steps;
  final void Function(double slope, double intercept) onUpdate;
  final void Function(bool success, int steps) onComplete;
  final VoidCallback onBack;

  const LRChallengeScreen({
    super.key,
    required this.slope,
    required this.intercept,
    required this.steps,
    required this.onUpdate,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<LRChallengeScreen> createState() => _LRChallengeScreenState();
}

class _LRChallengeScreenState extends State<LRChallengeScreen> {
  late double _slope;
  late double _intercept;
  int _lockIns = 0;
  bool _hasSucceeded = false;
  bool _hasMoved = false;

  @override
  void initState() {
    super.initState();
    _slope = 0.2;
    _intercept = 0.1;
  }

  double get _mse => lr.calcMSE(_slope, _intercept);
  bool get _exhausted => _lockIns >= _maxSteps && !_hasSucceeded;
  bool get _done => _hasSucceeded || _exhausted;

  String get _feedback {
    if (_hasSucceeded) return 'Excellent fit! MSE is below the target.';
    if (_exhausted) return 'Out of adjustments. Try again!';
    final mse = _mse;
    if (mse > 0.3) return 'Way off — the line is far from the data.';
    if (mse > 0.15) return 'Getting closer. Adjust slope to match the trend.';
    if (mse > 0.08) return 'Almost there! Fine-tune the intercept.';
    return 'Very close! Small adjustments now.';
  }

  String get _feedbackType {
    if (_hasSucceeded) return 'ok';
    if (_exhausted) return 'warn';
    if (_mse > 0.15) return 'warn';
    return 'info';
  }

  void _lockIn() {
    if (_done) return;
    setState(() {
      _lockIns++;
      _hasMoved = false;
      if (_mse < _targetMSE) _hasSucceeded = true;
    });
    widget.onUpdate(_slope, _intercept);
  }

  @override
  Widget build(BuildContext context) {
    final mseBelow = _mse < _targetMSE;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'LR Challenge', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fit the line.',
                      style: spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Get MSE below ${_targetMSE.toStringAsFixed(2)} in $_maxSteps lock-ins.',
                      style: inter(fontSize: 14, color: C.muted)),
                  const SizedBox(height: 12),

                  // Metrics row
                  Row(
                    children: [
                      StepCounter(steps: _lockIns, max: _maxSteps),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: mseBelow
                              ? C.green.withValues(alpha: 0.12)
                              : C.surface,
                          borderRadius: S.borderSm,
                          border: Border.all(
                            color: mseBelow
                                ? C.green.withValues(alpha: 0.3)
                                : C.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('MSE: ', style: inter(fontSize: 12, color: C.muted)),
                            Text(_mse.toStringAsFixed(4),
                                style: mono(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: mseBelow ? C.green : C.accentLight)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Target: < $_targetMSE',
                            style: mono(fontSize: 11, color: C.muted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Plot
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: CustomPaint(
                      painter: _ChallengePlotPainter(
                        slope: _slope,
                        intercept: _intercept,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  FeedbackBar(message: _feedback, type: _feedbackType),
                  const SizedBox(height: 14),

                  if (!_done)
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Slope (m)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: C.accentLight)),
                              Text(_slope.toStringAsFixed(3), style: mono(fontSize: 13, color: C.txt)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: C.accentLight,
                              inactiveTrackColor: C.surface3,
                              thumbColor: C.accentLight,
                              overlayColor: C.accentLight.withValues(alpha: 0.15),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _slope.clamp(-0.5, 2.0),
                              min: -0.5,
                              max: 2.0,
                              onChanged: (v) => setState(() { _slope = v; _hasMoved = true; }),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Intercept (b)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: C.blue)),
                              Text(_intercept.toStringAsFixed(3), style: mono(fontSize: 13, color: C.txt)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: C.blue,
                              inactiveTrackColor: C.surface3,
                              thumbColor: C.blue,
                              overlayColor: C.blue.withValues(alpha: 0.15),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _intercept.clamp(-0.5, 1.5),
                              min: -0.5,
                              max: 1.5,
                              onChanged: (v) => setState(() { _intercept = v; _hasMoved = true; }),
                            ),
                          ),
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
                  const SizedBox(height: 20),

                  if (_done)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: PrimaryBtn(label: 'See results', onPressed: () => widget.onComplete(_hasSucceeded, _lockIns)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengePlotPainter extends CustomPainter {
  final double slope, intercept;

  _ChallengePlotPainter({required this.slope, required this.intercept});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final padL = w * (lr.plotPad['l']! / lr.svgW);
    final padR = w * (lr.plotPad['r']! / lr.svgW);
    final padT = h * (lr.plotPad['t']! / lr.svgH);
    final padB = h * (lr.plotPad['b']! / lr.svgH);
    final iw = w - padL - padR;
    final ih = h - padT - padB;

    double xOf(double xNorm) => padL + xNorm * iw;
    double yOf(double yNorm) => padT + ih - yNorm * ih;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(padL, padT, iw, ih), const Radius.circular(2)),
      Paint()..color = const Color(0xFF1B1F26).withValues(alpha: 0.4),
    );

    // Residuals
    for (final pt in lr.dataPoints) {
      final px = xOf(pt.x);
      final py = yOf(pt.y);
      final predY = yOf(slope * pt.x + intercept);
      canvas.drawLine(
        Offset(px, py), Offset(px, predY),
        Paint()..color = C.pink.withValues(alpha: 0.5)..strokeWidth = 1.5,
      );
    }

    // Your line
    canvas.drawLine(
      Offset(xOf(0), yOf(intercept).clamp(0, h)),
      Offset(xOf(1), yOf(slope + intercept).clamp(0, h)),
      Paint()..color = C.accent..strokeWidth = 2,
    );

    // Data points
    for (final pt in lr.dataPoints) {
      canvas.drawCircle(Offset(xOf(pt.x), yOf(pt.y)), 4, Paint()..color = C.txt);
    }
  }

  @override
  bool shouldRepaint(_ChallengePlotPainter old) => slope != old.slope || intercept != old.intercept;
}
