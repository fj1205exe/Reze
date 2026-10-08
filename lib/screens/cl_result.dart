import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../main.dart';

class CLResultScreen extends StatelessWidget {
  final AppProgress progress;
  final bool challengeSuccess;
  final double challengeAccuracy;
  final int challengeSteps;
  final VoidCallback? onRetryChallenge;
  final VoidCallback onNext;
  final VoidCallback onPlayPR;

  const CLResultScreen({
    super.key,
    required this.progress,
    this.challengeSuccess = true,
    this.challengeAccuracy = 100.0,
    this.challengeSteps = 0,
    this.onRetryChallenge,
    required this.onNext,
    required this.onPlayPR,
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
                  Text('Classification', style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 16),

              // Challenge results card
              if (challengeSuccess)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: C.green.withValues(alpha: 0.1),
                    borderRadius: S.borderMd,
                    border: Border.all(color: C.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, size: 20, color: C.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Challenge passed! ${challengeAccuracy.round()}% accuracy in $challengeSteps adjustments.',
                          style: inter(fontSize: 14, color: C.green),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!challengeSuccess)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: C.pink.withValues(alpha: 0.08),
                    borderRadius: S.borderMd,
                    border: Border.all(color: C.pink.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    'Challenge missed — ${challengeAccuracy.round()}% accuracy. 90% needed.',
                    style: inter(fontSize: 14, color: C.pink),
                  ),
                ),
              if (!challengeSuccess) ...[
                SecondaryBtn(label: 'Retry challenge', onPressed: onRetryChallenge),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 8),

              // Summary
              Container(
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
                      'A linear classifier draws a decision boundary that separates classes. By adjusting the angle and position you found the hyperplane that best separates the data. The same idea powers modern ML — from spam filters to image classifiers.',
                      style: inter(fontSize: 14, color: C.txt),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: C.surface2,
                        borderRadius: S.borderSm,
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: mono(fontSize: 14, color: C.txt),
                          children: [
                            const TextSpan(text: 'ŷ = '),
                            TextSpan(text: 'sign', style: mono(fontSize: 14, color: C.green)),
                            const TextSpan(text: '('),
                            TextSpan(text: 'w', style: mono(fontSize: 14, color: C.purple)),
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

              // Skill updates
              Text('skill updates', style: spaceGrotesk(fontSize: 12, color: C.muted)),
              const SizedBox(height: 10),
              _buildSkillRow('Statistics', 12, const Color(0xFFA78BFA), progress.skillMap['Statistics'] ?? 0),
              const SizedBox(height: 8),
              _buildSkillRow('Optimization', 8, C.blue, progress.skillMap['Optimization'] ?? 0),
              const SizedBox(height: 24),

              // Concepts completed
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
                    Text('models world — progress', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 12),
                    _buildConceptRow('Linear Regression', progress.lrComplete),
                    const SizedBox(height: 8),
                    _buildConceptRow('Overfitting', progress.ofComplete),
                    const SizedBox(height: 8),
                    _buildConceptRow('Classification', progress.clComplete),
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
