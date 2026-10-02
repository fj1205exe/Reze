import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/lr.dart' as lr;

class _Term {
  final String sym;
  final Color color;
  final String label;
  final String desc;
  const _Term(this.sym, this.color, this.label, this.desc);
}

const _terms = [
  _Term('n', C.blue, 'Number of points', 'How many data points we have'),
  _Term('y', C.txt, 'Actual value', 'The real y value from the data'),
  _Term('ŷ', C.accentLight, 'Predicted value', 'What your line predicts at x'),
  _Term('y-ŷ', C.pink, 'Residual (error)', 'How far off the prediction is'),
  _Term('(y-ŷ)²', C.yellow, 'Squared error', "Squared so negatives don't cancel"),
];

class LRExplainScreen extends StatefulWidget {
  final double slope;
  final double intercept;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LRExplainScreen({
    super.key,
    required this.slope,
    required this.intercept,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LRExplainScreen> createState() => _LRExplainScreenState();
}

class _LRExplainScreenState extends State<LRExplainScreen> {
  String? _highlighted;

  @override
  Widget build(BuildContext context) {
    final mse = lr.calcMSE(widget.slope, widget.intercept);
    final optMSE = lr.calcMSE(lr.olsSlope, lr.olsIntercept);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Linear Regression', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discovery badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: C.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: C.green.withValues(alpha: 0.25)),
                    ),
                    child: Text('DISCOVERY',
                        style: spaceGrotesk(fontSize: 12, color: C.green)),
                  ),
                  const SizedBox(height: 12),
                  Text('You just minimized the error.',
                      style: spaceGrotesk(
                          fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                  const SizedBox(height: 8),
                  Text(
                    'Every adjustment you made changed the Mean Squared Error — the average of all squared residuals.',
                    style: inter(fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Mini visualization
                  Container(
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: AspectRatio(
                      aspectRatio: 350 / 200,
                      child: CustomPaint(
                        painter: _LRExplainPainter(
                          slope: widget.slope,
                          intercept: widget.intercept,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Equation card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('the formula',
                            style: spaceGrotesk(
                                fontSize: 12, color: C.muted, letterSpacing: 0.08)),
                        const SizedBox(height: 16),

                        // MSE equation
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: C.surface2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {}),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: mono(fontSize: 15, color: C.txt),
                                    children: [
                                      const TextSpan(text: 'MSE'),
                                      TextSpan(
                                          text: ' = ',
                                          style: mono(
                                              fontSize: 15,
                                              color: const Color(0xFF4B5563))),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () => setState(() => _highlighted =
                                              _highlighted == 'n' ? null : 'n'),
                                          child: Text('1/n',
                                              style: mono(
                                                  fontSize: 15,
                                                  color: _highlighted == 'n'
                                                      ? C.blue
                                                      : C.blue.withValues(alpha: 0.4))),
                                        ),
                                      ),
                                      TextSpan(
                                          text: ' · ',
                                          style: mono(
                                              fontSize: 15,
                                              color: const Color(0xFF4B5563))),
                                      TextSpan(
                                          text: 'Σ',
                                          style: mono(
                                              fontSize: 15,
                                              color: const Color(0xFF4B5563))),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () => setState(() => _highlighted =
                                              _highlighted == '(y-ŷ)²'
                                                  ? null
                                                  : '(y-ŷ)²'),
                                          child: Text(' (y − ŷ)²',
                                              style: mono(
                                                  fontSize: 15,
                                                  color: _highlighted == '(y-ŷ)²'
                                                      ? C.yellow
                                                      : C.yellow.withValues(alpha: 0.4))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Tap a term to learn what it means',
                                  style: inter(
                                      fontSize: 12,
                                      color: const Color(0xFF4B5563))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Your MSE vs Optimal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Your MSE', style: inter(fontSize: 14)),
                            Text(mse.toStringAsFixed(4),
                                style: mono(fontSize: 16, color: C.accentLight)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Optimal MSE', style: inter(fontSize: 14)),
                            Text(optMSE.toStringAsFixed(4),
                                style: mono(fontSize: 16, color: C.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Term cards
                  ..._terms.map((term) {
                    final isHl = _highlighted == term.sym;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _highlighted = _highlighted == term.sym ? null : term.sym),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isHl
                                ? term.color.withValues(alpha: 0.06)
                                : C.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isHl
                                  ? term.color.withValues(alpha: 0.19)
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: term.color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  term.sym.length > 2 ? '...' : term.sym,
                                  style: mono(fontSize: 14, color: term.color),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(term.label,
                                        style: spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(term.desc, style: inter(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  PrimaryBtn(label: 'TAKE THE CHALLENGE', onPressed: widget.onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LRExplainPainter extends CustomPainter {
  final double slope;
  final double intercept;

  _LRExplainPainter({required this.slope, required this.intercept});

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

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(padL, padT, iw, ih), const Radius.circular(2)),
      Paint()..color = const Color(0xFF1B1F26).withValues(alpha: 0.4),
    );

    // Residuals with squares
    for (final pt in lr.dataPoints) {
      final px = xOf(pt.x);
      final py = yOf(pt.y);
      final predY = yOf(slope * pt.x + intercept);
      // Residual line
      canvas.drawLine(
        Offset(px, py),
        Offset(px, predY),
        Paint()..color = C.pink.withValues(alpha: 0.6)..strokeWidth = 1.5,
      );
      // Squared error rectangle
      final side = (py - predY).abs();
      canvas.drawRect(
        Rect.fromLTWH(px - side / 2, min(py, predY), side, side),
        Paint()..color = C.pink.withValues(alpha: 0.07),
      );
    }

    // OLS optimal line (dashed)
    _drawDashedLine(
      canvas,
      Offset(xOf(0), yOf(lr.olsIntercept)),
      Offset(xOf(1), yOf(lr.olsSlope + lr.olsIntercept)),
      Paint()..color = C.green.withValues(alpha: 0.4)..strokeWidth = 1,
      4, 5,
    );

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

    // Labels
    _drawText(canvas, 'residuals (squared)', Offset(padL + 4, padT + 4), 8,
        C.pink.withValues(alpha: 0.7));
    final olsLabelX = xOf(0.65);
    final olsLabelY = yOf(lr.olsSlope * 0.65 + lr.olsIntercept) - 10;
    _drawText(canvas, 'optimal', Offset(olsLabelX, olsLabelY), 7,
        C.green.withValues(alpha: 0.5));
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint, double dash, double gap) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 1) return;
    final ux = dx / dist;
    final uy = dy / dist;
    double d = 0;
    while (d < dist) {
      final s = Offset(start.dx + ux * d, start.dy + uy * d);
      final e = Offset(
          start.dx + ux * min(d + dash, dist), start.dy + uy * min(d + dash, dist));
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  void _drawText(
      Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'Inter')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LRExplainPainter old) =>
      slope != old.slope || intercept != old.intercept;
}
