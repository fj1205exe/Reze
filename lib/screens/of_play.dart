import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/overfitting.dart' as of_utils;

class OFPlayScreen extends StatelessWidget {
  final int degree;
  final ValueChanged<int> onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OFPlayScreen({
    super.key,
    required this.degree,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final coeffs = of_utils.fitPolynomial(of_utils.trainPoints, degree);
    final curvePoints = of_utils.sampleOFCurve(coeffs, 90);
    final trainMSE = of_utils.calcPolyMSE(coeffs, of_utils.trainPoints);

    final unlocked = degree >= 3;

    String degreeLabel() {
      if (degree == 1) return 'Straight line';
      if (degree == 2) return 'Quadratic';
      if (degree == 3) return 'Cubic';
      return 'Degree $degree';
    }

    final curveColor = degree <= 2 ? C.blue : (degree <= 4 ? C.accent : C.pink);

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
                  _backBtn(onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MODELS', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Overfitting', style: spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                      ],
                    ),
                  ),
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Stack(
                  children: [
                    Positioned(top: 12, left: 12, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: curveColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: curveColor.withValues(alpha: 0.35)),
                      ),
                      child: Text(degreeLabel(), style: spaceGrotesk(fontSize: 11, color: curveColor, fontWeight: FontWeight.w600)),
                    )),
                    Positioned(bottom: 12, left: 12, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('train MSE', style: inter(fontSize: 11, color: C.muted)),
                        Text(trainMSE.toStringAsFixed(4), style: mono(fontSize: 14, color: C.accentLight)),
                      ],
                    )),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CustomPaint(
                          painter: _OFPlayPainter(
                            coeffs: coeffs,
                            curvePoints: curvePoints,
                            degree: degree,
                          ),
                        ),
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Polynomial degree', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('$degree', style: mono(fontSize: 13, color: curveColor)),
                    ],
                  ),
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
                      max: of_utils.maxDegree.toDouble(),
                      divisions: of_utils.maxDegree - 1,
                      onChanged: (v) => onUpdate(v.round()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('simple', style: inter(fontSize: 11, color: C.muted)),
                      Text('complex', style: inter(fontSize: 11, color: C.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                if (degree >= 5)
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: C.pink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.pink.withValues(alpha: 0.3)),
                      ),
                      child: Text('The curve bends wildly to fit every point. Will it generalize?',
                        style: inter(fontSize: 14, color: C.pink), textAlign: TextAlign.center),
                    ),
                  )
                else if (degree >= 3)
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 450),
                    slideDistance: 16,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: C.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text('The curve bends to fit every point. Is that always better?',
                        style: inter(fontSize: 14, color: C.accentLight), textAlign: TextAlign.center),
                    ),
                  ),
                if (unlocked)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 12,
                    child: SecondaryBtn(label: 'What happens with more flexibility? →', onPressed: onNext),
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
      decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
    ),
  );
}

class _OFPlayPainter extends CustomPainter {
  final List<double> coeffs;
  final List<Map<String, double>> curvePoints;
  final int degree;

  _OFPlayPainter({
    required this.coeffs,
    required this.curvePoints,
    required this.degree,
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
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(padL, padT + ih * f), Offset(padL + iw, padT + ih * f), gridPaint);
    }

    // Clip curve inside plot rect
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(padL, padT - 2, iw, ih + 4));

    // Fitted curve
    final curveColor = degree == 1 ? C.blue : (degree <= 4 ? C.accent : C.pink);
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
        ..strokeWidth = 2.5,
    );
    canvas.restore();

    // Train points (white circles)
    for (final pt in of_utils.trainPoints) {
      canvas.drawCircle(
        Offset(toX(pt.x), toY(pt.y)),
        5,
        Paint()..color = Colors.white,
      );
    }

    // Axis labels
    _drawText(canvas, 'y', Offset(padL + 2, padT + 2), 8, Colors.grey.withValues(alpha: 0.4));
    _drawText(canvas, 'x', Offset(padL + iw - 8, padT + ih - 10), 8, Colors.grey.withValues(alpha: 0.4));
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'JetBrains Mono'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_OFPlayPainter old) => degree != old.degree;
}
