import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../main.dart';

class PRResultScreen extends StatelessWidget {
  final AppProgress progress;
  final int challengeCorrect;
  final int challengeTotal;
  final VoidCallback? onRetryChallenge;
  final VoidCallback onNext;
  final VoidCallback onPlayBAY;

  const PRResultScreen({
    super.key,
    required this.progress,
    this.challengeCorrect = 3,
    this.challengeTotal = 3,
    this.onRetryChallenge,
    required this.onNext,
    required this.onPlayBAY,
  });

  @override
  Widget build(BuildContext context) {
    final passed = challengeCorrect >= 2;

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
                  Text('Probability', style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 16),

              // Challenge results card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: passed ? C.green.withValues(alpha: 0.1) : C.pink.withValues(alpha: 0.08),
                  borderRadius: S.borderMd,
                  border: Border.all(color: passed ? C.green.withValues(alpha: 0.3) : C.pink.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passed
                          ? 'Challenge passed! $challengeCorrect/$challengeTotal rounds correct.'
                          : 'Challenge missed — $challengeCorrect/$challengeTotal rounds correct. 2/3 needed.',
                      style: inter(fontSize: 14, color: passed ? C.green : C.pink),
                    ),
                    if (!passed) ...[
                      const SizedBox(height: 10),
                      SecondaryBtn(label: 'Retry challenge', onPressed: onRetryChallenge),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                      'Individual outcomes are unpredictable, but averages follow precise mathematical rules. The law of large numbers guarantees that with enough samples, observed frequency converges to true probability. Expected value and variance describe the long-run behaviour of any random process.',
                      style: inter(fontSize: 14, color: C.txt),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                            child: Text('E[X] = p', textAlign: TextAlign.center, style: mono(fontSize: 14, color: C.purple, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                            child: Text('Var[X] = p(1 − p)', textAlign: TextAlign.center, style: mono(fontSize: 13, color: C.yellow, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Skill updates
              Text('skill updates', style: spaceGrotesk(fontSize: 12, color: C.muted)),
              const SizedBox(height: 10),
              SkillGainBar(skill: 'Probability', delta: 14, color: const Color(0xFFA78BFA),
                  delay: const Duration(milliseconds: 300)),
              const SizedBox(height: 8),
              SkillGainBar(skill: 'Statistics', delta: 6, color: C.blue,
                  delay: const Duration(milliseconds: 500)),
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
                    Text('stats world — progress', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 12),
                    _buildConceptRow('Probability', progress.prComplete),
                    const SizedBox(height: 8),
                    _buildConceptRow("Bayes' Theorem", progress.bayComplete),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              FadeSlideIn(
                delay: const Duration(milliseconds: 250),
                duration: const Duration(milliseconds: 400),
                slideDistance: 12,
                child: PrimaryBtn(label: "NEXT: BAYES' THEOREM", onPressed: onPlayBAY),
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
