import 'dart:math';

class CLState {
  final double angle;
  final double offset;
  const CLState({this.angle = 0, this.offset = 0});
  CLState copyWith({double? angle, double? offset}) =>
      CLState(angle: angle ?? this.angle, offset: offset ?? this.offset);
}

class Pt {
  final double x, y;
  const Pt(this.x, this.y);
}

const List<Pt> classA = [
  Pt(0.22, 0.72), Pt(0.28, 0.61), Pt(0.33, 0.69),
  Pt(0.19, 0.58), Pt(0.38, 0.74), Pt(0.25, 0.78),
  Pt(0.31, 0.55), Pt(0.15, 0.65), Pt(0.42, 0.62), Pt(0.27, 0.84),
];

const List<Pt> classB = [
  Pt(0.65, 0.28), Pt(0.72, 0.42), Pt(0.78, 0.31),
  Pt(0.61, 0.38), Pt(0.85, 0.26), Pt(0.68, 0.48),
  Pt(0.74, 0.22), Pt(0.81, 0.44), Pt(0.58, 0.32), Pt(0.76, 0.36),
];

const double optimalAngle = -45;
const double optimalOffset = 0;

const double clPlotW = 350;
const double clPlotH = 220;
const double clPad = 24;

double clToSvgX(double xNorm) => clPad + xNorm * (clPlotW - 2 * clPad);
double clToSvgY(double yNorm) => clPlotH - clPad - yNorm * (clPlotH - 2 * clPad);

int classify(double px, double py, double angle, double offset) {
  final theta = angle * pi / 180;
  final d = sin(theta) * (px - 0.5) - cos(theta) * (py - 0.5) + offset;
  return d >= 0 ? 1 : -1;
}

double calcAccuracy(double angle, double offset) {
  int correctA = classA.where((p) => classify(p.x, p.y, angle, offset) == 1).length;
  int correctB = classB.where((p) => classify(p.x, p.y, angle, offset) == -1).length;
  return ((correctA + correctB) / (classA.length + classB.length)) * 100;
}

Map<String, double> boundaryLine(double angle, double offset) {
  final theta = angle * pi / 180;
  final cosT = cos(theta);
  final sinT = sin(theta);
  double cxN, cyN;
  if (cosT.abs() > 1e-4) {
    cxN = 0.5;
    cyN = 0.5 + offset / cosT;
  } else {
    cxN = 0.5 + offset / sinT;
    cyN = 0.5;
  }
  final cxS = clToSvgX(cxN);
  final cyS = clToSvgY(cyN);
  const l = 500.0;
  return {
    'x1': cxS - l * cosT,
    'y1': cyS + l * sinT,
    'x2': cxS + l * cosT,
    'y2': cyS - l * sinT,
  };
}

// --- Challenge dataset (harder — classes closer together) ---
const List<Pt> challengeClassA = [
  Pt(0.30, 0.65), Pt(0.35, 0.58), Pt(0.28, 0.55),
  Pt(0.40, 0.62), Pt(0.33, 0.70), Pt(0.38, 0.53),
  Pt(0.25, 0.60), Pt(0.42, 0.68), Pt(0.36, 0.50), Pt(0.31, 0.63),
];

const List<Pt> challengeClassB = [
  Pt(0.52, 0.45), Pt(0.58, 0.38), Pt(0.55, 0.48),
  Pt(0.62, 0.35), Pt(0.50, 0.42), Pt(0.57, 0.50),
  Pt(0.65, 0.40), Pt(0.53, 0.33), Pt(0.60, 0.46), Pt(0.48, 0.37),
];

Map<String, int> confusionMatrix(double angle, double offset, {List<Pt>? posClass, List<Pt>? negClass}) {
  final pos = posClass ?? classA;
  final neg = negClass ?? classB;
  int tp = 0, fn = 0, fp = 0, tn = 0;
  for (final p in pos) {
    if (classify(p.x, p.y, angle, offset) == 1) {
      tp++;
    } else {
      fn++;
    }
  }
  for (final p in neg) {
    if (classify(p.x, p.y, angle, offset) == 1) {
      fp++;
    } else {
      tn++;
    }
  }
  return {'tp': tp, 'fp': fp, 'tn': tn, 'fn': fn};
}

double calcAccuracyForDataset(double angle, double offset, List<Pt> posClass, List<Pt> negClass) {
  int correctPos = posClass.where((p) => classify(p.x, p.y, angle, offset) == 1).length;
  int correctNeg = negClass.where((p) => classify(p.x, p.y, angle, offset) == -1).length;
  return ((correctPos + correctNeg) / (posClass.length + negClass.length)) * 100;
}
