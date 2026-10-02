import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/neuralnet.dart' as nn_utils;

const _stepLabels = [
  'Inputs & target',
  'Hidden layer',
  'Output & loss',
  'Gradients → output',
  'Gradients → input weights',
];

class BPPlayScreen extends StatelessWidget {
  final nn_utils.BPState bp;
  final VoidCallback onStep;
  final VoidCallback onTrain;
  final VoidCallback onReset;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BPPlayScreen({
    super.key,
    required this.bp,
    required this.onStep,
    required this.onTrain,
    required this.onReset,
    required this.onNext,
    required this.onBack,
  });

  String _stepDescription(int step, double x1, double x2) {
    switch (step) {
      case 0:
        return 'We start with inputs x₁=${x1.toStringAsFixed(2)}, x₂=${x2.toStringAsFixed(2)} and a target y*=1.0 — the true label we want the network to predict.';
      case 1:
        return 'The hidden neuron computes z₁ = w₁x₁ + w₂x₂ + b₁ and applies sigmoid. Forward activations propagate.';
      case 2:
        return 'The output neuron computes y = σ(wₕ·h + b₂). Loss = (y − y*)². Measures how far off the prediction is.';
      case 3:
        return 'Gradients flow backward. By the chain rule: ∂L/∂wₕ = ∂L/∂y · ∂y/∂z₂ · ∂z₂/∂wₕ. Output weights get their gradients.';
      case 4:
        return 'Gradients reach input layer: ∂L/∂w₁ = ∂L/∂h · ∂h/∂z₁ · ∂z₁/∂w₁. Now every parameter knows how to step!';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final net = bp.net;
    final x1 = bp.x1;
    final x2 = bp.x2;
    final step = bp.step;
    final trainSteps = bp.trainSteps;

    final fwd = nn_utils.networkForward(net, x1, x2);
    final loss = fwd['loss']!;
    final lossColor = loss < 0.05 ? C.green : (loss < 0.2 ? C.yellow : C.pink);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Backpropagation', onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Forward, then backward.',
                      style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Watch values flow forward and gradients flow backward through the same weights.',
                      style: inter(fontSize: 14)),
                  const SizedBox(height: 16),

                  // Step indicators
                  Row(
                    children: List.generate(_stepLabels.length, (i) {
                      final isPassed = i <= step;
                      final isGrad = i >= 3;
                      final col = isPassed ? (isGrad ? C.pink : C.accentLight) : const Color(0xFF242830);
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i < _stepLabels.length - 1 ? 4 : 0),
                          decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(2)),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Network Diagram
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: CustomPaint(
                      painter: _BPNNetworkPainter(bp: bp, fwd: fwd),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Step Explanation Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'STEP ${step + 1} / 5: ${_stepLabels[step]}',
                              style: spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: step >= 3 ? C.pink : C.accentLight,
                                letterSpacing: 0.06,
                              ),
                            ),
                            Text('Loss: ${loss.toStringAsFixed(4)}', style: mono(fontSize: 11, color: lossColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stepDescription(step, x1, x2),
                          style: inter(fontSize: 13, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Actions
                  if (step < 4)
                    PrimaryBtn(label: 'NEXT STEP IN BACKPROP', onPressed: onStep)
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: onTrain,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: C.green,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: Text('TAKE GD STEP (x1)', style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: onReset,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: C.txt,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('RESET'),
                          ),
                        ),
                      ],
                    ),
                    if (trainSteps > 0) ...[
                      const SizedBox(height: 6),
                      Center(child: Text('Training steps taken: $trainSteps', style: mono(fontSize: 11, color: C.muted))),
                    ],
                    const SizedBox(height: 12),
                    PrimaryBtn(label: 'See the chain rule math', onPressed: onNext),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BPNNetworkPainter extends CustomPainter {
  final nn_utils.BPState bp;
  final Map<String, double> fwd;

  _BPNNetworkPainter({required this.bp, required this.fwd});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final x1Pos = Offset(w * 0.18, h * 0.32);
    final x2Pos = Offset(w * 0.18, h * 0.68);
    final hPos  = Offset(w * 0.50, h * 0.50);
    final yPos  = Offset(w * 0.82, h * 0.50);

    final step = bp.step;
    final isBackward = step >= 3;

    // Connections
    final connPaint = Paint()
      ..color = (step >= 1 ? C.accentLight : const Color(0xFF4B5563)).withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.drawLine(x1Pos, hPos, connPaint);
    canvas.drawLine(x2Pos, hPos, connPaint);

    final outConnPaint = Paint()
      ..color = (step >= 2 ? C.blue : const Color(0xFF4B5563)).withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.drawLine(hPos, yPos, outConnPaint);

    if (isBackward) {
      // Draw dashed red gradient arrows flowing backwards
      final gradPaint = Paint()
        ..color = C.pink
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(yPos - const Offset(28, -6), hPos + const Offset(28, 6), gradPaint);
    }

    // Input Nodes
    _drawNode(canvas, x1Pos, 'x₁', bp.x1.toStringAsFixed(2), C.blue, step >= 0);
    _drawNode(canvas, x2Pos, 'x₂', bp.x2.toStringAsFixed(2), C.blue, step >= 0);

    // Hidden Node
    _drawNode(canvas, hPos, 'h', fwd['h']!.toStringAsFixed(2), C.purple, step >= 1);

    // Output Node
    _drawNode(canvas, yPos, 'y', fwd['y']!.toStringAsFixed(2), step >= 2 ? (fwd['loss']! < 0.1 ? C.green : C.yellow) : const Color(0xFF4B5563), step >= 2);
  }

  void _drawNode(Canvas canvas, Offset center, String label, String val, Color col, bool active) {
    final bg = active ? col.withValues(alpha: 0.18) : C.surface2;
    final border = active ? col : const Color(0xFF4B5563);

    canvas.drawCircle(center, 22, Paint()..color = bg);
    canvas.drawCircle(center, 22, Paint()..color = border..style = PaintingStyle.stroke..strokeWidth = 1.5);

    _drawCenteredText(canvas, label, center - const Offset(0, 5), 11, active ? col : Colors.grey, FontWeight.bold);
    _drawCenteredText(canvas, val, center + const Offset(0, 7), 9, Colors.white.withValues(alpha: 0.9), FontWeight.normal);
  }

  void _drawCenteredText(Canvas canvas, String text, Offset center, double size, Color col, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: col, fontSize: size, fontFamily: 'JetBrains Mono', fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_BPNNetworkPainter old) => bp.step != old.bp.step || bp.trainSteps != old.bp.trainSteps;
}
