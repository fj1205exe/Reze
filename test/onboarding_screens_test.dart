import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlab/main.dart';
import 'package:mlab/screens/splash_screen.dart';
import 'package:mlab/screens/welcome_screen.dart';
import 'package:mlab/screens/goal_screen.dart';
import 'package:mlab/screens/diagnostic_screen.dart';
import 'package:mlab/screens/skill_map_screen.dart';
import 'package:mlab/utils/comprehension.dart';
import 'package:mlab/screens/home_screen.dart';
import 'package:mlab/screens/map_tab.dart';
import 'package:mlab/screens/progress_tab.dart';
import 'package:mlab/screens/result_screen.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('Onboarding & App Core Navigation Screens', () {
    testWidgets('SplashScreen displays correctly and handles tap/timer', (WidgetTester tester) async {
      bool nextCalled = false;
      await tester.pumpWidget(createTestApp(
        SplashScreen(onNext: () => nextCalled = true),
      ));

      expect(find.text('MLab'), findsOneWidget);
      expect(find.text('Learn ML by playing with the math.'), findsOneWidget);

      await tester.tap(find.byType(SplashScreen));
      await tester.pumpAndSettle();
      expect(nextCalled, isTrue);
    });

    testWidgets('WelcomeScreen renders key text and triggers Get Started', (WidgetTester tester) async {
      bool nextCalled = false;
      await tester.pumpWidget(createTestApp(
        WelcomeScreen(onNext: () => nextCalled = true),
      ));

      expect(find.text("Math shouldn't feel like memorizing."), findsOneWidget);
      expect(find.text('Play with it.'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(nextCalled, isTrue);
    });

    testWidgets('GoalScreen options selection and continue action', (WidgetTester tester) async {
      String selectedGoal = '';
      bool nextCalled = false;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            GoalScreen(
              goal: selectedGoal,
              onSelect: (g) => setState(() => selectedGoal = g),
              onNext: () => nextCalled = true,
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('What do you want to get better at?'), findsOneWidget);
      expect(find.text('Understand ML fundamentals'), findsOneWidget);

      // Select an option
      await tester.tap(find.text('Understand ML fundamentals'));
      await tester.pump();
      expect(selectedGoal, equals('fundamentals'));

      // Tap CONTINUE
      final continueFinder = find.text('CONTINUE');
      await tester.scrollUntilVisible(continueFinder, 100);
      await tester.tap(continueFinder);
      await tester.pumpAndSettle();
      expect(nextCalled, isTrue);
    });

    testWidgets('DiagnosticScreen preference answers and level computation', (WidgetTester tester) async {
      ComprehensionLevel? finalLevel;

      await tester.pumpWidget(createTestApp(
        DiagnosticScreen(
          onNext: (level) => finalLevel = level,
          onBack: () {},
        ),
      ));

      expect(find.text('About You'), findsOneWidget);
      expect(find.text('Which explanation clicks for you?'), findsOneWidget);

      // Answer question 1 — pick second option then change to advanced option
      await tester.tap(find.text('The algorithm reduces error by adjusting values step by step'));
      await tester.pump();
      await tester.tap(find.text('Parameters are iteratively updated via the negative gradient of the loss'));
      await tester.pump();

      // Advance to Q2
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Pick the version that feels easiest to read:'), findsOneWidget);

      // Answer question 2 — pick advanced option
      await tester.tap(find.text('α scales the gradient: θ ← θ − α∇L(θ)'));
      await tester.pump();

      // Advance to Q3
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('How would you find the best price for a product?'), findsOneWidget);

      // Answer question 3 — pick advanced option
      await tester.tap(find.text('Model demand as f(p) and optimize revenue = p · f(p)'));
      await tester.pump();

      // Finish diagnostic
      await tester.tap(find.text('SEE YOUR MAP'));
      await tester.pumpAndSettle();
      expect(finalLevel, ComprehensionLevel.advanced);
    });

    testWidgets('SkillMapScreen displays skill progress and map', (WidgetTester tester) async {
      bool nextCalled = false;

      final mockSkillMap = {
        'Algebra': 72,
        'Functions': 58,
        'Vectors': 45,
        'Probability': 61,
        'Statistics': 54,
        'Calculus': 25,
        'Optimization': 45,
      };

      await tester.pumpWidget(createTestApp(
        SkillMapScreen(
          skillMap: mockSkillMap,
          mode: 'onboarding',
          onNext: () => nextCalled = true,
          onBack: () {},
        ),
      ));

      expect(find.text('Your math map'), findsOneWidget);
      expect(find.text('Algebra'), findsOneWidget);

      final continueFinder = find.text('Continue');
      await tester.scrollUntilVisible(continueFinder, 100);
      await tester.tap(continueFinder);
      await tester.pumpAndSettle();
      expect(nextCalled, isTrue);
    });

    testWidgets('HomeScreen renders dashboard and navigation bar', (WidgetTester tester) async {
      AppScreen? navigatedScreen;

      final progress = AppProgress(
        skillMap: {'Optimization': 50, 'Calculus': 30},
      );

      await tester.pumpWidget(createTestApp(
        HomeScreen(
          progress: progress,
          onNavigate: (s) => navigatedScreen = s,
        ),
      ));

      expect(find.text("What's next?"), findsOneWidget);
      expect(find.text('Gradient Descent'), findsOneWidget);

      // Tap on navigation tab Map
      await tester.tap(find.byIcon(Icons.explore_outlined));
      await tester.pumpAndSettle();
      expect(navigatedScreen, equals(AppScreen.mapTab));
    });

    testWidgets('MapTabScreen lists all concepts', (WidgetTester tester) async {
      AppScreen? navigatedScreen;
      final progress = AppProgress();

      await tester.pumpWidget(createTestApp(
        MapTabScreen(
          progress: progress,
          onNavigate: (s) => navigatedScreen = s,
        ),
      ));

      expect(find.text('Concept Map'), findsOneWidget);
      expect(find.text('Gradient Descent'), findsOneWidget);
      expect(find.text('Linear Regression'), findsOneWidget);

      await tester.tap(find.text('Gradient Descent'));
      await tester.pumpAndSettle();
      expect(navigatedScreen, equals(AppScreen.gdPlay));
    });

    testWidgets('ProgressTabScreen shows progress metrics and skills', (WidgetTester tester) async {
      final progress = AppProgress();

      await tester.pumpWidget(createTestApp(
        ProgressTabScreen(
          skillMap: progress.skillMap,
          progress: progress,
          onNavigate: (_) {},
        ),
      ));

      expect(find.text('Progress'), findsWidgets);
      expect(find.text('Concepts completed'), findsOneWidget);
      expect(find.text('Skills'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('ResultScreen displays completion summary and actions', (WidgetTester tester) async {
      bool playLRCalled = false;

      await tester.pumpWidget(createTestApp(
        ResultScreen(
          roundsPassed: 4,
          totalRounds: 5,
          totalSteps: 12,
          succeeded: true,
          onNext: () {},
          onPlayLR: () => playLRCalled = true,
          onRetry: () {},
        ),
      ));

      expect(find.text('CONCEPT CLEAR'), findsOneWidget);
      expect(find.text('Gradient Descent'), findsOneWidget);

      final nextFinder = find.text('Play next →');
      await tester.scrollUntilVisible(nextFinder, 100);
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      expect(playLRCalled, isTrue);
    });
  });
}
