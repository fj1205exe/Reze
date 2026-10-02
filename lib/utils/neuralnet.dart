import 'dart:math';

double sigmoid(double z) => 1 / (1 + exp(-z));
double sigmoidDerivative(double z) {
  final s = sigmoid(z);
  return s * (1 - s);
}
double relu(double z) => max(0, z);
double reluDerivative(double z) => z > 0 ? 1 : 0;

class NNState {
  final double w1, w2, bias, x1, x2;
  const NNState({this.w1 = 0.5, this.w2 = 0.5, this.bias = 0.0, this.x1 = 0.8, this.x2 = 0.6});
  NNState copyWith({double? w1, double? w2, double? bias, double? x1, double? x2}) =>
      NNState(w1: w1 ?? this.w1, w2: w2 ?? this.w2, bias: bias ?? this.bias, x1: x1 ?? this.x1, x2: x2 ?? this.x2);
}

const NNState nnInit = NNState();

Map<String, double> neuronForward(double x1, double x2, double w1, double w2, double bias) {
  final z = w1 * x1 + w2 * x2 + bias;
  return {'z': z, 'output': sigmoid(z)};
}

class MiniNetwork {
  final double w1, w2, wh, b1, b2;
  const MiniNetwork({this.w1 = 0.3, this.w2 = -0.2, this.wh = 0.5, this.b1 = 0.1, this.b2 = 0.0});
  MiniNetwork copyWith({double? w1, double? w2, double? wh, double? b1, double? b2}) =>
      MiniNetwork(w1: w1 ?? this.w1, w2: w2 ?? this.w2, wh: wh ?? this.wh, b1: b1 ?? this.b1, b2: b2 ?? this.b2);
}

const MiniNetwork miniNetInit = MiniNetwork();
const double yTrue = 1.0;

Map<String, double> networkForward(MiniNetwork net, double x1, double x2) {
  final z1 = net.w1 * x1 + net.w2 * x2 + net.b1;
  final h = sigmoid(z1);
  final z2 = net.wh * h + net.b2;
  final y = sigmoid(z2);
  final loss = pow(y - yTrue, 2).toDouble();
  return {'z1': z1, 'h': h, 'z2': z2, 'y': y, 'loss': loss};
}

Map<String, double> networkBackward(MiniNetwork net, double x1, double x2) {
  final fwd = networkForward(net, x1, x2);
  final z1 = fwd['z1']!, h = fwd['h']!, z2 = fwd['z2']!, y = fwd['y']!;
  final dLdy = 2 * (y - yTrue);
  final dLdz2 = dLdy * sigmoidDerivative(z2);
  final dLdwh = dLdz2 * h;
  final dLdh = dLdz2 * net.wh;
  final dLdz1 = dLdh * sigmoidDerivative(z1);
  final dLdw1 = dLdz1 * x1;
  final dLdw2 = dLdz1 * x2;
  return {
    'dL_dy': dLdy, 'dL_dz2': dLdz2, 'dL_dwh': dLdwh,
    'dL_dh': dLdh, 'dL_dz1': dLdz1, 'dL_dw1': dLdw1, 'dL_dw2': dLdw2,
  };
}

MiniNetwork networkStep(MiniNetwork net, double x1, double x2, double lr) {
  final g = networkBackward(net, x1, x2);
  return MiniNetwork(
    w1: net.w1 - lr * g['dL_dw1']!,
    w2: net.w2 - lr * g['dL_dw2']!,
    wh: net.wh - lr * g['dL_dwh']!,
    b1: net.b1 - lr * g['dL_dz1']!,
    b2: net.b2 - lr * g['dL_dz2']!,
  );
}

class BPState {
  final MiniNetwork net;
  final double x1, x2;
  final int step;
  final int trainSteps;
  const BPState({this.net = miniNetInit, this.x1 = 0.5, this.x2 = 0.8, this.step = 0, this.trainSteps = 0});
  BPState copyWith({MiniNetwork? net, double? x1, double? x2, int? step, int? trainSteps}) =>
      BPState(
        net: net ?? this.net, x1: x1 ?? this.x1, x2: x2 ?? this.x2,
        step: step ?? this.step, trainSteps: trainSteps ?? this.trainSteps,
      );
}

const BPState bpInit = BPState();
