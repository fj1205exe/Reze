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
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LRChallengeScreen({
    super.key,
    required this.slope,
    required this.intercept,
    required this.steps,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LRChallengeScreen> createState() => _LRChallengeScreenState();
}

class _LRChallengeScreenState extends State<LRChallengeScreen> {
  late double _slope;
  late double _intercept;
  int _adjustments = 0;

  @override
  void initState() {
    super.initState();
    _slope = 0.2;
    _intercept = 0.1;
  }

  double get _mse => lr.calcMSE(_slope, _intercept);
  bool get _succeeded => _mse < _targetMSE;
  bool get _exhausted => _adjustments >= _maxSteps;

  String get _feedback {
    if (_succeeded) return 'Excellent fit! MSE is below the target.';
    if (_exhausted) return 'Out of adjustments. Try again!';
    final mse = _mse;
    if (mse > 0.3) return 'Way off — the line is far from the data.';
    if (mse > 0.15) return 'Getting closer. Adjust slope to match the trend.';
    if (mse > 0.08) return 'Almost there! Fine-tune the intercept.';
    return 'Very close! Small adjustments now.';
  }

  String get _feedbackType {
    if (_succeeded) return 'ok';
    if (_exhausted) return 'warn';
    if (_mse > 0.15) return 'warn';
    return 'info';
  }

  void _handleSlopeChange(double v) {
    setState(() {
      _slope = v;
    });
  }

  void _handleSlopeChangeEnd(double v) {
    setState(() {
      _slope = v;
      _adjustments++;
    });
    widget.onUpdate(v, _intercept);
  }

  void _handleInterceptChange(double v) {
    setState(() {
      _intercept = v;
    });
  }

  void _handleInterceptChangeEnd(double v) {
    setState(() {
      _intercept = v;
      _adjustments++;
    });
    widget.onUpdate(_slope, v);
  }

  @override
  Widget build(BuildContext context) {
    final done = _succeeded || _exhausted;

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
                  Text('Get MSE below ${_targetMSE.toStringAsFixed(2)} in $_maxSteps adjustments.',
                      style: inter(fontSize: 14, color: C.muted)),
                  const SizedBox(height: 12),

                  // Metrics row
                  Row(
                    children: [
                      StepCounter(steps: _adjustments, max: _maxSteps),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _succeeded
                              ? C.green.withValues(alpha: 0.12)
                              : C.surface,
                          borderRadius: S.borderSm,
                          border: Border.all(
                            color: _succeeded
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
                                    color: _succeeded ? C.green : C.accentLight)),
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

                  // Slope slider
                  if (!done)
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
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: _slope.clamp(-0.5, 2.0),
                              min: -0.5,
                              max: 2.0,
                              onChanged: _handleSlopeChange,
                              onChangeEnd: _handleSlopeChangeEnd,
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
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: _intercept.clamp(-0.5, 1.5),
                              min: -0.5,
                              max: 1.5,
                              onChanged: _handleInterceptChange,
                              onChangeEnd: _handleInterceptChangeEnd,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  if (done)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: PrimaryBtn(label: 'See results', onPressed: widget.onNext),
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
