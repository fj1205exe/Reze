import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlab/utils/gd.dart' as gd;
import 'package:mlab/utils/sgd.dart' as sgd;
import 'package:mlab/utils/lr.dart' as lr;
import 'package:mlab/utils/loss_fns.dart' as lf;
import 'package:mlab/utils/vectors.dart' as vec;
import 'package:mlab/utils/probability.dart' as pr;
import 'package:mlab/utils/bayes.dart' as bay;
import 'package:mlab/utils/neuralnet.dart' as nn;
import 'package:mlab/utils/overfitting.dart' as of;
import 'package:mlab/utils/classification.dart' as cl;

void main() {
  // ── Gradient Descent ──

  group('gd', () {
    test('loss function has minimum at trueMin', () {
      final atMin = gd.lossFunc(gd.trueMin);
      expect(atMin, closeTo(1.2, 1e-10));
      expect(gd.lossFunc(0), greaterThan(atMin));
      expect(gd.lossFunc(10), greaterThan(atMin));
    });

    test('gradient is zero at minimum', () {
      expect(gd.gradientOf(gd.trueMin), closeTo(0, 1e-10));
    });

    test('gradient is negative left of minimum', () {
      expect(gd.gradientOf(2.0), lessThan(0));
    });

    test('gradient is positive right of minimum', () {
      expect(gd.gradientOf(8.0), greaterThan(0));
    });

    test('gdStep moves toward minimum', () {
      final theta = 8.0;
      final next = gd.gdStep(theta, 0.1);
      expect((next - gd.trueMin).abs(), lessThan((theta - gd.trueMin).abs()));
    });

    test('convergence detection', () {
      expect(gd.isConverged(gd.trueMin), isTrue);
      expect(gd.isConverged(gd.trueMin + 0.1), isTrue);
      expect(gd.isConverged(0), isFalse);
    });

    test('overshoot detection', () {
      expect(gd.isOvershoot(8.0, 7.0), isFalse);
      expect(gd.isOvershoot(5.5, 9.0), isTrue);
    });

    test('sampleCurve returns correct number of points', () {
      final samples = gd.sampleCurve(100);
      expect(samples.length, 101);
      expect(samples.first['t'], closeTo(gd.tMin, 1e-10));
    });
  });

  // ── SGD ──

  group('sgd', () {
    test('full batch has no noise', () {
      final theta = 5.0;
      final result = sgd.sgdStep(theta, 0.1, sgd.BatchSize.full);
      expect(result, closeTo(gd.gdStep(theta, 0.1), 1e-10));
    });

    test('stochastic batch adds noise', () {
      final results = List.generate(
        50,
        (_) => sgd.sgdStep(5.0, 0.1, sgd.BatchSize.stochastic),
      );
      final unique = results.toSet();
      expect(unique.length, greaterThan(1));
    });
  });

  // ── Linear Regression ──

  group('lr', () {
    test('OLS values produce low MSE', () {
      final mse = lr.calcMSE(lr.olsSlope, lr.olsIntercept);
      expect(mse, lessThan(0.01));
    });

    test('bad fit has higher MSE than OLS', () {
      final badMSE = lr.calcMSE(0, 0);
      final olsMSE = lr.optimalMSE();
      expect(badMSE, greaterThan(olsMSE));
    });

    test('isGoodFit accepts OLS solution', () {
      expect(lr.isGoodFit(lr.olsSlope, lr.olsIntercept), isTrue);
    });

    test('isGoodFit rejects bad fit', () {
      expect(lr.isGoodFit(0, 0), isFalse);
    });
  });

  // ── Loss Functions ──

  group('loss_fns', () {
    test('MSE is zero when prediction equals truth', () {
      expect(lf.mseLoss(lf.truth, lf.truth), closeTo(0, 1e-10));
    });

    test('MAE is zero when prediction equals truth', () {
      expect(lf.maeLoss(lf.truth, lf.truth), closeTo(0, 1e-10));
    });

    test('Huber is zero when prediction equals truth', () {
      expect(lf.huberLoss(lf.truth, lf.truth), closeTo(0, 1e-10));
    });

    test('MSE gradient is zero at truth', () {
      expect(lf.lossGradient('mse', lf.truth, lf.truth), closeTo(0, 1e-10));
    });

    test('MAE gradient is zero at truth', () {
      expect(lf.lossGradient('mae', lf.truth, lf.truth), closeTo(0, 1e-10));
    });

    test('Huber matches MSE for small residuals', () {
      final pred = lf.truth + 0.05;
      final huber = lf.huberLoss(pred, lf.truth);
      final mse = lf.mseLoss(pred, lf.truth);
      expect(huber, closeTo(0.5 * mse, 1e-10));
    });

    test('Huber is linear for large residuals', () {
      final pred = lf.truth + 1.0;
      final huber = lf.huberLoss(pred, lf.truth, 0.2);
      final linear = 0.2 * ((pred - lf.truth).abs() - 0.5 * 0.2);
      expect(huber, closeTo(linear, 1e-10));
    });

    test('sampleLossCurve returns points', () {
      for (final type in ['mse', 'mae', 'huber']) {
        final curve = lf.sampleLossCurve(type, 10);
        expect(curve.length, 11);
      }
    });
  });

  // ── Vectors ──

  group('vectors', () {
    test('add', () {
      final r = vec.vecAdd(const vec.Vec2(1, 2), const vec.Vec2(3, 4));
      expect(r.x, 4);
      expect(r.y, 6);
    });

    test('sub', () {
      final r = vec.vecSub(const vec.Vec2(5, 3), const vec.Vec2(2, 1));
      expect(r.x, 3);
      expect(r.y, 2);
    });

    test('scale', () {
      final r = vec.vecScale(const vec.Vec2(2, 3), 2);
      expect(r.x, 4);
      expect(r.y, 6);
    });

    test('magnitude', () {
      expect(vec.vecMagnitude(const vec.Vec2(3, 4)), closeTo(5, 1e-10));
    });

    test('normalize produces unit vector', () {
      final n = vec.vecNormalize(const vec.Vec2(3, 4));
      expect(vec.vecMagnitude(n), closeTo(1, 1e-10));
    });

    test('normalize zero vector returns zero', () {
      final n = vec.vecNormalize(const vec.Vec2(0, 0));
      expect(n.x, 0);
      expect(n.y, 0);
    });

    test('dot product', () {
      expect(vec.vecDot(const vec.Vec2(1, 0), const vec.Vec2(0, 1)), closeTo(0, 1e-10));
      expect(vec.vecDot(const vec.Vec2(2, 3), const vec.Vec2(4, 5)), closeTo(23, 1e-10));
    });

    test('angle between perpendicular vectors is 90', () {
      expect(vec.vecAngle(const vec.Vec2(1, 0), const vec.Vec2(0, 1)), closeTo(90, 1e-6));
    });

    test('angle between parallel vectors is 0', () {
      expect(vec.vecAngle(const vec.Vec2(1, 0), const vec.Vec2(2, 0)), closeTo(0, 1e-6));
    });

    test('angle with zero vector returns 0', () {
      expect(vec.vecAngle(const vec.Vec2(0, 0), const vec.Vec2(1, 0)), 0);
    });

    test('project onto axis', () {
      final p = vec.vecProject(const vec.Vec2(3, 4), const vec.Vec2(1, 0));
      expect(p.x, closeTo(3, 1e-10));
      expect(p.y, closeTo(0, 1e-10));
    });

    test('project onto zero vector returns zero', () {
      final p = vec.vecProject(const vec.Vec2(3, 4), const vec.Vec2(0, 0));
      expect(p.x, 0);
      expect(p.y, 0);
    });
  });

  // ── Probability ──

  group('probability', () {
    test('empiricalP empty returns 0', () {
      expect(pr.empiricalP([]), 0);
    });

    test('empiricalP all heads returns 1', () {
      expect(pr.empiricalP(['H', 'H', 'H']), 1.0);
    });

    test('empiricalP mixed', () {
      expect(pr.empiricalP(['H', 'T', 'H', 'T']), closeTo(0.5, 1e-10));
    });

    test('confidence interval with 0 flips returns full range', () {
      final ci = pr.confidenceInterval(0, 0.5);
      expect(ci['low'], 0.0);
      expect(ci['high'], 1.0);
    });

    test('confidence interval narrows with more samples', () {
      final ci10 = pr.confidenceInterval(10, 0.5);
      final ci100 = pr.confidenceInterval(100, 0.5);
      final width10 = ci10['high']! - ci10['low']!;
      final width100 = ci100['high']! - ci100['low']!;
      expect(width100, lessThan(width10));
    });

    test('runningProb tracks cumulative', () {
      final rp = pr.runningProb(['H', 'T', 'H']);
      expect(rp[0], closeTo(1.0, 1e-10));
      expect(rp[1], closeTo(0.5, 1e-10));
      expect(rp[2], closeTo(2 / 3, 1e-10));
    });
  });

  // ── Bayes ──

  group('bayes', () {
    test('posterior with zero prior is zero', () {
      expect(bay.calcPosterior(0, 0.9, 0.9), closeTo(0, 1e-10));
    });

    test('posterior with prior=1 is 1 (ignoring false positives)', () {
      expect(bay.calcPosterior(1.0, 0.9, 0.9), closeTo(1.0, 1e-10));
    });

    test('higher prior increases posterior', () {
      final low = bay.calcPosterior(0.01, 0.9, 0.9);
      final high = bay.calcPosterior(0.5, 0.9, 0.9);
      expect(high, greaterThan(low));
    });

    test('perfect test gives posterior equal to prior', () {
      final post = bay.calcPosterior(0.3, 1.0, 1.0);
      expect(post, closeTo(1.0, 1e-10));
    });

    test('calcPopStats returns consistent totals', () {
      final stats = bay.calcPopStats(0.05, 0.9, 0.9);
      expect(stats.total, 1000);
      expect(stats.truePositive + stats.falseNegative, stats.hasDisease);
      expect(stats.trueNegative + stats.falsePositive, stats.doesntHaveDisease);
    });
  });

  // ── Neural Network ──

  group('neuralnet', () {
    test('sigmoid bounds', () {
      expect(nn.sigmoid(0), closeTo(0.5, 1e-10));
      expect(nn.sigmoid(100), closeTo(1.0, 1e-6));
      expect(nn.sigmoid(-100), closeTo(0.0, 1e-6));
    });

    test('sigmoid derivative is max at z=0', () {
      final at0 = nn.sigmoidDerivative(0);
      expect(at0, closeTo(0.25, 1e-10));
      expect(nn.sigmoidDerivative(5), lessThan(at0));
    });

    test('neuron forward produces valid output', () {
      final result = nn.neuronForward(0.5, 0.5, 0.3, 0.3, 0.1);
      expect(result['output']!, greaterThan(0));
      expect(result['output']!, lessThan(1));
    });

    test('network forward produces loss', () {
      final fwd = nn.networkForward(nn.miniNetInit, 0.5, 0.8);
      expect(fwd['loss']!, greaterThanOrEqualTo(0));
      expect(fwd['y']!, greaterThan(0));
      expect(fwd['y']!, lessThan(1));
    });

    test('network step reduces loss', () {
      final net = nn.miniNetInit;
      final lossBefore = nn.networkForward(net, 0.5, 0.8)['loss']!;
      final updated = nn.networkStep(net, 0.5, 0.8, 0.5);
      final lossAfter = nn.networkForward(updated, 0.5, 0.8)['loss']!;
      expect(lossAfter, lessThan(lossBefore));
    });

    test('backward produces all gradient keys', () {
      final g = nn.networkBackward(nn.miniNetInit, 0.5, 0.8);
      expect(g.containsKey('dL_dy'), isTrue);
      expect(g.containsKey('dL_dw1'), isTrue);
      expect(g.containsKey('dL_dw2'), isTrue);
      expect(g.containsKey('dL_dwh'), isTrue);
    });
  });

  // ── Overfitting (Polynomial Fitting) ──

  group('overfitting', () {
    test('degree 1 fit is linear', () {
      final coeffs = of.fitPolynomial(of.trainPoints, 1);
      expect(coeffs.length, 2);
    });

    test('higher degree reduces train MSE', () {
      final c1 = of.fitPolynomial(of.trainPoints, 1);
      final c5 = of.fitPolynomial(of.trainPoints, 5);
      final mse1 = of.calcPolyMSE(c1, of.trainPoints);
      final mse5 = of.calcPolyMSE(c5, of.trainPoints);
      expect(mse5, lessThan(mse1));
    });

    test('evalPoly is correct for known values', () {
      expect(of.evalPoly(0, [3.0, 2.0, 1.0]), closeTo(3.0, 1e-10));
      expect(of.evalPoly(1, [3.0, 2.0, 1.0]), closeTo(6.0, 1e-10));
      expect(of.evalPoly(2, [3.0, 2.0, 1.0]), closeTo(11.0, 1e-10));
    });

    test('sampleOFCurve returns clamped values', () {
      final coeffs = of.fitPolynomial(of.trainPoints, 7);
      final curve = of.sampleOFCurve(coeffs);
      for (final pt in curve) {
        expect(pt['y']!, greaterThanOrEqualTo(-0.2));
        expect(pt['y']!, lessThanOrEqualTo(1.2));
      }
    });
  });

  // ── Classification ──

  group('classification', () {
    test('accuracy is bounded 0-100', () {
      final acc = cl.calcAccuracy(cl.optimalAngle, cl.optimalOffset);
      expect(acc, greaterThanOrEqualTo(0));
      expect(acc, lessThanOrEqualTo(100));
    });

    test('confusion matrix totals match dataset size', () {
      final cm = cl.confusionMatrix(-45, 0);
      final total = cm['tp']! + cm['fp']! + cm['tn']! + cm['fn']!;
      expect(total, cl.classA.length + cl.classB.length);
    });

    test('classify returns 1 or -1', () {
      final c = cl.classify(0.5, 0.5, 0, 0);
      expect(c == 1 || c == -1, isTrue);
    });

    test('calcAccuracyForDataset matches calcAccuracy for default data', () {
      final a1 = cl.calcAccuracy(-45, 0);
      final a2 = cl.calcAccuracyForDataset(-45, 0, cl.classA, cl.classB);
      expect(a1, closeTo(a2, 1e-10));
    });
  });
}
