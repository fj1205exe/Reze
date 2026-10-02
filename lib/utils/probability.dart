import 'dart:math';

class PRState {
  final double p;
  final List<String> flips;
  final bool autoFlipping;
  const PRState({this.p = 0.6, this.flips = const [], this.autoFlipping = false});
  PRState copyWith({double? p, List<String>? flips, bool? autoFlipping}) =>
      PRState(
        p: p ?? this.p,
        flips: flips ?? this.flips,
        autoFlipping: autoFlipping ?? this.autoFlipping,
      );
}

const int maxFlips = 100;
final _rng = Random();

String flip(double p) => _rng.nextDouble() < p ? 'H' : 'T';

int countH(List<String> flips) => flips.where((f) => f == 'H').length;
int countT(List<String> flips) => flips.where((f) => f == 'T').length;

double empiricalP(List<String> flips) {
  if (flips.isEmpty) return 0;
  return countH(flips) / flips.length;
}

double expectedValue(double p) => p;

Map<String, double> confidenceInterval(int n, double pHat) {
  if (n == 0) return {'low': 0.0, 'high': 1.0};
  const z = 1.96;
  const z2 = z * z;
  final centre = (pHat + z2 / (2 * n)) / (1 + z2 / n);
  final margin = (z / (1 + z2 / n)) * sqrt((pHat * (1 - pHat)) / n + z2 / (4 * n * n));
  return {
    'low': max(0, centre - margin),
    'high': min(1, centre + margin),
  };
}

List<double> runningProb(List<String> flips) {
  int heads = 0;
  return List.generate(flips.length, (i) {
    if (flips[i] == 'H') heads++;
    return heads / (i + 1);
  });
}
