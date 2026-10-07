import 'dart:math';

class DataPoint {
  final double x, y;
  const DataPoint(this.x, this.y);
}

const List<DataPoint> trainPoints = [
  DataPoint(0.10, 0.28), DataPoint(0.20, 0.35), DataPoint(0.30, 0.44),
  DataPoint(0.40, 0.48), DataPoint(0.50, 0.52), DataPoint(0.60, 0.58),
  DataPoint(0.70, 0.63), DataPoint(0.80, 0.71),
];

const List<DataPoint> testPoints = [
  DataPoint(0.15, 0.31), DataPoint(0.35, 0.41),
  DataPoint(0.55, 0.55), DataPoint(0.75, 0.67),
];

const int maxDegree = 7;
const int sweetSpot = 2;

List<double> _gaussianElim(List<List<double>> A, List<double> b) {
  final n = b.length;
  final aug = List.generate(n, (i) => [...A[i], b[i]]);

  for (int col = 0; col < n; col++) {
    int maxRow = col;
    for (int row = col + 1; row < n; row++) {
      if (aug[row][col].abs() > aug[maxRow][col].abs()) maxRow = row;
    }
    final tmp = aug[col];
    aug[col] = aug[maxRow];
    aug[maxRow] = tmp;

    if (aug[col][col].abs() < 1e-12) continue;

    for (int row = col + 1; row < n; row++) {
      final factor = aug[row][col] / aug[col][col];
      for (int k = col; k <= n; k++) {
        aug[row][k] -= factor * aug[col][k];
      }
    }
  }

  final x = List<double>.filled(n, 0);
  for (int i = n - 1; i >= 0; i--) {
    x[i] = aug[i][n];
    for (int j = i + 1; j < n; j++) {
      x[i] -= aug[i][j] * x[j];
    }
    x[i] /= (aug[i][i].abs() < 1e-12 ? 1 : aug[i][i]);
  }
  return x;
}

List<double> fitPolynomial(List<DataPoint> points, int degree) {
  final d = degree + 1;
  final xtx = List.generate(d, (_) => List<double>.filled(d, 0));
  final xty = List<double>.filled(d, 0);

  for (final pt in points) {
    final pows = List.generate(d, (j) => pow(pt.x, j).toDouble());
    for (int i = 0; i < d; i++) {
      xty[i] += pows[i] * pt.y;
      for (int j = 0; j < d; j++) {
        xtx[i][j] += pows[i] * pows[j];
      }
    }
  }

  return _gaussianElim(xtx, xty);
}

double evalPoly(double x, List<double> coeffs) {
  double result = 0;
  for (int i = 0; i < coeffs.length; i++) {
    result += coeffs[i] * pow(x, i);
  }
  return result;
}

double calcPolyMSE(List<double> coeffs, List<DataPoint> points) {
  double sum = 0;
  for (final pt in points) {
    final err = pt.y - evalPoly(pt.x, coeffs);
    sum += err * err;
  }
  return sum / points.length;
}

List<Map<String, double>> sampleOFCurve(List<double> coeffs, [int n = 80]) {
  return List.generate(n, (i) {
    final x = i / (n - 1);
    final y = evalPoly(x, coeffs).clamp(-0.2, 1.2);
    return {'x': x, 'y': y};
  });
}

const ofPlot = {
  'padL': 28.0, 'padR': 12.0, 'padT': 16.0, 'padB': 16.0,
  'svgW': 350.0, 'svgH': 200.0, 'iw': 310.0, 'ih': 168.0,
};

double ofToSvgX(double xNorm) => ofPlot['padL']! + xNorm * ofPlot['iw']!;
double ofToSvgY(double yNorm) => ofPlot['padT']! + (1 - yNorm) * ofPlot['ih']!;
