import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  const WelcomeScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text("Math shouldn't feel like memorizing.",
                style: spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.02)),
              const SizedBox(height: 20),
              for (final line in ['Play with it.', 'See what happens.', 'Then learn why.'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(line, style: inter(fontSize: 16, color: C.muted)),
                ),
              const Spacer(),
              Row(
                children: [
                  for (final tag in ['Optimization', 'Calculus', 'Vectors'])
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: C.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(tag, style: inter(fontSize: 12, color: C.accent.withValues(alpha: 0.8))),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryBtn(label: 'Get started', onPressed: onNext),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
