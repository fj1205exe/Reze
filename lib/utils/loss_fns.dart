import 'dart:math';

const double truth = 0.62;

const Map<String, String> lossNames = {
  'mse': 'MSE', 'mae': 'MAE', 'huber': 'Huber',
};

const Map<String, int> lossColors = {
  'mse': 0xFF8B5CF6, 'mae': 0xFF38BDF8, 'huber': 0xFFFBBF24,
};

const Map<String, String> lossDescriptions = {
  'mse': 'Mean Squared Error — penalizes large errors heavily',
  'mae': 'Mean Absolute Error — robust to outliers',
  'huber': 'Huber — squared near zero, linear for large errors',
};

double mseLoss(double pred, double t) => pow(pred - t, 2).toDouble();

double maeLoss(double pred, double t) => (pred - t).abs();

double huberLoss(double pred, double t, [double delta = 0.2]) {
  final r = pred - t;
  final absR = r.abs();
  if (absR <= delta) return 0.5 * r * r;
  return delta * (absR - 0.5 * delta);
}

double lossGradient(String type, double pred, double t, [double delta = 0.2]) {
  final r = pred - t;
  if (type == 'mse') return 2 * r;
  if (type == 'mae') {
    if (r > 0) return 1;
    if (r < 0) return -1;
    return 0;
  }
  final absR = r.abs();
  if (absR <= delta) return r;
  return delta * r.sign;
}

List<Map<String, double>> sampleLossCurve(String type, [int numPoints = 80]) {
  return List.generate(numPoints + 1, (i) {
    final x = i / numPoints;
    double loss;
    if (type == 'mse') {
      loss = mseLoss(x, truth);
    } else if (type == 'mae') {
      loss = maeLoss(x, truth);
    } else {
      loss = huberLoss(x, truth);
    }
    return {'x': x, 'loss': loss};
  });
}
