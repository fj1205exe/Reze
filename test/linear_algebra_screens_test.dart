import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlab/screens/vec_play.dart';
import 'package:mlab/screens/vec_discover.dart';
import 'package:mlab/screens/vec_explain.dart';
import 'package:mlab/screens/vec_challenge.dart';
import 'package:mlab/screens/vec_result.dart';
import 'package:mlab/screens/dot_play.dart';
import 'package:mlab/screens/dot_discover.dart';
import 'package:mlab/screens/dot_explain.dart';
import 'package:mlab/screens/dot_challenge.dart';
import 'package:mlab/screens/dot_result.dart';
import 'package:mlab/main.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('Linear Algebra Screens (VEC, DOT)', () {
    testWidgets('VECPlayScreen canvas interaction and vector inspection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        VECPlayScreen(
          ax: 0.8, ay: 0.6,
          bx: -0.5, by: 0.9,
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('Vectors in 2D space.'), findsOneWidget);
      expect(find.text('Vector a'), findsOneWidget);
      expect(find.text('Vector b'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('VECDiscoverScreen sum/diff toggles and vector controls', (WidgetTester tester) async {
      bool sumToggled = false;
      bool diffToggled = false;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            VECDiscoverScreen(
              ax: 0.8, ay: 0.6,
              bx: -0.5, by: 0.9,
              showSum: sumToggled,
              showDiff: diffToggled,
              onUpdateA: (_, _) {},
              onUpdateB: (_, _) {},
              onToggleSum: () => setState(() => sumToggled = !sumToggled),
              onToggleDiff: () => setState(() => diffToggled = !diffToggled),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Explore vector operations.'), findsOneWidget);
      final sumBtn = find.textContaining('Show a + b');
      await tester.scrollUntilVisible(sumBtn, 100);
      await tester.tap(sumBtn);
      await tester.pump();

      expect(sumToggled, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('VECExplainScreen presents addition and scaling rules', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        VECExplainScreen(
          ax: 0.8, ay: 0.6,
          bx: -0.5, by: 0.9,
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('Everything in ML is a vector.'), findsOneWidget);
      expect(find.text('THE VECTOR'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('VECChallengeScreen vector magnitude challenge', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        VECChallengeScreen(
          ax: 1.0, ay: 0.0,
          targetMag: 5.0,
          steps: 0,
          onUpdateA: (_, _) {},
          onComplete: (_, _) {},
          onBack: () {},
          onRetry: () {},
        ),
      ));

      expect(find.text('Match the target magnitude.'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('VECResultScreen displays completion state', (WidgetTester tester) async {
      final progress = AppProgress();

      await tester.pumpWidget(createTestApp(
        VECResultScreen(
          progress: progress,
          onNext: () {},
          onPlayDOT: () {},
        ),
      ));

      expect(find.text('CONCEPT CLEAR'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('DOTPlayScreen renders angle sliders and dot product', (WidgetTester tester) async {
      double angleA = 30;
      double angleB = 100;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            DOTPlayScreen(
              angleA: angleA,
              angleB: angleB,
              onUpdate: (aA, aB, mA, mB) => setState(() {
                angleA = aA;
                angleB = aB;
              }),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Measuring alignment.'), findsOneWidget);
      expect(find.text('Dot product a · b'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('DOTDiscoverScreen renders magnitude & angle controls', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        DOTDiscoverScreen(
          angleA: 30, angleB: 100,
          magA: 1.0, magB: 1.0,
          steps: 0,
          onUpdate: (_, _, _, _) {},
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('Explore angle and magnitude.'), findsOneWidget);
      expect(find.text('cos(θ)'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('DOTExplainScreen presents dot product formula', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        DOTExplainScreen(
          angleA: 30, angleB: 100,
          magA: 1.0, magB: 1.0,
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('The engine of ML.'), findsOneWidget);
      expect(find.text('two faces of the same operation'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('DOTChallengeScreen scenario quiz and evaluation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        DOTChallengeScreen(
          angleA: 30, angleB: 100,
          magA: 1.0, magB: 1.0,
          steps: 0,
          onUpdate: (_, _, _, _) {},
          onComplete: (_, _) {},
          onBack: () {},
        ),
      ));

      expect(find.text('Find perpendicular.'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('DOTResultScreen displays completion summary', (WidgetTester tester) async {
      final progress = AppProgress();

      await tester.pumpWidget(createTestApp(
        DOTResultScreen(
          progress: progress,
          onNext: () {},
          onPlayPR: () {},
        ),
      ));

      expect(find.text('CONCEPT CLEAR'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
