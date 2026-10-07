import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../main.dart';

class NNResultScreen extends StatelessWidget {
  final AppProgress progress;
  final bool challengeSuccess;
  final int challengeSteps;
  final VoidCallback onRetryChallenge;
  final VoidCallback onNext;
  final VoidCallback onPlayBP;

  const NNResultScreen({
    super.key,
    required this.progress,
    required this.challengeSuccess,
    required this.challengeSteps,
    required this.onRetryChallenge,
    required this.onNext,
    required this.onPlayBP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                duration: const Duration(milliseconds: 450),
                slideDistance: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: C.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: C.green.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: C.green),
                        const SizedBox(width: 4),
                        Text('CONCEPT CLEAR', style: spaceGrotesk(fontSize: 11, color: C.green, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Weights & Bias', style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('what you discovered', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 10),
                    Text(
                      'Every neuron in a neural network does one simple thing — weighted sum plus bias, passed through a non-linearity. Training a neural network means adjusting those weights and biases to minimize error across data points.',
                      style: inter(fontSize: 14, color: C.txt),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: C.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: mono(fontSize: 14, color: C.txt),
                          children: [
                            const TextSpan(text: 'output = '),
                            TextSpan(text: 'σ', style: mono(fontSize: 14, color: C.accentLight)),
                            const TextSpan(text: '('),
                            TextSpan(text: 'w', style: mono(fontSize: 14, color: C.green)),
                            const TextSpan(text: ' · '),
                            TextSpan(text: 'x', style: mono(fontSize: 14, color: C.blue)),
                            const TextSpan(text: ' + '),
                            TextSpan(text: 'b', style: mono(fontSize: 14, color: C.yellow)),
                            const TextSpan(text: ')'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: challengeSuccess
                        ? C.green.withValues(alpha: 0.2)
                        : C.pink.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          challengeSuccess ? Icons.emoji_events : Icons.replay,
                          size: 16,
                          color: challengeSuccess ? C.yellow : C.pink,
                        ),
                        const SizedBox(width: 8),
                        Text('Challenge: Hit the target output',
                            style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _metricTile('Result', challengeSuccess ? 'Passed' : 'Failed', challengeSuccess ? C.green : C.pink)),
                        const SizedBox(width: 8),
                        Expanded(child: _metricTile('Adjustments', '$challengeSteps / 8', C.yellow)),
                      ],
                    ),
                  ],
                ),
              ),
              if (!challengeSuccess) ...[
                const SizedBox(height: 12),
                SecondaryBtn(label: 'Retry challenge', onPressed: onRetryChallenge),
              ],
              const SizedBox(height: 20),

              Text('skill updates', style: spaceGrotesk(fontSize: 12, color: C.muted)),
              const SizedBox(height: 10),
              _buildSkillRow('Calculus', 18, C.blue, progress.skillMap['Calculus'] ?? 0),
              const SizedBox(height: 8),
              _buildSkillRow('Optimization', 10, C.accent, progress.skillMap['Optimization'] ?? 0),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('neural networks world — progress', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 12),
                    _buildConceptRow('Weights & Bias', progress.nnComplete),
                    const SizedBox(height: 8),
                    _buildConceptRow('Backpropagation', progress.bpComplete),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              FadeSlideIn(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 400),
                slideDistance: 12,
                child: PrimaryBtn(label: 'NEXT: BACKPROPAGATION', onPressed: onPlayBP),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                duration: const Duration(milliseconds: 400),
                slideDistance: 10,
                child: SecondaryBtn(label: 'BACK TO HOME', onPressed: onNext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: inter(fontSize: 11, color: C.muted)),
          const SizedBox(height: 2),
          Text(value, style: mono(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildSkillRow(String skill, int delta, Color color, int val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(skill, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                width: 90,
                height: 4,
                decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(2)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (val / 100).clamp(0.0, 1.0),
                  child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                ),
              ),
            ],
          ),
          Text('+$delta', style: mono(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildConceptRow(String label, bool done) {
    return Row(
      children: [
        Icon(done ? Icons.check_circle : Icons.circle_outlined, size: 16, color: done ? C.green : C.muted),
        const SizedBox(width: 8),
        Text(label, style: inter(fontSize: 13, color: done ? C.txt : C.muted)),
      ],
    );
  }
}
