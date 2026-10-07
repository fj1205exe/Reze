import 'package:flutter/material.dart';
import 'theme.dart';

class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool disabled;
  const PrimaryBtn({super.key, required this.label, this.onPressed, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? C.surface3 : C.accent,
          foregroundColor: disabled ? C.muted : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: disabled ? C.muted : Colors.white, letterSpacing: 0.04)),
      ),
    );
  }
}

class SecondaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const SecondaryBtn({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: C.txt,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: C.txt)),
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                      borderRadius: BorderRadius.circular(8),
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
        return Container(
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
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
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
        borderRadius: BorderRadius.circular(8),
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
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
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
                Icon(isActive ? activeIcon : icon, size: 20, color: isActive ? C.accent : C.muted),
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
