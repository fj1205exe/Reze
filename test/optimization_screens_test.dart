import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlab/screens/gd_play.dart';
import 'package:mlab/screens/gd_discover.dart';
import 'package:mlab/screens/gd_explain.dart';
import 'package:mlab/screens/gd_challenge.dart';
import 'package:mlab/screens/sgd_play.dart';
import 'package:mlab/screens/sgd_discover.dart';
import 'package:mlab/screens/sgd_explain.dart';
import 'package:mlab/screens/sgd_challenge.dart';
import 'package:mlab/screens/lf_play.dart';
import 'package:mlab/screens/lf_discover.dart';
import 'package:mlab/screens/lf_explain.dart';
import 'package:mlab/screens/lf_challenge.dart';
import 'package:mlab/utils/sgd.dart' as sgd;

Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('Optimization Screens (GD, SGD, LF)', () {
    testWidgets('GDPlayScreen renders tasks and performs step', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        GDPlayScreen(
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('GRADIENT DESCENT'), findsOneWidget);
      expect(find.text('Step downhill'), findsOneWidget);

      final stepFinder = find.text('Step');
      expect(stepFinder, findsOneWidget);

      await tester.tap(stepFinder);
      await tester.pump();

      expect(find.text('step 1 / 4'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('GDDiscoverScreen renders experiments and handles steps', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        GDDiscoverScreen(
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('DISCOVER'), findsOneWidget);
      expect(find.text('Experiment 1: Tiny steps'), findsOneWidget);

      final stepFinder = find.text('Step');
      await tester.tap(stepFinder);
      await tester.pump();

      expect(find.text('Steps'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('GDExplainScreen renders symbol cards and quiz', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        GDExplainScreen(
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('You just performed\nGradient Descent.'), findsOneWidget);
      expect(find.text('THE UPDATE RULE'), findsOneWidget);

      final revealFinder = find.text('Reveal next symbol');
      await tester.scrollUntilVisible(revealFinder, 100);
      await tester.tap(revealFinder);
      await tester.pump();
      await tester.pumpAndSettle();
    });

    testWidgets('GDChallengeScreen renders round and allows stepping', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        GDChallengeScreen(
          onComplete: (_, _, _) {},
          onBack: () {},
        ),
      ));

      expect(find.text('CHALLENGE'), findsOneWidget);
      expect(find.text('Round 1: Speed'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('SGDPlayScreen steps and batch selection', (WidgetTester tester) async {
      int stepCount = 0;
      sgd.BatchSize currentBatch = sgd.BatchSize.mini;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            SGDPlayScreen(
              theta: 5.0,
              history: const [],
              steps: stepCount,
              lr: 0.3,
              batchSize: currentBatch,
              onStep: () => setState(() => stepCount++),
              onLrChange: (_) {},
              onBatchChange: (b) => setState(() => currentBatch = b),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('How noisy should your gradient be?'), findsOneWidget);
      final stepFinder = find.text('STEP (SGD)');
      await tester.scrollUntilVisible(stepFinder, 100);
      await tester.tap(stepFinder);
      await tester.pump();
      expect(stepCount, equals(1));
      await tester.pumpAndSettle();
    });

    testWidgets('SGDDiscoverScreen renders noise comparison', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        SGDDiscoverScreen(
          theta: 5.0,
          history: const [6.0, 5.5],
          lr: 0.3,
          batchSize: sgd.BatchSize.mini,
          onStep: () {},
          onLrChange: (_) {},
          onBatchChange: (_) {},
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('How noise changes learning.'), findsOneWidget);
      expect(find.text('Mini'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('SGDExplainScreen renders benefits and tradeoffs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        SGDExplainScreen(
          theta: 5.0,
          history: const [],
          batchSize: sgd.BatchSize.mini,
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('Noise is a feature, not a bug.'), findsOneWidget);
      expect(find.text('TAKE THE CHALLENGE'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('SGDChallengeScreen renders challenge setup', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        SGDChallengeScreen(
          onComplete: (_, _, _) {},
          onBack: () {},
        ),
      ));

      expect(find.text('Converge in 15 steps.'), findsOneWidget);
      expect(find.text('Step'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('LFPlayScreen calculates loss and switches loss types', (WidgetTester tester) async {
      String selectedLoss = 'mse';
      double pred = 0.2;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            LFPlayScreen(
              selectedLoss: selectedLoss,
              prediction: pred,
              onUpdate: (p, l) => setState(() {
                pred = p;
                selectedLoss = l;
              }),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Which loss hurts more?'), findsOneWidget);
      expect(find.text('MSE'), findsOneWidget);

      await tester.tap(find.text('MAE'));
      await tester.pump();
      expect(selectedLoss, equals('mae'));
      await tester.pumpAndSettle();
    });

    testWidgets('LFDiscoverScreen toggles outlier and renders plot', (WidgetTester tester) async {
      String selectedLoss = 'mse';
      double pred = 0.2;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            LFDiscoverScreen(
              selectedLoss: selectedLoss,
              prediction: pred,
              onUpdate: (p, l) => setState(() {
                pred = p;
                selectedLoss = l;
              }),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Why do different losses exist?'), findsOneWidget);
      expect(find.text('Tap to add an outlier'), findsOneWidget);

      await tester.tap(find.text('Tap to add an outlier'));
      await tester.pump();

      expect(find.textContaining('Outlier at'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('LFExplainScreen presents loss formula and term breakdown', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        LFExplainScreen(
          selectedLoss: 'mse',
          prediction: 0.2,
          onNext: () {},
          onBack: () {},
        ),
      ));

      expect(find.text('Measuring mistakes.'), findsOneWidget);
      expect(find.text('anatomy of the loss'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('LFChallengeScreen scenario selection and grading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        LFChallengeScreen(
          onComplete: (_, _, _) {},
          onBack: () {},
        ),
      ));

      expect(find.textContaining('Loss Functions'), findsOneWidget);
      expect(find.text('Mean Squared Error'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
