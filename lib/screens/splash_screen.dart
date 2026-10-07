import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onNext;
  const SplashScreen({super.key, required this.onNext});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..addListener(() => setState(() {}))
     ..forward();
    _timer = Timer(const Duration(milliseconds: 2800), widget.onNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  double _ease(double begin, double end, [Curve curve = Curves.easeOut]) {
    final t = _ctrl.value;
    if (t <= begin) return 0;
    if (t >= end) return 1;
    return curve.transform((t - begin) / (end - begin));
  }

  @override
  Widget build(BuildContext context) {
    final logoOp = _ease(0, 0.35);
    final logoScale = 0.7 + 0.3 * _ease(0, 0.5, Curves.easeOutBack);
    final titleOp = _ease(0.2, 0.55);
    final titleSlide = 14 * (1 - titleOp);
    final tagOp = _ease(0.4, 0.7);

    return GestureDetector(
      onTap: widget.onNext,
      child: Container(
        color: C.bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: logoOp,
                child: Transform.scale(
                  scale: logoScale,
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: C.accent.withValues(alpha: 0.1),
                      border: Border.all(color: C.accent.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.show_chart, color: C.accent, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Opacity(
                opacity: titleOp,
                child: Transform.translate(
                  offset: Offset(0, titleSlide),
                  child: Text('MLab', style: spaceGrotesk(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.02)),
                ),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: tagOp,
                child: Text('Learn ML by playing with the math.', style: inter(fontSize: 14, color: C.muted), textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
