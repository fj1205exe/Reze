import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideDistance;
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.slideDistance = 20,
  });
  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: widget.duration, vsync: this)
      ..addListener(() => setState(() {}));
    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(_ctrl.value);
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, widget.slideDistance * (1 - t)),
        child: widget.child,
      ),
    );
  }
}

class PrimaryBtn extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool disabled;
  const PrimaryBtn({super.key, required this.label, this.onPressed, this.disabled = false});
  @override
  State<PrimaryBtn> createState() => _PrimaryBtnState();
}

class _PrimaryBtnState extends State<PrimaryBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.disabled ? null : (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: widget.disabled ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.disabled ? C.surface3 : C.accent,
            borderRadius: S.borderMd,
          ),
          alignment: Alignment.center,
          child: Text(widget.label, style: spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.disabled ? C.muted : Colors.white,
            letterSpacing: 0.04,
          )),
        ),
      ),
    );
  }
}

class SecondaryBtn extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  const SecondaryBtn({super.key, required this.label, this.onPressed});
  @override
  State<SecondaryBtn> createState() => _SecondaryBtnState();
}

class _SecondaryBtnState extends State<SecondaryBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: S.borderMd,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          alignment: Alignment.center,
          child: Text(widget.label, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: C.txt)),
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final Widget child;
  final bool selected;
  final VoidCallback onSelect;
  const OptionCard({super.key, required this.child, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: S.borderMd,
            border: Border.all(color: selected ? C.accent : Colors.white.withValues(alpha: 0.07)),
            color: selected ? C.accent.withValues(alpha: 0.05) : C.surface,
          ),
          child: child,
        ),
      ),
    );
  }
}

class MLabHeader extends StatelessWidget {
  final String label;
  final VoidCallback? onBack;
  final Widget? right;
  const MLabHeader({super.key, required this.label, this.onBack, this.right});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(
          children: [
            if (onBack != null)
              Semantics(
                button: true,
                label: 'Back',
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: C.surface2,
                      borderRadius: S.borderSm,
                    ),
                    child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                  ),
                ),
              ),
            if (onBack != null) const SizedBox(width: 12),
            Text(label, style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.08)),
            if (right != null) ...[const Spacer(), right!],
          ],
        ),
      ),
    );
  }
}

class ProgressPill extends StatelessWidget {
  final int current;
  final int total;
  const ProgressPill({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: active ? 18 : 10,
          height: 4,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: active ? C.accent : C.surface3,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class SkillBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const SkillBar({super.key, required this.label, required this.value, this.color = C.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label, style: inter(fontSize: 12, color: C.muted))),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(2)),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: value / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, val, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: val.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 28,
          child: Text('$value', style: mono(fontSize: 12, color: color), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class SkillGainBar extends StatefulWidget {
  final String skill;
  final int delta;
  final Color color;
  final Duration delay;
  const SkillGainBar({
    super.key,
    required this.skill,
    required this.delta,
    required this.color,
    this.delay = Duration.zero,
  });
  @override
  State<SkillGainBar> createState() => _SkillGainBarState();
}

class _SkillGainBarState extends State<SkillGainBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(() => setState(() {}));
    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(_ctrl.value);
    final displayDelta = (widget.delta * t).round();

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - t)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: S.borderSm,
            border: Border.all(color: C.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.skill, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text('+$displayDelta',
                      style: mono(fontSize: 14, fontWeight: FontWeight.w600, color: widget.color)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(color: C.surface3),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (widget.delta / 20.0).clamp(0.05, 1.0) * t,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [widget.color.withValues(alpha: 0.5), widget.color],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LrSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChange;
  final double min;
  final double max;
  const LrSlider({super.key, required this.value, required this.onChange, this.min = 0.01, this.max = 2.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('small', style: inter(fontSize: 12, color: C.muted)),
            Text('η = ${value.toStringAsFixed(2)}', style: mono(fontSize: 14, color: C.accent)),
            Text('large', style: inter(fontSize: 12, color: C.muted)),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: C.accent,
            inactiveTrackColor: C.surface3,
            thumbColor: C.accent,
            overlayColor: C.accent.withValues(alpha: 0.15),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChange,
          ),
        ),
      ],
    );
  }
}

class FeedbackBar extends StatelessWidget {
  final String type;
  final String message;
  const FeedbackBar({super.key, required this.type, required this.message});

  Color get _color {
    switch (type) {
      case 'warn': return C.yellow;
      case 'ok': return C.green;
      default: return C.accentLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: _color, width: 2)),
      ),
      child: Text(message, style: inter(fontSize: 14, color: _color)),
    );
  }
}

class StepCounter extends StatelessWidget {
  final int steps;
  final int? max;
  const StepCounter({super.key, required this.steps, this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: C.surface2,
        borderRadius: S.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Steps ', style: inter(fontSize: 12, color: C.muted)),
          Text('$steps', style: mono(fontSize: 13, color: C.txt)),
          if (max != null) Text('/$max', style: mono(fontSize: 13, color: C.muted)),
        ],
      ),
    );
  }
}

class MLabNavBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onNavigate;
  const MLabNavBar({super.key, required this.active, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.surface,
        border: Border(top: BorderSide(color: C.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _tab('home', 'Home', Icons.home_outlined, Icons.home),
            _tab('map', 'Map', Icons.explore_outlined, Icons.explore),
            _tab('progress', 'Progress', Icons.bar_chart_outlined, Icons.bar_chart),
          ],
        ),
      ),
    );
  }

  Widget _tab(String id, String label, IconData icon, IconData activeIcon) {
    final isActive = active == id;
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        selected: isActive,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onNavigate(id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    size: 20,
                    color: isActive ? C.accent : C.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(label, style: inter(fontSize: 10, color: isActive ? C.accent : C.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfettiBurst extends StatefulWidget {
  final Duration delay;
  const ConfettiBurst({super.key, this.delay = const Duration(milliseconds: 200)});
  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;

  static const _colors = [C.accent, C.blue, C.green, C.yellow, C.pink, C.accentLight];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(48, (_) => _Particle(rng));
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..addListener(() => setState(() {}));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl.value == 0) return const SizedBox.expand();
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_particles, _ctrl.value, _colors),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double rotSpeed;
  final double size;
  final int colorIdx;
  final bool isCircle;

  _Particle(Random rng)
      : angle = -pi / 2 + (rng.nextDouble() - 0.5) * pi * 0.8,
        speed = 300 + rng.nextDouble() * 500,
        rotSpeed = (rng.nextDouble() - 0.5) * 12,
        size = 4 + rng.nextDouble() * 6,
        colorIdx = rng.nextInt(6),
        isCircle = rng.nextBool();
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  final List<Color> colors;
  _ConfettiPainter(this.particles, this.t, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.35;
    const gravity = 600.0;
    final fade = t > 0.7 ? 1.0 - (t - 0.7) / 0.3 : 1.0;

    for (final p in particles) {
      final vx = cos(p.angle) * p.speed;
      final vy = sin(p.angle) * p.speed;
      final x = cx + vx * t;
      final y = cy + vy * t + 0.5 * gravity * t * t;
      if (y > size.height + 20) continue;

      final paint = Paint()
        ..color = colors[p.colorIdx].withValues(alpha: fade * 0.9);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotSpeed * t);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
