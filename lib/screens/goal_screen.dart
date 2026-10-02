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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('What do you want to get better at?',
                    style: spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                  const SizedBox(height: 8),
                  Text("We'll personalize your path.", style: inter(fontSize: 14, color: C.muted)),
                  const SizedBox(height: 32),
                  for (final opt in _options) ...[
                    OptionCard(
                      selected: goal == opt['id'],
                      onSelect: () => onSelect(opt['id'] as String),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(opt['icon'] as IconData, size: 24,
                            color: goal == opt['id'] ? C.accent : const Color(0xFF4B5563)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(opt['label'] as String, style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(opt['desc'] as String, style: inter(fontSize: 14, color: C.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Spacer(),
                  PrimaryBtn(label: 'CONTINUE', onPressed: onNext, disabled: goal.isEmpty),
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
