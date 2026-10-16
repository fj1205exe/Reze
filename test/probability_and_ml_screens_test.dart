import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlab/screens/cl_play.dart';
import 'package:mlab/screens/pr_play.dart';
import 'package:mlab/screens/bay_play.dart';
import 'package:mlab/screens/nn_play.dart';
import 'package:mlab/screens/bp_play.dart';
import 'package:mlab/utils/neuralnet.dart' as nn_utils;

Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('Probability & ML Screens (CL, PR, BAY, NN, BP)', () {
    testWidgets('CLPlayScreen boundary angle adjustment', (WidgetTester tester) async {
      double angle = 0;
      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            CLPlayScreen(
              angle: angle,
              onUpdate: (a, o) => setState(() => angle = a),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Rotate the boundary.'), findsOneWidget);
      expect(find.text('Angle'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('PRPlayScreen coin flip simulation', (WidgetTester tester) async {
      List<String> flips = [];

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            PRPlayScreen(
              flips: flips,
              onFlip: () => setState(() => flips.add('H')),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Flip a fair coin.'), findsOneWidget);
      await tester.tap(find.text('Flip'));
      await tester.pump();

      expect(flips.length, equals(1));
      await tester.pumpAndSettle();
    });

    testWidgets('BAYPlayScreen base rate fallacy quiz and sliders', (WidgetTester tester) async {
      double prior = 0.01;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            BAYPlayScreen(
              prior: prior,
              sensitivity: 0.95,
              specificity: 0.95,
              onUpdate: (p, se, sp) => setState(() => prior = p),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('The Base Rate Fallacy'), findsOneWidget);
      expect(find.text('~16%'), findsOneWidget);

      await tester.tap(find.text('~16%'));
      await tester.pump();

      expect(find.text('CONFIRM GUESS'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('NNPlayScreen single neuron XOR limitation', (WidgetTester tester) async {
      double w1 = 0.5;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            NNPlayScreen(
              w1: w1,
              w2: 0.5,
              bias: -0.2,
              x1: 1.0,
              x2: 0.0,
              onUpdate: (v1, v2, b) => setState(() => w1 = v1),
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Can a single neuron solve XOR?'), findsOneWidget);
      expect(find.text('Weight w₁'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('BPPlayScreen backprop step sequence', (WidgetTester tester) async {
      nn_utils.BPState bpState = nn_utils.bpInit;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return createTestApp(
            BPPlayScreen(
              bp: bpState,
              onStep: () => setState(() => bpState = bpState.copyWith(step: (bpState.step + 1) % 5)),
              onTrain: () {},
              onReset: () {},
              onNext: () {},
              onBack: () {},
            ),
          );
        },
      ));

      expect(find.text('Forward, then backward.'), findsOneWidget);
      expect(find.text('NEXT STEP IN BACKPROP'), findsOneWidget);

      await tester.tap(find.text('NEXT STEP IN BACKPROP'));
      await tester.pump();

      expect(bpState.step, equals(1));
      await tester.pumpAndSettle();
    });
  });
}
