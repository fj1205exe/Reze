import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../main.dart';

class DOTResultScreen extends StatelessWidget {
  final AppProgress progress;
  final int challengeSteps;
  final bool challengeSuccess;
  final VoidCallback onNext;
  final VoidCallback onPlayPR;
  final VoidCallback? onRetry;

  const DOTResultScreen({
    super.key,
    required this.progress,
    this.challengeSteps = 0,
    this.challengeSuccess = true,
    required this.onNext,
    required this.onPlayPR,
    this.onRetry,
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
              // Badge
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
                  Text('Dot Product', style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 16),

              // Challenge performance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: challengeSuccess ? C.green.withValues(alpha: 0.08) : C.yellow.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (challengeSuccess ? C.green : C.yellow).withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Challenge Result', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        Icon(
                          challengeSuccess ? Icons.check_circle : Icons.info_outline,
                          size: 16,
                          color: challengeSuccess ? C.green : C.yellow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challengeSuccess
                          ? 'Found perpendicular vectors in $challengeSteps attempt${challengeSteps == 1 ? '' : 's'}!'
                          : 'Completed with $challengeSteps attempts.',
                      style: inter(fontSize: 14, color: challengeSuccess ? C.green : C.yellow, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary
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
                      'The dot product has two equivalent forms — geometric (angle + magnitudes) and algebraic (component-wise sum). It measures similarity, powers attention mechanisms, and is the core computation in every neural network layer.',
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
                            const TextSpan(text: 'a · b = '),
                            TextSpan(text: '|a| |b|', style: mono(fontSize: 14, color: C.blue)),
                            TextSpan(text: ' cos(θ)', style: mono(fontSize: 14, color: C.yellow)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Skill updates
              Text('skill updates', style: spaceGrotesk(fontSize: 12, color: C.muted)),
              const SizedBox(height: 10),
              _buildSkillRow('Vectors', 16, C.accent, progress.skillMap['Vectors'] ?? 0),
              const SizedBox(height: 8),
              _buildSkillRow('Calculus', 8, C.blue, progress.skillMap['Calculus'] ?? 0),
              const SizedBox(height: 24),

              // Concepts completed
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
                    Text('geometry world — progress', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 12),
                    _buildConceptRow('Vectors', progress.vecComplete),
                    const SizedBox(height: 8),
                    _buildConceptRow('Dot Product', progress.dotComplete),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              FadeSlideIn(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 400),
                slideDistance: 12,
                child: PrimaryBtn(label: 'NEXT: PROBABILITY', onPressed: onPlayPR),
              ),
              const SizedBox(height: 12),
              if (onRetry != null && !challengeSuccess) ...[
                SecondaryBtn(label: 'RETRY CHALLENGE', onPressed: onRetry),
                const SizedBox(height: 12),
              ],
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
