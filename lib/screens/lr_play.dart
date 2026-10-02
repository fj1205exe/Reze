import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/lr.dart' as lr;

class LRPlayScreen extends StatefulWidget {
  final double slope;
  final double intercept;
  final int steps;
  final void Function(double slope, double intercept) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LRPlayScreen({
    super.key,
    required this.slope,
    required this.intercept,
    required this.steps,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LRPlayScreen> createState() => _LRPlayScreenState();
}

class _LRPlayScreenState extends State<LRPlayScreen> {
  int _interactions = 0;

  void _handleSliderUpdate(double slope, double intercept) {
    setState(() => _interactions++);
    widget.onUpdate(slope, intercept);
  }

  @override
  Widget build(BuildContext context) {
    final mse = lr.calcMSE(widget.slope, widget.intercept);
    final goodFit = lr.isGoodFit(widget.slope, widget.intercept);
    final unlocked = _interactions >= 5;

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
                  _backBtn(widget.onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('REGRESSION',
                            style: spaceGrotesk(
                                fontSize: 10,
                                color: C.muted,
                                letterSpacing: 0.12)),
                        Text('Linear Regression',
                            style: spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.01)),
                      ],
                    ),
                  ),
                  StepCounter(steps: _interactions),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: goodFit
                      ? C.green.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('MSE', style: inter(fontSize: 12, color: C.muted)),
                        Text(mse.toStringAsFixed(4),
                            style: mono(
                                fontSize: 18,
                                color: goodFit ? C.green : C.accentLight)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: AspectRatio(
                      aspectRatio: 350 / 200,
                      child: CustomPaint(
                        painter: LRScatterPainter(
                          slope: widget.slope,
                          intercept: widget.intercept,
                          goodFit: goodFit,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Slope', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text('m = ${widget.slope.toStringAsFixed(2)}', style: mono(fontSize: 13, color: C.accentLight)),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                            value: widget.slope.clamp(-1.0, 2.0),
                            min: -1,
                            max: 2,
                            onChanged: (v) => _handleSliderUpdate(v, widget.intercept),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Intercept', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text('b = ${widget.intercept.toStringAsFixed(2)}', style: mono(fontSize: 13, color: C.blue)),
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
                            value: widget.intercept.clamp(-0.3, 1.2),
                            min: -0.3,
                            max: 1.2,
                            onChanged: (v) => _handleSliderUpdate(widget.slope, v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (goodFit)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: C.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.green.withValues(alpha: 0.3)),
                      ),
                      child: Text('Good fit! The line matches the data.',
                          style: inter(fontSize: 14, color: C.green),
                          textAlign: TextAlign.center),
                    ),
                  if (unlocked || goodFit)
                    SecondaryBtn(
                        label: 'Try fitting it yourself →',
                        onPressed: widget.onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _backBtn(VoidCallback onBack) {
  return GestureDetector(
    onTap: onBack,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          color: C.surface2, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
    ),
  );
}

class LRScatterPainter extends CustomPainter {
  final double slope;
  final double intercept;
  final bool goodFit;

  LRScatterPainter({
    required this.slope,
    required this.intercept,
    required this.goodFit,
  });

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

    // Background rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(padL, padT, iw, ih), const Radius.circular(2)),
      Paint()..color = const Color(0xFF1B1F26).withValues(alpha: 0.4),
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(padL, padT + ih * f),
          Offset(padL + iw, padT + ih * f), gridPaint);
    }

    // Residual lines (dashed)
    for (final pt in lr.dataPoints) {
      final px = xOf(pt.x);
      final py = yOf(pt.y);
      final pred = slope * pt.x + intercept;
      final predY = yOf(pred);
      final dashPaint = Paint()
        ..color = C.pink.withValues(alpha: 0.5)
        ..strokeWidth = 1;
      _drawDashedLine(canvas, Offset(px, py), Offset(px, predY), dashPaint, 2, 2);
    }

    // Regression line
    final x1 = xOf(0);
    final y1 = (yOf(intercept)).clamp(0.0, h);
    final x2 = xOf(1);
    final y2 = (yOf(slope + intercept)).clamp(0.0, h);
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = C.accent
        ..strokeWidth = 2.5,
    );

    // OLS optimal line (faint dashed)
    final olsY1 = yOf(lr.olsIntercept);
    final olsY2 = yOf(lr.olsSlope + lr.olsIntercept);
    _drawDashedLine(
      canvas,
      Offset(xOf(0), olsY1),
      Offset(xOf(1), olsY2),
      Paint()
        ..color = C.green.withValues(alpha: 0.18)
        ..strokeWidth = 1,
      4,
      6,
    );

    // Data points
    for (final pt in lr.dataPoints) {
      canvas.drawCircle(
        Offset(xOf(pt.x), yOf(pt.y)),
        5,
        Paint()..color = C.txt,
      );
    }

    // Axis labels
    _drawText(canvas, 'y', Offset(padL + 2, padT + 4), 8,
        Colors.grey.withValues(alpha: 0.5));
    _drawText(canvas, 'x', Offset(padL + iw - 10, padT + ih - 14), 8,
        Colors.grey.withValues(alpha: 0.5));
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint, double dash, double gap) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    final unitX = dx / dist;
    final unitY = dy / dist;
    double d = 0;
    while (d < dist) {
      final s = Offset(start.dx + unitX * d, start.dy + unitY * d);
      final e = Offset(
        start.dx + unitX * min(d + dash, dist),
        start.dy + unitY * min(d + dash, dist),
      );
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  void _drawText(
      Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: color, fontSize: fontSize, fontFamily: 'JetBrains Mono'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(LRScatterPainter old) =>
      slope != old.slope || intercept != old.intercept || goodFit != old.goodFit;
}
