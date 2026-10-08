import 'package:flutter/widgets.dart';
import '../main.dart';

class LevelProvider extends InheritedWidget {
  final ComprehensionLevel level;

  const LevelProvider({
    super.key,
    required this.level,
    required super.child,
  });

  static ComprehensionLevel of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<LevelProvider>();
    return provider?.level ?? ComprehensionLevel.beginner;
  }

  @override
  bool updateShouldNotify(LevelProvider oldWidget) => level != oldWidget.level;
}

T tiered<T>(BuildContext context, {required T beginner, required T intermediate, required T advanced}) {
  switch (LevelProvider.of(context)) {
    case ComprehensionLevel.beginner:
      return beginner;
    case ComprehensionLevel.intermediate:
      return intermediate;
    case ComprehensionLevel.advanced:
      return advanced;
  }
}
