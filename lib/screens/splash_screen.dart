import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onNext;
  const SplashScreen({super.key, required this.onNext});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2400), widget.onNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onNext,
      child: Container(
        color: C.bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: C.accent.withValues(alpha: 0.1),
                  border: Border.all(color: C.accent.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.show_chart, color: C.accent, size: 28),
              ),
              const SizedBox(height: 24),
              Text('MLab', style: spaceGrotesk(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.02)),
              const SizedBox(height: 12),
              Text('Learn ML by playing with the math.', style: inter(fontSize: 14, color: C.muted), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
