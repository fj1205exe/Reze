import 'dart:math';

const double tMin = 0;
const double tMax = 10;
const double trueMin = 5.2;
const double convergenceRadius = 0.15;
const double challengeStart = 8.5;
const double playStart = 1.5;

double lossFunc(double t) {
  return 0.25 * pow(t - trueMin, 2) + 1.2;
}

double gradientOf(double t) {
  return 0.5 * (t - trueMin);
}

double gdStep(double theta, double lr) {
  return theta - lr * gradientOf(theta);
}

double clamp(double val, double lo, double hi) {
  return max(lo, min(hi, val));
}

bool isConverged(double theta) {
  return (theta - trueMin).abs() < convergenceRadius;
}

bool isOvershoot(double prev, double next) {
  return lossFunc(next) > lossFunc(prev) + 0.001;
}

List<Map<String, double>> sampleCurve([int n = 300]) {
  return List.generate(n + 1, (i) {
    final t = tMin + (i / n) * (tMax - tMin);
    return {'t': t, 'loss': lossFunc(t)};
  });
}

final List<Map<String, double>> _samples = sampleCurve(500);
final double curveLossMin =
    _samples.map((s) => s['loss']!).reduce(min);
final double curveLossMax =
    _samples.map((s) => s['loss']!).reduce(max);
