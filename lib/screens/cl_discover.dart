import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/classification.dart' as cl_utils;

class CLDiscoverScreen extends StatefulWidget {
  final double angle;
  final double offset;
  final void Function(double a, double o) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CLDiscoverScreen({
    super.key,
    required this.angle,
    required this.offset,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CLDiscoverScreen> createState() => _CLDiscoverScreenState();
}

class _CLDiscoverScreenState extends State<CLDiscoverScreen> {
  late double _bestAccuracy;
  String? _feedbackType;
  String _feedbackMsg = '';

  @override
  void initState() {
    super.initState();
    _bestAccuracy = cl_utils.calcAccuracy(widget.angle, widget.offset);
    _updateFeedback(cl_utils.calcAccuracy(widget.angle, widget.offset));
  }

  void _handleUpdate(double a, double o) {
    widget.onUpdate(a, o);
    final acc = cl_utils.calcAccuracy(a, o);
    setState(() {
      _bestAccuracy = max(_bestAccuracy, acc);
      _updateFeedback(acc);
    });
  }

  void _updateFeedback(double accuracy) {
    if (accuracy >= 90) {
      _feedbackType = 'ok';
      _feedbackMsg = 'Excellent! The boundary separates most points.';
    } else if (accuracy >= 80) {
      _feedbackType = 'info';
      _feedbackMsg = 'Good separation! Can you get above 90%?';
    } else if (accuracy >= 60) {
      _feedbackType = 'info';
      _feedbackMsg = 'Getting better! Adjust the offset to fine-tune.';
    } else {
      _feedbackType = 'warn';
      _feedbackMsg = 'Try rotating the boundary to separate the classes.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = cl_utils.calcAccuracy(widget.angle, widget.offset);
    final isGood = accuracy >= 90.0;
    final cm = cl_utils.confusionMatrix(widget.angle, widget.offset);
    final unlocked = _bestAccuracy >= 80;

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
                        Text('CLASSIFICATION', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Find the best boundary.', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isGood
                      ? C.green.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: 12, left: 12, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accuracy', style: inter(fontSize: 12, color: C.muted)),
                      Text(
                        '${accuracy.round()}%',
                        style: mono(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isGood ? C.green : (accuracy >= 70 ? C.yellow : C.pink),
                        ),
                      ),
                    ],
                  )),
                  Positioned(top: 12, right: 12, child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('A', style: inter(fontSize: 11, color: C.muted)),
                      const SizedBox(width: 10),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('B', style: inter(fontSize: 11, color: C.muted)),
                    ],
                  )),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _CLPlotPainter(angle: widget.angle, offset: widget.offset),
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
                  // Confusion matrix
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confusion Matrix', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const SizedBox(width: 60),
                            Expanded(child: Text('Pred +', textAlign: TextAlign.center, style: inter(fontSize: 11, color: C.muted))),
                            Expanded(child: Text('Pred −', textAlign: TextAlign.center, style: inter(fontSize: 11, color: C.muted))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SizedBox(width: 60, child: Text('True +', style: inter(fontSize: 11, color: C.muted))),
                            Expanded(child: _cmCell('TP', cm['tp']!, C.green)),
                            const SizedBox(width: 4),
                            Expanded(child: _cmCell('FN', cm['fn']!, C.pink)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SizedBox(width: 60, child: Text('True −', style: inter(fontSize: 11, color: C.muted))),
                            Expanded(child: _cmCell('FP', cm['fp']!, C.pink)),
                            const SizedBox(width: 4),
                            Expanded(child: _cmCell('TN', cm['tn']!, C.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Angle slider
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Angle (w)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('${widget.angle.round()}', style: mono(fontSize: 13, color: C.accentLight)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.accent,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.accent,
                            overlayColor: C.accent.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: widget.angle,
                            min: -90,
                            max: 90,
                            onChanged: (v) => _handleUpdate(v, widget.offset),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Offset slider
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bias / Offset (b)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text(widget.offset.toStringAsFixed(2), style: mono(fontSize: 13, color: C.yellow)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.yellow,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.yellow,
                            overlayColor: C.yellow.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: widget.offset,
                            min: -0.5,
                            max: 0.5,
                            onChanged: (v) => _handleUpdate(widget.angle, v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_feedbackType != null)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FeedbackBar(type: _feedbackType!, message: _feedbackMsg),
                      ),
                    ),

                  if (unlocked)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: SecondaryBtn(label: 'I understand — show me the math →', onPressed: widget.onNext),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cmCell(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text('$count', style: mono(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: inter(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _CLPlotPainter extends CustomPainter {
  final double angle;
  final double offset;

  _CLPlotPainter({required this.angle, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const pad = 20.0;
    final iw = w - 2 * pad;
    final ih = h - 2 * pad;

    double toX(double xNorm) => pad + xNorm * iw;
    double toY(double yNorm) => h - pad - yNorm * ih;

    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final f = i / 4;
      canvas.drawLine(Offset(toX(f), pad), Offset(toX(f), h - pad), gridPaint);
      canvas.drawLine(Offset(pad, toY(f)), Offset(w - pad, toY(f)), gridPaint);
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(pad, pad, iw, ih));

    final theta = angle * pi / 180;
    final cosT = cos(theta);
    final sinT = sin(theta);
    double cxN, cyN;
    if (cosT.abs() > 1e-4) {
      cxN = 0.5;
      cyN = 0.5 + offset / cosT;
    } else {
      cxN = 0.5 + offset / sinT;
      cyN = 0.5;
    }
    final cxS = toX(cxN);
    final cyS = toY(cyN);
    const l = 500.0;

    canvas.drawLine(
      Offset(cxS - l * cosT, cyS + l * sinT),
      Offset(cxS + l * cosT, cyS - l * sinT),
      Paint()..color = Colors.white..strokeWidth = 2,
    );

    canvas.restore();

    for (final p in cl_utils.classA) {
      final isCorrect = cl_utils.classify(p.x, p.y, angle, offset) == 1;
      canvas.drawCircle(
        Offset(toX(p.x), toY(p.y)),
        5,
        Paint()..color = isCorrect ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6).withValues(alpha: 0.35),
      );
      if (!isCorrect) {
        canvas.drawCircle(Offset(toX(p.x), toY(p.y)), 6.5,
          Paint()..color = C.pink..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }

    for (final p in cl_utils.classB) {
      final isCorrect = cl_utils.classify(p.x, p.y, angle, offset) == -1;
      canvas.drawCircle(
        Offset(toX(p.x), toY(p.y)),
        5,
        Paint()..color = isCorrect ? const Color(0xFF38BDF8) : const Color(0xFF38BDF8).withValues(alpha: 0.35),
      );
      if (!isCorrect) {
        canvas.drawCircle(Offset(toX(p.x), toY(p.y)), 6.5,
          Paint()..color = C.pink..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }
  }

  @override
  bool shouldRepaint(_CLPlotPainter old) => angle != old.angle || offset != old.offset;
}
