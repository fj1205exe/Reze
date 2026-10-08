import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../main.dart';
import '../utils/loss_fns.dart' as lf_utils;

class LFResultScreen extends StatelessWidget {
  final AppProgress progress;
  final bool challengeSuccess;
  final int challengeCorrect;
  final int challengeTotal;
  final VoidCallback onRetryChallenge;
  final VoidCallback onNext;
  final VoidCallback onPlaySGD;

  const LFResultScreen({
    super.key,
    required this.progress,
    required this.challengeSuccess,
    required this.challengeCorrect,
    required this.challengeTotal,
    required this.onRetryChallenge,
    required this.onNext,
    required this.onPlaySGD,
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
                  Text('Loss Functions', style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 24),

              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                duration: const Duration(milliseconds: 400),
                slideDistance: 14,
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: S.borderMd,
                  border: Border.all(color: C.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('what you discovered', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 10),
                    Text(
                      'Loss functions are how models measure their own mistakes. MSE amplifies large errors, MAE treats all errors equally, and Huber bridges both. Choosing the right loss changes what your model optimizes for.',
                      style: inter(fontSize: 14, color: C.txt),
                    ),
                    const SizedBox(height: 14),
                    _buildFormulaPill('MSE', 'L = (y − ŷ)²', Color(lf_utils.lossColors['mse']!)),
                    const SizedBox(height: 6),
                    _buildFormulaPill('MAE', 'L = |y − ŷ|', Color(lf_utils.lossColors['mae']!)),
                    const SizedBox(height: 6),
                    _buildFormulaPill('HUBER', 'L = ½r² or δ(|r| − ½δ)', Color(lf_utils.lossColors['huber']!)),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 20),


              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
                slideDistance: 14,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: S.borderMd,
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
                        Text('Challenge: Pick the right loss',
                            style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _metricTile('Result', challengeSuccess ? 'Passed' : 'Failed', challengeSuccess ? C.green : C.pink)),
                        const SizedBox(width: 8),
                        Expanded(child: _metricTile('Correct', '$challengeCorrect / $challengeTotal', C.yellow)),
                      ],
                    ),
                  ],
                ),
              ),
              ),
              if (!challengeSuccess) ...[
                const SizedBox(height: 12),
                SecondaryBtn(label: 'Retry challenge', onPressed: onRetryChallenge),
              ],
              const SizedBox(height: 20),

              Text('skill updates', style: spaceGrotesk(fontSize: 12, color: C.muted)),
              const SizedBox(height: 10),
              _buildSkillRow('Optimization', 15, C.accent, progress.skillMap['Optimization'] ?? 0),
              const SizedBox(height: 8),
              _buildSkillRow('Calculus', 8, C.blue, progress.skillMap['Calculus'] ?? 0),
              const SizedBox(height: 24),

              Container(
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
                    Text('optimization world — progress', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 12),
                    _buildConceptRow('Gradient Descent', progress.gdComplete),
                    const SizedBox(height: 8),
                    _buildConceptRow('Loss Functions', progress.lfComplete),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                duration: const Duration(milliseconds: 400),
                slideDistance: 12,
                child: Column(children: [
                  PrimaryBtn(label: 'NEXT: STOCHASTIC GD', onPressed: onPlaySGD),
                  const SizedBox(height: 12),
                  SecondaryBtn(label: 'BACK TO HOME', onPressed: onNext),
                ]),
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
        borderRadius: S.borderSm,
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

  Widget _buildFormulaPill(String name, String formula, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: C.surface2,
        borderRadius: S.borderSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: col)),
          Text(formula, style: mono(fontSize: 12, color: C.txt)),
        ],
      ),
    );
  }

  Widget _buildSkillRow(String skill, int delta, Color color, int val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: S.borderSm,
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
