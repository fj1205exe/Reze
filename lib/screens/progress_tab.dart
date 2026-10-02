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
                  Container(
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
                        Container(
                          height: 6,
                          decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(3)),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: completedCount / flags.length,
                            child: Container(decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(3))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  if (progress.history.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Recent activity', style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    for (final item in progress.history.take(8)) ...[
                      Container(
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
                            Text(item.concept, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('${item.action} · ${item.detail}', style: inter(fontSize: 12, color: C.muted)),
                          ],
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
