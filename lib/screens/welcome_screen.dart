import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;
  const WelcomeScreen({super.key, required this.onNext});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  static const _lines = ['Play with it.', 'See what happens.', 'Then learn why.'];
  static const _tags = ['Optimization', 'Calculus', 'Vectors'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..addListener(() => setState(() {}))
     ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _ease(double begin, double end) {
    final t = _ctrl.value;
    if (t <= begin) return 0;
    if (t >= end) return 1;
    return Curves.easeOutCubic.transform((t - begin) / (end - begin));
  }

  @override
  Widget build(BuildContext context) {
    final headOp = _ease(0, 0.3);
    final headSlide = 20 * (1 - headOp);
    final tagOp = _ease(0.45, 0.65);
    final btnOp = _ease(0.6, 0.8);

    return Container(
      color: C.bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Opacity(
                opacity: headOp,
                child: Transform.translate(
                  offset: Offset(0, headSlide),
                  child: Text("Math shouldn't feel like memorizing.",
                    style: spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.02)),
                ),
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < _lines.length; i++)
                Builder(builder: (context) {
                  final op = _ease(0.15 + i * 0.08, 0.4 + i * 0.08);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Opacity(
                      opacity: op,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - op)),
                        child: Text(_lines[i], style: inter(fontSize: 16, color: C.muted)),
                      ),
                    ),
                  );
                }),
              const Spacer(),
              Opacity(
                opacity: tagOp,
                child: Row(
                  children: [
                    for (final tag in _tags)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: C.accent.withValues(alpha: 0.1),
                          borderRadius: S.borderSm,
                        ),
                        child: Text(tag, style: inter(fontSize: 12, color: C.accent.withValues(alpha: 0.8))),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: btnOp,
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - btnOp)),
                  child: PrimaryBtn(label: 'Get started', onPressed: widget.onNext),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
