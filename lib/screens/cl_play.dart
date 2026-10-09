import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/classification.dart' as cl_utils;

class CLPlayScreen extends StatefulWidget {
  final double angle;
  final double offset;
  final void Function(double, double) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CLPlayScreen({
    super.key,
    required this.angle,
    this.offset = 0,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CLPlayScreen> createState() => _CLPlayScreenState();
}

class _CLPlayScreenState extends State<CLPlayScreen> {
  int _interactions = 0;

  void _handleAngleChange(double newAngle) {
    setState(() => _interactions++);
    widget.onUpdate(newAngle, widget.offset);
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = cl_utils.calcAccuracy(widget.angle, widget.offset);
    final isGood = accuracy >= 90.0;
    final unlocked = _interactions >= 4;

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
                  _backBtn(widget.onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CLASSIFICATION', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Rotate the boundary.', style: spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                      ],
                    ),
                  ),
                  StepCounter(steps: _interactions),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isGood
                        ? C.green.withValues(alpha: 0.3)
                        : C.border,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(top: 12, right: 12, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('accuracy', style: inter(fontSize: 12, color: C.muted)),
                        Text(
                          '${accuracy.round()}%',
                          style: mono(
                            fontSize: 18,
                            color: isGood ? C.green : (accuracy >= 70 ? C.yellow : C.pink),
                          ),
                        ),
                      ],
                    )),
                    Positioned(bottom: 12, right: 12, child: Row(
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
                      padding: const EdgeInsets.all(8),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _CLPlotPainter(angle: widget.angle, offset: widget.offset),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
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
                      Text('Angle', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('${widget.angle.round()}°', style: mono(fontSize: 13, color: C.accentLight)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: C.accent,
                      inactiveTrackColor: C.surface3,
                      thumbColor: C.accent,
                      overlayColor: C.accent.withValues(alpha: 0.15),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: widget.angle,
                      min: -90,
                      max: 90,
                      onChanged: _handleAngleChange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                if (isGood && _interactions > 0)
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 450),
                    slideDistance: 16,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: C.green.withValues(alpha: 0.1),
                        borderRadius: S.borderMd,
                        border: Border.all(color: C.green.withValues(alpha: 0.3)),
                      ),
                      child: Text('Great separation at this angle!', style: inter(fontSize: 14, color: C.green), textAlign: TextAlign.center),
                    ),
                  ),
                if (unlocked)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 12,
                    child: SecondaryBtn(label: 'Try fitting it precisely →', onPressed: widget.onNext),
                  ),
              ],
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
      width: 32, height: 32,
      decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
    ),
  );
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

    // Grid lines
    final gridPaint = Paint()..color = C.dim..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final f = i / 4;
      canvas.drawLine(Offset(toX(f), pad), Offset(toX(f), h - pad), gridPaint);
      canvas.drawLine(Offset(pad, toY(f)), Offset(w - pad, toY(f)), gridPaint);
    }

    // Clip to plot area
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(pad, pad, iw, ih));

    // Decision boundary line
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
    final x1 = cxS - l * cosT;
    final y1 = cyS + l * sinT;
    final x2 = cxS + l * cosT;
    final y2 = cyS - l * sinT;

    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()..color = Colors.white..strokeWidth = 2,
    );

    canvas.restore();

    // Data points - Class A (Purple)
    for (final p in cl_utils.classA) {
      final isCorrect = cl_utils.classify(p.x, p.y, angle, offset) == 1;
      canvas.drawCircle(
        Offset(toX(p.x), toY(p.y)),
        5,
        Paint()..color = isCorrect ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6).withValues(alpha: 0.35),
      );
      if (!isCorrect) {
        canvas.drawCircle(
          Offset(toX(p.x), toY(p.y)),
          6.5,
          Paint()..color = C.pink..style = PaintingStyle.stroke..strokeWidth = 1.5,
        );
      }
    }

    // Data points - Class B (Blue)
    for (final p in cl_utils.classB) {
      final isCorrect = cl_utils.classify(p.x, p.y, angle, offset) == -1;
      canvas.drawCircle(
        Offset(toX(p.x), toY(p.y)),
        5,
        Paint()..color = isCorrect ? const Color(0xFF38BDF8) : const Color(0xFF38BDF8).withValues(alpha: 0.35),
      );
      if (!isCorrect) {
        canvas.drawCircle(
          Offset(toX(p.x), toY(p.y)),
          6.5,
          Paint()..color = C.pink..style = PaintingStyle.stroke..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CLPlotPainter old) => angle != old.angle || offset != old.offset;
}
