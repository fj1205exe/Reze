class BAYState {
  final double prior;
  final double sensitivity;
  final double specificity;
  const BAYState({this.prior = 0.05, this.sensitivity = 0.90, this.specificity = 0.90});
  BAYState copyWith({double? prior, double? sensitivity, double? specificity}) =>
      BAYState(
        prior: prior ?? this.prior,
        sensitivity: sensitivity ?? this.sensitivity,
        specificity: specificity ?? this.specificity,
      );
}

const BAYState bayInit = BAYState();

double calcPosterior(double prior, double sensitivity, double specificity) {
  final pPositive = sensitivity * prior + (1 - specificity) * (1 - prior);
  if (pPositive == 0) return 0;
  return (sensitivity * prior) / pPositive;
}

double calcFalsePositiveRate(double specificity) => 1 - specificity;
double calcFalseNegativeRate(double sensitivity) => 1 - sensitivity;

class PopStats {
  final int total, hasDisease, doesntHaveDisease;
  final int truePositive, falseNegative, falsePositive, trueNegative;
  final double posterior;
  const PopStats({
    required this.total, required this.hasDisease, required this.doesntHaveDisease,
    required this.truePositive, required this.falseNegative,
    required this.falsePositive, required this.trueNegative,
    required this.posterior,
  });
}

PopStats calcPopStats(double prior, double sensitivity, double specificity) {
  const total = 1000;
  final hasDisease = (total * prior).round();
  final doesntHaveDisease = total - hasDisease;
  final truePositive = (hasDisease * sensitivity).round();
  final falseNegative = hasDisease - truePositive;
  final falsePositive = (doesntHaveDisease * (1 - specificity)).round();
  final trueNegative = doesntHaveDisease - falsePositive;
  final posterior = truePositive + falsePositive == 0
      ? 0.0
      : truePositive / (truePositive + falsePositive);
  return PopStats(
    total: total, hasDisease: hasDisease, doesntHaveDisease: doesntHaveDisease,
    truePositive: truePositive, falseNegative: falseNegative,
    falsePositive: falsePositive, trueNegative: trueNegative,
    posterior: posterior,
  );
}
