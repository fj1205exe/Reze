import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/probability.dart' as pr_utils;

class PRDiscoverScreen extends StatefulWidget {
  final double p;
  final List<String> flips;
  final VoidCallback onFlip;
  final ValueChanged<int> onFlipMany;
  final ValueChanged<double> onChangeP;
  final VoidCallback onReset;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PRDiscoverScreen({
    super.key,
    required this.p,
    required this.flips,
    required this.onFlip,
    required this.onFlipMany,
    required this.onChangeP,
    required this.onReset,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PRDiscoverScreen> createState() => _PRDiscoverScreenState();
}

class _PRDiscoverScreenState extends State<PRDiscoverScreen> {
  bool _changedP = false;

  String get _feedbackMsg {
    final n = widget.flips.length;
    if (n < 10) return 'With few flips, anything can happen';
    if (n < 30) return 'More flips → proportion approaches true probability';
    if (n < 50) return 'This is the Law of Large Numbers';
    return 'Expected value = n × p = ${(n * widget.p).toStringAsFixed(1)}';
  }

  String get _feedbackType {
    final n = widget.flips.length;
    if (n < 10) return 'info';
    if (n < 50) return 'info';
    return 'ok';
  }

  bool get _canAdvance => widget.flips.length >= 50 && _changedP;

  void _handlePChange(double v) {
    setState(() => _changedP = true);
    widget.onReset();
    widget.onChangeP(v);
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.flips.length;
    final h = pr_utils.countH(widget.flips);
    final t = pr_utils.countT(widget.flips);
    final empP = pr_utils.empiricalP(widget.flips);
    final running = pr_utils.runningProb(widget.flips);

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
                        Text('PROBABILITY', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Explore biased coins.', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
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
              padding: S.screenPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Running chart
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: CustomPaint(
                      painter: _PRDiscoverChartPainter(
                        runningProbs: running,
                        trueP: widget.p,
                        totalFlips: n,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary stats row
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
                              Text('Empirical P(H)', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(
                                n == 0 ? '---' : '${(empP * 100).toStringAsFixed(1)}%',
                                style: mono(fontSize: 18, color: C.blue, fontWeight: FontWeight.w700),
                              ),
                              Text('$h H / $t T ($n total)', style: mono(fontSize: 10, color: C.muted)),
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
                              Text('True P(H)', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(
                                '${(widget.p * 100).toStringAsFixed(0)}%',
                                style: mono(fontSize: 18, color: C.accentLight, fontWeight: FontWeight.w700),
                              ),
                              Text('Expected: ${(widget.p * n).toStringAsFixed(1)} H', style: mono(fontSize: 10, color: C.muted)),
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
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('recent flips', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                            if (widget.flips.isNotEmpty)
                              InkWell(
                                onTap: widget.onReset,
                                child: Text('reset', style: mono(fontSize: 11, color: C.pink)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (widget.flips.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Text('Press flip to start generating samples', style: inter(fontSize: 12, color: C.muted)),
                            ),
                          )
                        else
                          SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.flips.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 6),
                              itemBuilder: (_, i) {
                                final f = widget.flips[widget.flips.length - 1 - i];
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
                  const SizedBox(height: 14),

                  // Probability slider
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
                            Text('Coin bias P(H)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text(widget.p.toStringAsFixed(2), style: mono(fontSize: 13, color: C.accentLight)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('always tails', style: inter(fontSize: 11, color: C.muted)),
                            Text('always heads', style: inter(fontSize: 11, color: C.muted)),
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
                            value: widget.p.clamp(0.0, 1.0),
                            min: 0.0,
                            max: 1.0,
                            onChanged: _handlePChange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Feedback bar
                  if (n > 0)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: FeedbackBar(type: _feedbackType, message: _feedbackMsg),
                      ),
                    ),

                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: widget.onFlip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: C.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text('Flip', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => widget.onFlipMany(10),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: C.txt,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('Flip 10', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => widget.onFlipMany(100),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: C.txt,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('Flip 100', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_canAdvance) ...[
                    const SizedBox(height: 16),
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

class _PRDiscoverChartPainter extends CustomPainter {
  final List<double> runningProbs;
  final double trueP;
  final int totalFlips;

  _PRDiscoverChartPainter({
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

    final gridPaint = Paint()..color = C.dim..strokeWidth = 1;
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
    _drawText(canvas, 'p', Offset(w - padR + 4, trueY - 4), 8, C.accentLight);

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
  bool shouldRepaint(_PRDiscoverChartPainter old) =>
      runningProbs.length != old.runningProbs.length || trueP != old.trueP;
}
