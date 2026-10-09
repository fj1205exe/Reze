import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

const _xorPoints = [
  {'x1': 0.15, 'x2': 0.15, 'target': 0},
  {'x1': 0.15, 'x2': 0.85, 'target': 1},
  {'x1': 0.85, 'x2': 0.15, 'target': 1},
  {'x1': 0.85, 'x2': 0.85, 'target': 0},
];

class NNPlayScreen extends StatefulWidget {
  final double w1, w2, bias, x1, x2;
  final void Function(double w1, double w2, double b) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NNPlayScreen({
    super.key,
    required this.w1,
    required this.w2,
    required this.bias,
    required this.x1,
    required this.x2,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<NNPlayScreen> createState() => _NNPlayScreenState();
}

class _NNPlayScreenState extends State<NNPlayScreen> {
  int _moves = 0;

  int _classify(double x1, double x2, double w1, double w2, double b) {
    return (w1 * x1 + w2 * x2 + b) >= 0 ? 1 : 0;
  }

  int _xorAccuracy(double w1, double w2, double b) {
    int correct = 0;
    for (final p in _xorPoints) {
      if (_classify(p['x1'] as double, p['x2'] as double, w1, w2, b) == (p['target'] as int)) {
        correct++;
      }
    }
    return correct;
  }

  void _handleUpdate({double? w1, double? w2, double? b}) {
    final nextW1 = w1 ?? widget.w1;
    final nextW2 = w2 ?? widget.w2;
    final nextB = b ?? widget.bias;
    widget.onUpdate(nextW1, nextW2, nextB);
    setState(() => _moves++);
  }

  @override
  Widget build(BuildContext context) {
    final w1 = widget.w1;
    final w2 = widget.w2;
    final b = widget.bias;
    final correct = _xorAccuracy(w1, w2, b);
    final accuracy = (correct / 4) * 100;
    final canAdvance = _moves >= 6;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Weights & Bias', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Can a single neuron solve XOR?',
                      style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Adjust weights and bias to separate the red points from blue points.',
                      style: inter(fontSize: 14)),
                  const SizedBox(height: 16),

                  // 2D XOR plane
                  Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: CustomPaint(
                      painter: _NNXorPainter(w1: w1, w2: w2, bias: b),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Accuracy card & frustration insight
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Accuracy ($correct / 4 correct)', style: inter(fontSize: 12, color: C.muted)),
                            const SizedBox(height: 2),
                            Text(
                              '${accuracy.round()}%',
                              style: mono(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: accuracy > 75 ? C.green : (accuracy == 75 ? C.yellow : C.pink),
                              ),
                            ),
                          ],
                        ),
                        Text('Max possible: 75%', style: mono(fontSize: 11, color: C.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Insight note
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: C.yellow, width: 2)),
                    ),
                    child: Text(
                      'Notice that no straight line can separate diagonal points! A single neuron is fundamentally limited to linear boundaries.',
                      style: inter(fontSize: 12, color: C.yellow),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      children: [
                        _sliderRow('Weight w₁', w1, -2.0, 2.0, C.green, (v) => _handleUpdate(w1: v)),
                        const SizedBox(height: 4),
                        _sliderRow('Weight w₂', w2, -2.0, 2.0, C.blue, (v) => _handleUpdate(w2: v)),
                        const SizedBox(height: 4),
                        _sliderRow('Bias b', b, -2.0, 2.0, C.yellow, (v) => _handleUpdate(b: v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (canAdvance)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: PrimaryBtn(
                        label: 'See why (The AI Winter)',
                        onPressed: widget.onNext,
                      ),
                    )
                  else
                    PrimaryBtn(
                      label: 'Try adjusting sliders (${6 - _moves} moves remaining)',
                      disabled: true,
                      onPressed: null,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, double val, double min, double max, Color color, ValueChanged<double> onChange) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${val >= 0 ? "+" : ""}${val.toStringAsFixed(2)}', style: mono(fontSize: 13, color: color)),
          ],
        ),
        Slider(
          value: val.clamp(min, max),
          min: min,
          max: max,
          activeColor: color,
          onChanged: onChange,
        ),
      ],
    );
  }
}

class _NNXorPainter extends CustomPainter {
  final double w1, w2, bias;

  _NNXorPainter({required this.w1, required this.w2, required this.bias});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const pad = 28.0;
    final iw = w - 2 * pad;
    final ih = h - 2 * pad;

    double toX(double xNorm) => pad + xNorm * iw;
    double toY(double yNorm) => h - pad - yNorm * ih;

    // Grid lines
    final gridPaint = Paint()..color = C.dim..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final f = i / 4;
      canvas.drawLine(Offset(toX(f), pad), Offset(toX(f), h - pad), gridPaint);
      canvas.drawLine(Offset(pad, toY(f)), Offset(w - pad, toY(f)), gridPaint);
    }

    // Clip
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(pad, pad, iw, ih));

    // Decision boundary line w1*x1 + w2*x2 + b = 0
    if (w2.abs() > 1e-4) {
      final y0 = (-bias) / w2;
      final y1 = (-w1 - bias) / w2;
      canvas.drawLine(
        Offset(toX(0), toY(y0)),
        Offset(toX(1), toY(y1)),
        Paint()..color = Colors.white..strokeWidth = 2,
      );
    } else if (w1.abs() > 1e-4) {
      final x0 = (-bias) / w1;
      canvas.drawLine(
        Offset(toX(x0), toY(0)),
        Offset(toX(x0), toY(1)),
        Paint()..color = Colors.white..strokeWidth = 2,
      );
    }

    canvas.restore();

    // Draw XOR Points
    for (final p in _xorPoints) {
      final x1 = p['x1'] as double;
      final x2 = p['x2'] as double;
      final target = p['target'] as int;
      final isClass1 = target == 1;
      final color = isClass1 ? C.pink : C.blue;

      canvas.drawCircle(
        Offset(toX(x1), toY(x2)),
        7,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(toX(x1), toY(x2)),
        3,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_NNXorPainter old) => w1 != old.w1 || w2 != old.w2 || bias != old.bias;
}
