import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

const _skillList = [
  {'id': 'algebra', 'label': 'Algebra', 'color': 0xFF8B5CF6},
  {'id': 'functions', 'label': 'Functions', 'color': 0xFFA78BFA},
  {'id': 'vectors', 'label': 'Vectors', 'color': 0xFF38BDF8},
  {'id': 'probability', 'label': 'Probability', 'color': 0xFF38BDF8},
  {'id': 'statistics', 'label': 'Statistics', 'color': 0xFFA78BFA},
  {'id': 'calculus', 'label': 'Calculus', 'color': 0xFF8B5CF6},
  {'id': 'optimization', 'label': 'Optimization', 'color': 0xFF38BDF8},
];

const _nodes = [
  {'id': 'algebra', 'x': 0.5, 'y': 0.05},
  {'id': 'functions', 'x': 0.2, 'y': 0.3},
  {'id': 'vectors', 'x': 0.78, 'y': 0.3},
  {'id': 'probability', 'x': 0.15, 'y': 0.58},
  {'id': 'statistics', 'x': 0.5, 'y': 0.55},
  {'id': 'calculus', 'x': 0.82, 'y': 0.58},
  {'id': 'optimization', 'x': 0.5, 'y': 0.82},
];

const _edges = [
  ['algebra', 'functions'], ['algebra', 'vectors'],
  ['functions', 'calculus'], ['functions', 'probability'],
  ['vectors', 'calculus'], ['probability', 'statistics'],
  ['calculus', 'optimization'], ['statistics', 'optimization'],
];

class SkillMapScreen extends StatelessWidget {
  final Map<String, int> skillMap;
  final String mode;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const SkillMapScreen({super.key, required this.skillMap, required this.mode, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: mode == 'explore' ? 'skill map' : 'MLab', onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your math map', style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text("You don't need to learn everything at once.", style: inter(fontSize: 14, color: C.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    duration: const Duration(milliseconds: 500),
                    slideDistance: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: CustomPaint(
                        painter: _SkillGraphPainter(skillMap),
                        size: const Size(double.infinity, 270),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (int i = 0; i < _skillList.length; i++) ...[
                    FadeSlideIn(
                      delay: Duration(milliseconds: 250 + i * 50),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 10,
                      child: SkillBar(
                        label: _skillList[i]['label'] as String,
                        value: skillMap[_skillList[i]['label'] as String] ?? 0,
                        color: Color(_skillList[i]['color'] as int),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (mode == 'onboarding') ...[
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 14,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: C.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: C.accent.withValues(alpha: 0.18)),
                        ),
                        child: Row(
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: C.accent)),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Optimization is your next frontier — start with Gradient Descent.',
                              style: inter(fontSize: 14, color: C.accentLight))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 750),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 10,
                      child: PrimaryBtn(label: 'Continue', onPressed: onNext),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillGraphPainter extends CustomPainter {
  final Map<String, int> skillMap;
  _SkillGraphPainter(this.skillMap);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    const h = 270.0;

    Map<String, dynamic> nodeOf(String id) => _nodes.firstWhere((n) => n['id'] == id);
    Map<String, dynamic> skillOf(String id) => _skillList.firstWhere((s) => s['id'] == id);

    // Edges
    for (final edge in _edges) {
      final a = nodeOf(edge[0]);
      final b = nodeOf(edge[1]);
      canvas.drawLine(
        Offset((a['x'] as double) * w, (a['y'] as double) * h + 20),
        Offset((b['x'] as double) * w, (b['y'] as double) * h + 20),
        Paint()..color = Colors.white.withValues(alpha: 0.07)..strokeWidth = 1,
      );
    }

    // Nodes
    for (final n in _nodes) {
      final sk = skillOf(n['id'] as String);
      final cx = (n['x'] as double) * w;
      final cy = (n['y'] as double) * h + 20;
      const r = 22.0;
      final val = skillMap[sk['label'] as String] ?? 0;
      final color = Color(sk['color'] as int);

      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFF14171C).withValues(alpha: 0.9));
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white.withValues(alpha: 0.07)..style = PaintingStyle.stroke..strokeWidth = 1);

      final arcAngle = (val / 100) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi / 2, arcAngle, false,
        Paint()..color = color.withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round,
      );

      final labelTp = TextPainter(
        text: TextSpan(text: sk['label'] as String, style: spaceGrotesk(fontSize: 8.5, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(canvas, Offset(cx - labelTp.width / 2, cy - 6));

      final valTp = TextPainter(
        text: TextSpan(text: '$val%', style: mono(fontSize: 8, color: color)),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(cx - valTp.width / 2, cy + 5));
    }
  }

  @override
  bool shouldRepaint(covariant _SkillGraphPainter old) => true;
}
