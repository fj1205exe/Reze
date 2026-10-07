import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class GoalScreen extends StatelessWidget {
  final String goal;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GoalScreen({super.key, required this.goal, required this.onSelect, required this.onNext, required this.onBack});

  static const _options = [
    {'id': 'fundamentals', 'label': 'Understand ML fundamentals', 'desc': 'Build intuition for how machine learning works under the hood.', 'icon': Icons.diamond_outlined},
    {'id': 'math', 'label': 'Strengthen my math', 'desc': 'Fill gaps in calculus, linear algebra, and probability.', 'icon': Icons.functions},
    {'id': 'prep', 'label': 'Prepare for ML', 'desc': 'Get ready for courses, interviews, or research.', 'icon': Icons.arrow_forward},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'MLab', onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 500),
                    child: Text('What do you want to get better at?',
                      style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                  ),
                  const SizedBox(height: 8),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    duration: const Duration(milliseconds: 450),
                    child: Text("We'll personalize your path.", style: inter(fontSize: 14, color: C.muted)),
                  ),
                  const SizedBox(height: 32),
                  for (int i = 0; i < _options.length; i++) ...[
                    FadeSlideIn(
                      delay: Duration(milliseconds: 180 + i * 90),
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: OptionCard(
                        selected: goal == _options[i]['id'],
                        onSelect: () => onSelect(_options[i]['id'] as String),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_options[i]['icon'] as IconData, size: 24,
                              color: goal == _options[i]['id'] ? C.accent : const Color(0xFF4B5563)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_options[i]['label'] as String, style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text(_options[i]['desc'] as String, style: inter(fontSize: 14, color: C.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 400),
                    child: PrimaryBtn(label: 'CONTINUE', onPressed: onNext, disabled: goal.isEmpty),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
