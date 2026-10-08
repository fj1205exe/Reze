import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';

class MapTabScreen extends StatelessWidget {
  final AppProgress progress;
  final void Function(AppScreen s) onNavigate;
  const MapTabScreen({super.key, required this.progress, required this.onNavigate});

  static const _concepts = [
    {'flag': 'gdComplete', 'label': 'Gradient Descent', 'cat': 'Optimization', 'nav': AppScreen.gdPlay},
    {'flag': 'lrComplete', 'label': 'Linear Regression', 'cat': 'Regression', 'nav': AppScreen.lrPlay},
    {'flag': 'ofComplete', 'label': 'Overfitting', 'cat': 'Models', 'nav': AppScreen.ofPlay},
    {'flag': 'lfComplete', 'label': 'Loss Functions', 'cat': 'Optimization', 'nav': AppScreen.lfPlay},
    {'flag': 'sgdComplete', 'label': 'SGD', 'cat': 'Optimization', 'nav': AppScreen.sgdPlay},
    {'flag': 'clComplete', 'label': 'Classification', 'cat': 'Models', 'nav': AppScreen.clPlay},
    {'flag': 'vecComplete', 'label': 'Vectors', 'cat': 'Geometry', 'nav': AppScreen.vecPlay},
    {'flag': 'dotComplete', 'label': 'Dot Product', 'cat': 'Geometry', 'nav': AppScreen.dotPlay},
    {'flag': 'prComplete', 'label': 'Probability', 'cat': 'Stats', 'nav': AppScreen.prPlay},
    {'flag': 'bayComplete', 'label': "Bayes' Theorem", 'cat': 'Stats', 'nav': AppScreen.bayPlay},
    {'flag': 'nnComplete', 'label': 'Weights & Bias', 'cat': 'Neural Nets', 'nav': AppScreen.nnPlay},
    {'flag': 'bpComplete', 'label': 'Backpropagation', 'cat': 'Neural Nets', 'nav': AppScreen.bpPlay},
  ];

  @override
  Widget build(BuildContext context) {
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
                child: Text('Concept Map', style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _concepts.length,
              itemBuilder: (_, i) {
                final c = _concepts[i];
                final done = progress.getFlag(c['flag'] as String);
                return FadeSlideIn(
                  delay: Duration(milliseconds: 40 * i),
                  duration: const Duration(milliseconds: 400),
                  slideDistance: 12,
                  child: GestureDetector(
                    onTap: () => onNavigate(c['nav'] as AppScreen),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: S.borderMd,
                        border: Border.all(color: done ? C.green.withValues(alpha: 0.2) : C.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done ? C.green.withValues(alpha: 0.15) : C.surface2,
                            ),
                            child: Icon(
                              done ? Icons.check : Icons.play_arrow,
                              size: 16,
                              color: done ? C.green : C.muted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c['label'] as String, style: spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600)),
                                Text(c['cat'] as String, style: inter(fontSize: 12, color: C.muted)),
                              ],
                            ),
                          ),
                          Text(done ? 'Done' : 'Play', style: inter(fontSize: 12, color: done ? C.green : C.accent)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          MLabNavBar(
            active: 'map',
            onNavigate: (id) {
              if (id == 'home') onNavigate(AppScreen.home);
              if (id == 'progress') onNavigate(AppScreen.progress);
            },
          ),
        ],
      ),
    );
  }
}
