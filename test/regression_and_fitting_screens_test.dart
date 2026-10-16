import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlab/screens/lr_play.dart';
import 'package:mlab/screens/lr_discover.dart';
import 'package:mlab/screens/lr_explain.dart';
import 'package:mlab/screens/lr_challenge.dart';
import 'package:mlab/screens/lr_result.dart';
import 'package:mlab/screens/of_play.dart';
import 'package:mlab/screens/of_discover.dart';
import 'package:mlab/screens/of_explain.dart';
import 'package:mlab/screens/of_challenge.dart';
import 'package:mlab/screens/of_result.dart';
import 'package:mlab/main.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('Regression & Fitting Screens (LR, OF)', () {
    testWidgets('LRPlayScreen slope and intercept adjustment', (WidgetTester tester) async {
      double slope = 0.5;
      double intercept = 0.2;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            LRPlayScreen(
              slope: slope,
              intercept: intercept,
              steps: 0,
              onUpdate: (s, i) => setState(() {
                slope = s;
                intercept = i;
              }),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Linear Regression'), findsOneWidget);
      expect(find.text('Slope'), findsOneWidget);
      expect(find.text('Intercept'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('LRDiscoverScreen gradient step updates slope & intercept', (WidgetTester tester) async {
      double slope = 0.2;
      double intercept = 0.1;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            LRDiscoverScreen(
              slope: slope,
              intercept: intercept,
              lr: 0.1,
              steps: 0,
              onUpdate: (s, i) => setState(() {
                slope = s;
                intercept = i;
              }),
              onGradientStep: (s, i) => setState(() {
                slope = s;
                intercept = i;
              }),
              onLrChange: (_) {},
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Explore slope, intercept & gradient.'), findsOneWidget);
      final stepBtn = find.text('Gradient Step');
      await tester.scrollUntilVisible(stepBtn, 100);
      await tester.tap(stepBtn);
      await tester.pump();

      expect(slope, isNot(equals(0.2)));
      await tester.pumpAndSettle();
    });

    testWidgets('LRExplainScreen presents error formula and terms', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const LRExplainScreen(
          slope: 0.5,
          intercept: 0.2,
          onNext: nullCall,
          onBack: nullCall,
        ),
      ));

      expect(find.text('You just minimized the error.'), findsOneWidget);
      expect(find.text('the formula'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('LRChallengeScreen allows adjusting line to minimize MSE', (WidgetTester tester) async {
      double slope = 0.2;
      double intercept = 0.1;

      await tester.pumpWidget(createTestApp(
        LRChallengeScreen(
          slope: slope,
          intercept: intercept,
          steps: 0,
          onUpdate: (s, i) {
            slope = s;
            intercept = i;
          },
          onComplete: (_, _) {},
          onBack: () {},
        ),
      ));

      expect(find.text('Fit the line.'), findsOneWidget);
      expect(find.text('Slope (m)'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('LRResultScreen presents summary and progress update', (WidgetTester tester) async {
      final progress = AppProgress();

      await tester.pumpWidget(createTestApp(
        LRResultScreen(
          progress: progress,
          onNext: () {},
          onPlayOF: () {},
        ),
      ));

      expect(find.text('CONCEPT CLEAR'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('OFPlayScreen degree slider adjustment', (WidgetTester tester) async {
      int degree = 1;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            OFPlayScreen(
              degree: degree,
              onUpdate: (d) => setState(() => degree = d),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Overfitting'), findsOneWidget);
      expect(find.text('Polynomial degree'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('OFDiscoverScreen shows train/test error split', (WidgetTester tester) async {
      int degree = 1;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            OFDiscoverScreen(
              degree: degree,
              steps: 0,
              onUpdate: (d) => setState(() => degree = d),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Explore model complexity.'), findsOneWidget);
      expect(find.text('Train error'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('OFExplainScreen displays bias-variance tradeoff', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        const OFExplainScreen(
          degree: 3,
          onNext: nullCall,
          onBack: nullCall,
        ),
      ));

      expect(find.text('The bias-variance tradeoff.'), findsOneWidget);
      expect(find.text('THE TRADEOFF'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('OFChallengeScreen challenge setup and degree selection', (WidgetTester tester) async {
      int degree = 15; // High degree so it starts in non-succeeded state

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            OFChallengeScreen(
              degree: degree,
              steps: 0,
              onUpdate: (d) => setState(() => degree = d),
              onComplete: (_, _) {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Find the best degree.'), findsOneWidget);
      expect(find.text('Pick a degree'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('OFResultScreen renders result summary', (WidgetTester tester) async {
      final progress = AppProgress();

      await tester.pumpWidget(createTestApp(
        OFResultScreen(
          progress: progress,
          onNext: () {},
          onPlayLF: () {},
        ),
      ));

      expect(find.text('CONCEPT CLEAR'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}

void nullCall() {}
