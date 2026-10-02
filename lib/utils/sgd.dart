import 'dart:math';
import 'gd.dart';

enum BatchSize { full, mini, stochastic }

const Map<BatchSize, double> noiseFactor = {
  BatchSize.full: 0,
  BatchSize.mini: 0.15,
  BatchSize.stochastic: 0.4,
};

const Map<BatchSize, String> batchLabels = {
  BatchSize.full: 'Full batch (GD)',
  BatchSize.mini: 'Mini-batch (SGD)',
  BatchSize.stochastic: 'Single sample',
};

const Map<BatchSize, String> batchColors = {
  BatchSize.full: '#8B5CF6',
  BatchSize.mini: '#38BDF8',
  BatchSize.stochastic: '#FBBF24',
};

const Map<BatchSize, String> batchDescription = {
  BatchSize.full: 'Exact gradient. Slow but precise.',
  BatchSize.mini: 'Averaged over a subset. Fast and usually good enough.',
  BatchSize.stochastic: 'One sample at a time. Noisy but fast.',
};

final _rng = Random();

double sgdStep(double theta, double lr, BatchSize batchSize) {
  final noise = noiseFactor[batchSize]!;
  final noiseVal = noise == 0 ? 0.0 : (_rng.nextDouble() - 0.5) * 2 * noise;
  return gdStep(theta, lr) + noiseVal;
}
