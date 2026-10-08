import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class ResultScreen extends StatelessWidget {
  final int roundsPassed;
  final int totalRounds;
  final int totalSteps;
  final bool succeeded;
  final VoidCallback onNext;
  final VoidCallback onPlayLR;
  final VoidCallback onRetry;
  const ResultScreen({
    super.key,
    required this.roundsPassed,
    required this.totalRounds,
    required this.totalSteps,
    required this.succeeded,
    required this.onNext,
    required this.onPlayLR,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 32),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (succeeded ? C.green : C.accentLight).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: (succeeded ? C.green : C.accent).withValues(alpha: 0.3)),
                      ),
                      child: Text(succeeded ? 'CONCEPT CLEAR' : 'GOOD EFFORT',
                        style: spaceGrotesk(fontSize: 12, color: succeeded ? C.green : C.accentLight, letterSpacing: 0.1)),
                    ),
                    const SizedBox(height: 8),
                    Text(succeeded ? 'Gradient Descent' : 'Keep experimenting',
                      style: spaceGrotesk(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.02)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                duration: const Duration(milliseconds: 400),
                slideDistance: 14,
                child: Row(
                  children: [
                    Expanded(child: _metric('Rounds', '$roundsPassed', '/ $totalRounds', succeeded ? C.green : C.yellow)),
                    const SizedBox(width: 12),
                    Expanded(child: _metric('Steps', '$totalSteps', '', C.accent)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
                slideDistance: 14,
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WHAT YOU LEARNED', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                    const SizedBox(height: 12),
                    Text('Learning rate controls the size of each update. Too small — slow convergence. Too large — overshoot and diverge. The right η depends on the landscape and your position.',
                      style: inter(fontSize: 14, color: C.txt)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(text: 'θ', style: mono(fontSize: 15, color: C.blue)),
                          TextSpan(text: ' = ', style: mono(fontSize: 15, color: C.muted)),
                          TextSpan(text: 'θ', style: mono(fontSize: 15, color: C.blue)),
                          TextSpan(text: ' − ', style: mono(fontSize: 15, color: C.muted)),
                          TextSpan(text: 'η', style: mono(fontSize: 15, color: C.yellow)),
                          TextSpan(text: '∇J(θ)', style: mono(fontSize: 15, color: C.pink)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 28),
              Text(succeeded ? 'Skill updates' : 'What to aim for',
                  style: spaceGrotesk(fontSize: 12, color: C.muted)),
              const SizedBox(height: 12),
              _skillUpdate('Optimization', 8, succeeded ? C.blue : C.muted),
              const SizedBox(height: 8),
              _skillUpdate('Calculus', 4, succeeded ? C.accent : C.muted),
              if (succeeded) ...[
                const SizedBox(height: 28),
                _nextConceptCard(),
              ],
              const SizedBox(height: 28),
              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                duration: const Duration(milliseconds: 400),
                slideDistance: 12,
                child: Row(
                  children: [
                    Expanded(child: SecondaryBtn(label: 'Home', onPressed: onNext)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryBtn(
                        label: succeeded ? 'Play next →' : 'Retry Challenge',
                        onPressed: succeeded ? onPlayLR : onRetry,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: inter(fontSize: 12, color: C.muted)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: mono(fontSize: 28, fontWeight: FontWeight.w500, color: color)),
              if (sub.isNotEmpty) Text(sub, style: mono(fontSize: 14, color: C.muted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skillUpdate(String skill, int delta, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(skill, style: spaceGrotesk(fontSize: 14)),
          Text('+$delta', style: mono(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _nextConceptCard() {
    return GestureDetector(
      onTap: onPlayLR,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: S.borderMd,
          border: Border.all(color: C.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next concept', style: inter(fontSize: 12, color: C.muted)),
                  const SizedBox(height: 4),
                  Text('Linear Regression', style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Fit a line to data.', style: inter(fontSize: 12, color: C.muted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: C.accent, size: 16),
          ],
        ),
      ),
    );
  }
}
