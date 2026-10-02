import 'dart:math';

class Vec2 {
  final double x, y;
  const Vec2(this.x, this.y);
}

Vec2 vecAdd(Vec2 a, Vec2 b) => Vec2(a.x + b.x, a.y + b.y);
Vec2 vecSub(Vec2 a, Vec2 b) => Vec2(a.x - b.x, a.y - b.y);
Vec2 vecScale(Vec2 v, double s) => Vec2(v.x * s, v.y * s);

double vecMagnitude(Vec2 v) => sqrt(v.x * v.x + v.y * v.y);

Vec2 vecNormalize(Vec2 v) {
  final m = vecMagnitude(v);
  if (m < 1e-10) return const Vec2(0, 0);
  return Vec2(v.x / m, v.y / m);
}

double vecDot(Vec2 a, Vec2 b) => a.x * b.x + a.y * b.y;

double vecAngle(Vec2 a, Vec2 b) {
  final ma = vecMagnitude(a);
  final mb = vecMagnitude(b);
  if (ma < 1e-10 || mb < 1e-10) return 0;
  final cosTheta = (vecDot(a, b) / (ma * mb)).clamp(-1.0, 1.0);
  return acos(cosTheta) * (180 / pi);
}

Vec2 vecProject(Vec2 a, Vec2 b) {
  final dotBB = vecDot(b, b);
  if (dotBB < 1e-10) return const Vec2(0, 0);
  return vecScale(b, vecDot(a, b) / dotBB);
}

const double vecSvgW = 350;
const double vecSvgH = 320;
const originX = 175.0;
const originY = 160.0;
const vecScale_ = 110.0;

Map<String, double> vecToSvg(Vec2 v) {
  return {
    'x': originX + v.x * vecScale_,
    'y': originY - v.y * vecScale_,
  };
}
