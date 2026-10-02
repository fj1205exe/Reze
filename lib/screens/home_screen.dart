import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';

class _ConceptInfo {
  final String flag, label, category, blurb;
  final AppScreen nav;
  const _ConceptInfo({required this.flag, required this.label, required this.category, required this.blurb, required this.nav});
}

const _conceptOrder = [
  _ConceptInfo(flag: 'gdComplete', label: 'Gradient Descent', category: 'OPTIMIZATION', blurb: 'Step down the loss landscape.', nav: AppScreen.gdPlay),
  _ConceptInfo(flag: 'lrComplete', label: 'Linear Regression', category: 'REGRESSION', blurb: 'Fit a line to data.', nav: AppScreen.lrPlay),
  _ConceptInfo(flag: 'ofComplete', label: 'Overfitting', category: 'MODELS', blurb: 'Bias vs variance tradeoff.', nav: AppScreen.ofPlay),
  _ConceptInfo(flag: 'lfComplete', label: 'Loss Functions', category: 'OPTIMIZATION', blurb: 'MSE, MAE, and Huber loss.', nav: AppScreen.lfPlay),
  _ConceptInfo(flag: 'sgdComplete', label: 'SGD', category: 'OPTIMIZATION', blurb: 'Noisy gradient updates.', nav: AppScreen.sgdPlay),
  _ConceptInfo(flag: 'clComplete', label: 'Classification', category: 'MODELS', blurb: 'Draw a decision boundary.', nav: AppScreen.clPlay),
  _ConceptInfo(flag: 'vecComplete', label: 'Vectors', category: 'GEOMETRY', blurb: 'Add, subtract, scale.', nav: AppScreen.vecPlay),
  _ConceptInfo(flag: 'dotComplete', label: 'Dot Product', category: 'GEOMETRY', blurb: 'Similarity in disguise.', nav: AppScreen.dotPlay),
  _ConceptInfo(flag: 'prComplete', label: 'Probability', category: 'STATS', blurb: 'Flip coins, find patterns.', nav: AppScreen.prPlay),
  _ConceptInfo(flag: 'bayComplete', label: "Bayes' Theorem", category: 'STATS', blurb: 'Update beliefs with evidence.', nav: AppScreen.bayPlay),
  _ConceptInfo(flag: 'nnComplete', label: 'Weights & Bias', category: 'NEURAL NETS', blurb: 'A single neuron forward pass.', nav: AppScreen.nnPlay),
  _ConceptInfo(flag: 'bpComplete', label: 'Backpropagation', category: 'NEURAL NETS', blurb: 'Chain rule through the network.', nav: AppScreen.bpPlay),
];

const _allSkills = [
  {'label': 'Optimization', 'color': 0xFF8B5CF6},
  {'label': 'Calculus', 'color': 0xFF38BDF8},
  {'label': 'Probability', 'color': 0xFFA78BFA},
  {'label': 'Statistics', 'color': 0xFF4ADE80},
  {'label': 'Algebra', 'color': 0xFFFBBF24},
  {'label': 'Vectors', 'color': 0xFFFB7185},
  {'label': 'Functions', 'color': 0xFF6EE7B7},
];

class HomeScreen extends StatelessWidget {
  final AppProgress progress;
  final void Function(AppScreen s) onNavigate;
  const HomeScreen({super.key, required this.progress, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final completedCount = _conceptOrder.where((c) => progress.getFlag(c.flag)).length;
    final totalConcepts = _conceptOrder.length;
    final nextConcept = _conceptOrder.cast<_ConceptInfo?>().firstWhere((c) => !progress.getFlag(c!.flag), orElse: () => null);
    final available = _conceptOrder.where((c) => !progress.getFlag(c.flag) && c != nextConcept).take(3).toList();
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: inter(fontSize: 14, color: C.muted)),
                      const SizedBox(height: 2),
                      Text("What's next?", style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                    ],
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: C.accent),
                    alignment: Alignment.center,
                    child: Text('M', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('continue', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                  const SizedBox(height: 8),
                  if (nextConcept != null)
                    _continueCard(nextConcept, completedCount, totalConcepts)
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: C.green.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.green.withValues(alpha: 0.15)),
                      ),
                      child: Text('All $totalConcepts concepts complete. Nice work.',
                        style: inter(fontSize: 14, color: C.green)),
                    ),
                  if (available.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('recommended', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 8),
                    for (final c in available) ...[
                      _conceptTile(c),
                      const SizedBox(height: 8),
                    ],
                  ],
                  const SizedBox(height: 24),
                  Text('your skills', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                  const SizedBox(height: 8),
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
                        for (final s in _allSkills) ...[
                          SkillBar(
                            label: s['label'] as String,
                            value: progress.skillMap[s['label'] as String] ?? 0,
                            color: Color(s['color'] as int),
                          ),
                          const SizedBox(height: 12),
                        ],
                        GestureDetector(
                          onTap: () => onNavigate(AppScreen.skillmap),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('View full map →', style: inter(fontSize: 12, color: C.accent.withValues(alpha: 0.65))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          MLabNavBar(
            active: 'home',
            onNavigate: (id) {
              if (id == 'map') onNavigate(AppScreen.mapTab);
              if (id == 'progress') onNavigate(AppScreen.progress);
            },
          ),
        ],
      ),
    );
  }

  Widget _continueCard(_ConceptInfo c, int completed, int total) {
    return GestureDetector(
      onTap: () => onNavigate(c.nav),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.accent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.category, style: spaceGrotesk(fontSize: 12, color: C.muted)),
                    const SizedBox(height: 4),
                    Text(c.label, style: spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(c.blurb, style: inter(fontSize: 14, color: C.muted)),
                  ],
                ),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress', style: inter(fontSize: 12, color: C.muted)),
                Text('$completed / $total', style: mono(fontSize: 12, fontWeight: FontWeight.w500, color: C.accent)),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(3)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: total == 0 ? 0 : completed / total,
                child: Container(decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(3))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conceptTile(_ConceptInfo c) {
    return GestureDetector(
      onTap: () => onNavigate(c.nav),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.category, style: spaceGrotesk(fontSize: 12, color: C.muted)),
                Text(c.label, style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(c.blurb, style: inter(fontSize: 12, color: C.muted)),
              ],
            ),
            Text('play →', style: inter(fontSize: 12, color: C.muted)),
          ],
        ),
      ),
    );
  }
}
