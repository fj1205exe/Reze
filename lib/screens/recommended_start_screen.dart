import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class RecommendedStartScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const RecommendedStartScreen({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Recommended', onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your next concept', style: inter(fontSize: 14, color: C.muted)),
                        const SizedBox(height: 4),
                        Text('Gradient Descent', style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _tag('OPTIMIZATION', C.blue),
                            const SizedBox(width: 8),
                            _tag('∼ 10 min', C.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    duration: const Duration(milliseconds: 500),
                    slideDistance: 16,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: C.border),
                      ),
                      child: CustomPaint(painter: _PreviewPainter()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 450),
                    slideDistance: 14,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: S.borderMd,
                        border: Border.all(color: C.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Let's experiment with how learning rate changes movement.",
                            style: inter(fontSize: 14, color: C.txt)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text('Optimization ', style: inter(fontSize: 12, color: C.muted)),
                              Text('+8', style: mono(fontSize: 12, color: C.accent)),
                              const SizedBox(width: 16),
                              Text('Calculus ', style: inter(fontSize: 12, color: C.muted)),
                              Text('+4', style: mono(fontSize: 12, color: C.accent)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 10,
                    child: Row(
                      children: [
                        for (final tag in ['Gradient', 'Derivatives', 'Loss Functions'])
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: C.surface2,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(tag, style: inter(fontSize: 12, color: C.muted)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 10,
                    child: PrimaryBtn(label: 'Play', onPressed: onNext),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(text, style: spaceGrotesk(fontSize: 12, color: color, letterSpacing: 0.08)),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(20, size.height - 20)
      ..quadraticBezierTo(size.width * 0.3, 20, size.width * 0.5, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.68, size.height + 10, size.width - 20, 30);
    canvas.drawPath(path, Paint()..color = C.accent..strokeWidth = 2..style = PaintingStyle.stroke);

    canvas.drawCircle(Offset(size.width * 0.2, 55), 10, Paint()..color = C.accent.withValues(alpha: 0.2));
    canvas.drawCircle(Offset(size.width * 0.2, 55), 7, Paint()..color = C.accent);
    canvas.drawCircle(Offset(size.width * 0.2, 55), 3, Paint()..color = Colors.white);

    canvas.drawLine(
      Offset(size.width * 0.5, 20), Offset(size.width * 0.5, size.height - 20),
      Paint()..color = C.green..strokeWidth = 1..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.72), 5, Paint()..color = C.green.withValues(alpha: 0.5));

    final tp = TextPainter(
      text: TextSpan(text: 'Loss landscape — find the minimum', style: inter(fontSize: 12, color: C.muted.withValues(alpha: 0.7))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(16, size.height - 20));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
