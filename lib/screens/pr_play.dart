import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/probability.dart' as pr_utils;

class PRPlayScreen extends StatelessWidget {
  final double p;
  final List<String> flips;
  final VoidCallback onFlip;
  final void Function(int)? onFlipMany;
  final void Function(double)? onChangeP;
  final VoidCallback? onReset;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PRPlayScreen({
    super.key,
    this.p = 0.5,
    required this.flips,
    required this.onFlip,
    this.onFlipMany,
    this.onChangeP,
    this.onReset,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final n = flips.length;
    final h = pr_utils.countH(flips);
    final t = pr_utils.countT(flips);
    final running = pr_utils.runningProb(flips);
    final canAdvance = n >= 10;

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
                    onTap: onBack,
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
                        Text('PROBABILITY', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Flip a fair coin.', style: spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                      ],
                    ),
                  ),
                  StepCounter(steps: n),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tap flip and watch what happens.',
                      style: inter(fontSize: 14, color: const Color(0xFFD1D5DB))),
                  const SizedBox(height: 16),

                  // Running chart
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: CustomPaint(
                      painter: _PRChartPainter(
                        runningProbs: running,
                        trueP: p,
                        totalFlips: n,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Heads vs Tails stat cards
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
                              Text('Heads', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(
                                '$h',
                                style: mono(fontSize: 24, color: C.accentLight, fontWeight: FontWeight.w700),
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
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tails', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(
                                '$t',
                                style: mono(fontSize: 24, color: C.blue, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Recent flips row
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('recent flips', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        if (flips.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Text('Press flip to start', style: inter(fontSize: 12, color: C.muted)),
                            ),
                          )
                        else
                          SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: flips.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 6),
                              itemBuilder: (_, i) {
                                final f = flips[flips.length - 1 - i];
                                final isH = f == 'H';
                                return Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isH ? C.accent.withValues(alpha: 0.2) : C.blue.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isH ? C.accent : C.blue),
                                  ),
                                  child: Text(
                                    f,
                                    style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: isH ? C.accentLight : C.blue),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  PrimaryBtn(label: 'Flip', onPressed: onFlip),
                  if (canAdvance) ...[
                    const SizedBox(height: 12),
                    SecondaryBtn(label: 'What if the coin is biased? →', onPressed: onNext),
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

class _PRChartPainter extends CustomPainter {
  final List<double> runningProbs;
  final double trueP;
  final int totalFlips;

  _PRChartPainter({
    required this.runningProbs,
    required this.trueP,
    required this.totalFlips,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const padL = 36.0;
    const padR = 16.0;
    const padT = 16.0;
    const padB = 20.0;
    final iw = w - padL - padR;
    final ih = h - padT - padB;

    double toX(int idx) {
      final total = max(pr_utils.maxFlips, runningProbs.length);
      return padL + (idx / total) * iw;
    }

    double toY(double prob) => padT + (1.0 - prob) * ih;

    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 1;
    for (final v in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final y = toY(v);
      canvas.drawLine(Offset(padL, y), Offset(w - padR, y), gridPaint);
      _drawText(canvas, v.toStringAsFixed(2), Offset(padL - 28, y - 4), 8, Colors.grey.withValues(alpha: 0.5));
    }

    final trueY = toY(trueP);
    _drawDashedLine(
      canvas,
      Offset(padL, trueY),
      Offset(w - padR, trueY),
      Paint()..color = C.accentLight.withValues(alpha: 0.6)..strokeWidth = 1,
      4, 4,
    );
    _drawText(canvas, 'p=${trueP.toStringAsFixed(1)}', Offset(w - padR - 30, trueY - 12), 8, C.accentLight);

    if (runningProbs.isEmpty) {
      _drawCenterText(canvas, 'Flip coins to visualize convergence', Offset(w / 2, h / 2));
      return;
    }

    final path = Path();
    for (int i = 0; i < runningProbs.length; i++) {
      final x = toX(i);
      final y = toY(runningProbs[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = C.blue
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );

    final lastX = toX(runningProbs.length - 1);
    final lastY = toY(runningProbs.last);
    canvas.drawCircle(Offset(lastX, lastY), 3.5, Paint()..color = C.blue);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dash, double gap) {
    double d = start.dx;
    while (d < end.dx) {
      canvas.drawLine(Offset(d, start.dy), Offset(min(d + dash, end.dx), start.dy), paint);
      d += dash + gap;
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'JetBrains Mono')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawCenterText(Canvas canvas, String text, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: C.muted, fontSize: 12, fontFamily: 'Inter')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_PRChartPainter old) =>
      runningProbs.length != old.runningProbs.length || trueP != old.trueP;
}
