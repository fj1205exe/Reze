import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../main.dart';

class LRResultScreen extends StatelessWidget {
  final AppProgress progress;
  final int challengeSteps;
  final double challengeMSE;
  final bool challengeSuccess;
  final VoidCallback onNext;
  final VoidCallback onPlayOF;
  final VoidCallback? onRetry;

  const LRResultScreen({
    super.key,
    required this.progress,
    this.challengeSteps = 0,
    this.challengeMSE = 0.0,
    this.challengeSuccess = true,
    required this.onNext,
    required this.onPlayOF,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
      Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text('Linear Regression', style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary
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
                      'Linear regression finds a line that minimizes the average squared distance between predictions and actual values. That distance is the MSE.',
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
                            const TextSpan(text: 'MSE = '),
                            TextSpan(text: '1/n', style: mono(fontSize: 14, color: C.blue)),
                            TextSpan(text: ' · ', style: mono(fontSize: 14, color: const Color(0xFF4B5563))),
                            TextSpan(text: 'Σ', style: mono(fontSize: 14, color: const Color(0xFF4B5563))),
                            TextSpan(text: '(y − ŷ)²', style: mono(fontSize: 14, color: C.yellow)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 20),

              // Challenge metrics
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
                        Text('Challenge: Fit the line',
                            style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _metricTile('Result', challengeSuccess ? 'Passed' : 'Failed', challengeSuccess ? C.green : C.pink)),
                        const SizedBox(width: 8),
                        Expanded(child: _metricTile('Adjustments', '$challengeSteps / 10', C.yellow)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _metricTile('Final MSE', challengeMSE.toStringAsFixed(4), C.accentLight)),
                        const SizedBox(width: 8),
                        Expanded(child: _metricTile('Target', '< 0.05', C.blue)),
                      ],
                    ),
                  ],
                ),
              ),
              ),
              if (!challengeSuccess) ...[
                const SizedBox(height: 12),
                SecondaryBtn(label: 'Retry challenge', onPressed: onRetry),
              ],
              const SizedBox(height: 20),

              // Skill updates
              Text('skill updates', style: spaceGrotesk(fontSize: 12, color: C.muted)),
              const SizedBox(height: 10),
              SkillGainBar(skill: 'Optimization', delta: 10, color: C.blue,
                  delay: const Duration(milliseconds: 300)),
              const SizedBox(height: 8),
              SkillGainBar(skill: 'Statistics', delta: 12, color: C.accentLight,
                  delay: const Duration(milliseconds: 500)),
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
                    Text('models world — progress', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                    const SizedBox(height: 12),
                    _buildConceptRow('Linear Regression', progress.lrComplete),
                    const SizedBox(height: 8),
                    _buildConceptRow('Overfitting', progress.ofComplete),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                duration: const Duration(milliseconds: 400),
                slideDistance: 12,
                child: Column(children: [
                  PrimaryBtn(label: 'NEXT: OVERFITTING', onPressed: onPlayOF),
                  const SizedBox(height: 12),
                  SecondaryBtn(label: 'BACK TO HOME', onPressed: onNext),
                ]),
              ),
            ],
          ),
        ),
      ),
    ),
      if (challengeSuccess) const ConfettiBurst(),
      ],
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
