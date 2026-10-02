import 'dart:math';

class DataPoint {
  final double x, y;
  const DataPoint(this.x, this.y);
}

const List<DataPoint> dataPoints = [
  DataPoint(0.1, 0.22), DataPoint(0.2, 0.38), DataPoint(0.3, 0.31),
  DataPoint(0.4, 0.48), DataPoint(0.5, 0.53), DataPoint(0.6, 0.61),
  DataPoint(0.7, 0.68), DataPoint(0.8, 0.74), DataPoint(0.9, 0.88),
];

const double olsSlope = 0.765;
const double olsIntercept = 0.155;

double calcMSE(double slope, double intercept) {
  final n = dataPoints.length;
  double sum = 0;
  for (final p in dataPoints) {
    final pred = slope * p.x + intercept;
    sum += pow(p.y - pred, 2);
  }
  return sum / n;
}

double optimalMSE() => calcMSE(olsSlope, olsIntercept);

bool isGoodFit(double slope, double intercept) {
  return calcMSE(slope, intercept) < optimalMSE() * 2.5;
}

const plotPad = {'l': 40.0, 'r': 20.0, 't': 20.0, 'b': 30.0};
const svgW = 350.0;
const svgH = 200.0;
final iw = svgW - plotPad['l']! - plotPad['r']!;
final ih = svgH - plotPad['t']! - plotPad['b']!;

double toSvgX(double xNorm) => plotPad['l']! + xNorm * iw;
double toSvgY(double yNorm) => plotPad['t']! + ih - yNorm * ih;
