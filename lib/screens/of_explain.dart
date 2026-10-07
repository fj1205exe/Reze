import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/overfitting.dart' as of_utils;

class OFExplainScreen extends StatefulWidget {
  final int degree;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OFExplainScreen({
    super.key,
    required this.degree,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OFExplainScreen> createState() => _OFExplainScreenState();
}

class _OFExplainScreenState extends State<OFExplainScreen> {
  late int _selectedDegree;
  String? _highlighted;

  static const _terms = [
    {'sym': 'B', 'color': 0xFF38BDF8, 'label': 'Bias', 'desc': 'The systematic error from overly simple assumptions'},
    {'sym': 'V', 'color': 0xFFFB7185, 'label': 'Variance', 'desc': 'Sensitivity to small fluctuations in training data'},
    {'sym': 'U', 'color': 0xFF38BDF8, 'label': 'Underfitting', 'desc': 'Model cannot capture the underlying pattern'},
    {'sym': 'O', 'color': 0xFFFB7185, 'label': 'Overfitting', 'desc': 'Model memorizes noise instead of learning signal'},
    {'sym': 'S', 'color': 0xFF4ADE80, 'label': 'Sweet spot', 'desc': 'Optimal tradeoff between bias and variance'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDegree = widget.degree <= 4 ? widget.degree : 3;
  }

  @override
  Widget build(BuildContext context) {
    final coeffs = of_utils.fitPolynomial(of_utils.trainPoints, _selectedDegree);
    final trainMSE = of_utils.calcPolyMSE(coeffs, of_utils.trainPoints);
    final testMSE = of_utils.calcPolyMSE(coeffs, of_utils.testPoints);

    final zone = _selectedDegree == 1
        ? 'under'
        : (_selectedDegree <= 4 ? 'good' : 'over');
    final zoneColor = zone == 'under'
        ? C.blue
        : (zone == 'good' ? C.green : C.pink);
    final zoneLabel = zone == 'under'
        ? 'Underfitting'
        : (zone == 'good' ? 'Good generalization' : 'Overfitting');

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'The Bias-Variance Tradeoff', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 450),
                    slideDistance: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: C.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.green.withValues(alpha: 0.25)),
                          ),
                          child: Text('DISCOVERY',
                              style: spaceGrotesk(fontSize: 11, color: C.green, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Text('The bias-variance tradeoff.',
                            style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          'Every model lives somewhere between two failure modes. Too simple — it misses the pattern entirely. Too complex — it memorizes the training data and fails on anything new.',
                          style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Plot card
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: zoneColor.withValues(alpha: 0.3)),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _OFExplainPainter(
                              coeffs: coeffs,
                              curvePoints: of_utils.sampleOFCurve(coeffs, 90),
                              zoneColor: zoneColor,
                            ),
                          ),
                        ),
                        // Degree switcher at bottom
                        Positioned(
                          bottom: 8,
                          left: 10,
                          right: 10,
                          child: Row(
                            children: [1, 3, 6].map((d) {
                              final isCur = _selectedDegree == d;
                              final z = d == 1 ? 'under' : (d <= 4 ? 'good' : 'over');
                              final c = z == 'under' ? C.blue : (z == 'good' ? C.green : C.pink);
                              final lbl = 'degree $d';
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedDegree = d),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isCur ? c.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isCur ? c.withValues(alpha: 0.4) : Colors.transparent),
                                      ),
                                      child: Text(
                                        lbl,
                                        style: spaceGrotesk(fontSize: 11, color: isCur ? c : const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 12),

                  // Current zone badge & errors
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: zoneColor, width: 2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(zoneLabel, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: zoneColor)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('train: ${trainMSE.toStringAsFixed(4)}', style: mono(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(width: 14),
                              Text('test: ${testMSE.toStringAsFixed(4)}', style: mono(fontSize: 12, color: const Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tradeoff formula -- interactive
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 280),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        children: [
                          Text('THE TRADEOFF', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                          const SizedBox(height: 16),
                          _equation(),
                          const SizedBox(height: 12),
                          Text('Tap a symbol to learn what it means.', style: inter(fontSize: 12, color: C.muted)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Term cards
                  for (final term in _terms) ...[
                    _termCard(term),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 8),
                  Text(
                    'You cannot reduce both at once. The goal is finding the sweet spot — just complex enough to fit the signal, not the noise.',
                    style: inter(fontSize: 12, color: const Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 350),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 12,
                    child: PrimaryBtn(label: 'TAKE THE CHALLENGE', onPressed: widget.onNext),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _equation() {
    final parts = [
      {'text': 'Error', 'term': null},
      {'text': ' = ', 'term': null},
      {'text': 'Bias²', 'term': 'B'},
      {'text': ' + ', 'term': null},
      {'text': 'Variance', 'term': 'V'},
      {'text': ' + ', 'term': null},
      {'text': 'noise', 'term': null},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        final termData = part['term'] != null
            ? _terms.firstWhere((t) => t['sym'] == part['term'], orElse: () => {})
            : null;
        final isHl = part['term'] == _highlighted;

        Color color;
        if (termData != null && termData.containsKey('color')) {
          color = Color(termData['color'] as int).withValues(alpha: isHl ? 1 : 0.6);
        } else if (part['text'] == 'noise') {
          color = const Color(0xFF6B7280);
        } else if (part['text'] == 'Error') {
          color = C.txt;
        } else {
          color = C.txt.withValues(alpha: 0.5);
        }

        return GestureDetector(
          onTap: part['term'] != null
              ? () => setState(() => _highlighted = _highlighted == part['term'] ? null : part['term'])
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isHl && termData != null ? Color(termData['color'] as int).withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              part['text'] as String,
              style: mono(
                fontSize: part['term'] != null ? 22 : 18,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _termCard(Map<String, dynamic> term) {
    final isHl = _highlighted == term['sym'];
    final color = Color(term['color'] as int);
    return GestureDetector(
      onTap: () => setState(() => _highlighted = _highlighted == term['sym'] ? null : term['sym'] as String?),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHl ? color.withValues(alpha: 0.06) : C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isHl ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Text(term['sym'] as String, style: mono(fontSize: 15, color: color)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(term['label'] as String, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(term['desc'] as String, style: inter(fontSize: 12, color: C.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OFExplainPainter extends CustomPainter {
  final List<double> coeffs;
  final List<Map<String, double>> curvePoints;
  final Color zoneColor;

  _OFExplainPainter({
    required this.coeffs,
    required this.curvePoints,
    required this.zoneColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const padL = 24.0;
    const padR = 14.0;
    const padT = 12.0;
    const padB = 44.0;
    final iw = w - padL - padR;
    final ih = h - padT - padB;

    double toX(double xNorm) => padL + xNorm * iw;
    double toY(double yNorm) => padT + (1 - yNorm) * ih;

    // Grid lines
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(padL, padT + ih * f), Offset(padL + iw, padT + ih * f), gridPaint);
    }

    // Clip curve
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(padL, padT - 2, iw, ih + 4));

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
        ..color = zoneColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();

    // Test points (yellow diamonds)
    for (final pt in of_utils.testPoints) {
      final px = toX(pt.x);
      final py = toY(pt.y);
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(pi / 4);
      canvas.drawRect(
        const Rect.fromLTWH(-3, -3, 6, 6),
        Paint()..color = C.yellow.withValues(alpha: 0.8),
      );
      canvas.restore();
    }

    // Train points (white circles)
    for (final pt in of_utils.trainPoints) {
      canvas.drawCircle(Offset(toX(pt.x), toY(pt.y)), 3.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_OFExplainPainter old) => zoneColor != old.zoneColor || coeffs != old.coeffs;
}
