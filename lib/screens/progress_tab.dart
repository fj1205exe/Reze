import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';

class ProgressTabScreen extends StatelessWidget {
  final Map<String, int> skillMap;
  final AppProgress progress;
  final void Function(AppScreen s) onNavigate;
  const ProgressTabScreen({super.key, required this.skillMap, required this.progress, required this.onNavigate});

  static const _skills = [
    {'label': 'Optimization', 'color': 0xFF8B5CF6},
    {'label': 'Calculus', 'color': 0xFF38BDF8},
    {'label': 'Probability', 'color': 0xFFA78BFA},
    {'label': 'Statistics', 'color': 0xFF4ADE80},
    {'label': 'Algebra', 'color': 0xFFFBBF24},
    {'label': 'Vectors', 'color': 0xFFFB7185},
    {'label': 'Functions', 'color': 0xFF6EE7B7},
  ];

  @override
  Widget build(BuildContext context) {
    final flags = ['gdComplete', 'lrComplete', 'ofComplete', 'lfComplete', 'sgdComplete',
      'clComplete', 'prComplete', 'vecComplete', 'dotComplete', 'bayComplete', 'nnComplete', 'bpComplete'];
    final completedCount = flags.where((f) => progress.getFlag(f)).length;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Progress', style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 450),
                    slideDistance: 14,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Concepts completed', style: inter(fontSize: 12, color: C.muted)),
                          const SizedBox(height: 8),
                          Text('$completedCount / ${flags.length}', style: mono(fontSize: 28, color: C.accent)),
                          const SizedBox(height: 12),
                          TweenAnimationBuilder<double>(
                            tween: Tween(end: completedCount / flags.length),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, val, _) => Container(
                              height: 6,
                              decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(3)),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: val,
                                child: Container(decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(3))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Skills', style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            children: [
                              for (final s in _skills) ...[
                                SkillBar(
                                  label: s['label'] as String,
                                  value: skillMap[s['label'] as String] ?? 0,
                                  color: Color(s['color'] as int),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (progress.history.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: Text('Recent activity', style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < progress.history.take(8).length; i++) ...[
                      FadeSlideIn(
                        delay: Duration(milliseconds: 350 + i * 50),
                        duration: const Duration(milliseconds: 350),
                        slideDistance: 10,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(progress.history[i].concept, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('${progress.history[i].action} · ${progress.history[i].detail}', style: inter(fontSize: 12, color: C.muted)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          MLabNavBar(
            active: 'progress',
            onNavigate: (id) {
              if (id == 'home') onNavigate(AppScreen.home);
              if (id == 'map') onNavigate(AppScreen.mapTab);
            },
          ),
        ],
      ),
    );
  }
}
