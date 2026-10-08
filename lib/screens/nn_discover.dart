import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/neuralnet.dart' as nn_utils;

class NNDiscoverScreen extends StatefulWidget {
  final double w1, w2, bias, x1, x2;
  final int steps;
  final void Function(double w1, double w2, double b) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NNDiscoverScreen({
    super.key,
    required this.w1,
    required this.w2,
    required this.bias,
    required this.x1,
    required this.x2,
    required this.steps,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<NNDiscoverScreen> createState() => _NNDiscoverScreenState();
}

class _NNDiscoverScreenState extends State<NNDiscoverScreen> {
  int _discoverSteps = 0;

  String get _feedbackMsg {
    final w1 = widget.w1;
    final w2 = widget.w2;
    final bias = widget.bias;
    final fwd = nn_utils.neuronForward(widget.x1, widget.x2, w1, w2, bias);
    final output = fwd['output']!;

    if (w1.abs() > 1.5 || w2.abs() > 1.5) {
      return 'Weights control input importance — larger weights amplify input signals.';
    }
    if (bias.abs() > 0.5) {
      return 'Bias shifts the activation threshold — it moves the decision boundary.';
    }
    if (output > 0.9) {
      return 'Sigmoid squashes to 0-1 — large positive z pushes output near 1.';
    }
    if (output < 0.1) {
      return 'Sigmoid squashes to 0-1 — large negative z pushes output near 0.';
    }
    return 'Adjust weights and bias to see how they affect neuron output.';
  }

  String get _feedbackType {
    final fwd = nn_utils.neuronForward(widget.x1, widget.x2, widget.w1, widget.w2, widget.bias);
    final output = fwd['output']!;
    if (output > 0.8 || output < 0.2) return 'ok';
    return 'info';
  }

  @override
  Widget build(BuildContext context) {
    final fwd = nn_utils.neuronForward(widget.x1, widget.x2, widget.w1, widget.w2, widget.bias);
    final z = fwd['z']!;
    final output = fwd['output']!;
    final unlocked = _discoverSteps >= 8;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: S.headerPad,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NEURAL NETWORKS', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Adjust the weights.', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  StepCounter(steps: widget.steps),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Neuron diagram
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.border),
                    ),
                    child: Stack(
                      children: [
                        Positioned(top: 12, right: 12, child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('output', style: inter(fontSize: 11, color: C.muted)),
                            Text(output.toStringAsFixed(3), style: mono(fontSize: 18, color: C.accentLight, fontWeight: FontWeight.bold)),
                          ],
                        )),
                        CustomPaint(
                          size: const Size(double.infinity, 240),
                          painter: _NeuronDiagramPainter(
                            x1: widget.x1, x2: widget.x2,
                            w1: widget.w1, w2: widget.w2,
                            bias: widget.bias, z: z, output: output,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Computation breakdown
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('COMPUTATION', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: mono(fontSize: 13, color: C.txt),
                            children: [
                              const TextSpan(text: 'z = '),
                              TextSpan(text: 'w₁', style: mono(fontSize: 13, color: C.green)),
                              const TextSpan(text: ' · '),
                              TextSpan(text: 'x₁', style: mono(fontSize: 13, color: C.blue)),
                              const TextSpan(text: ' + '),
                              TextSpan(text: 'w₂', style: mono(fontSize: 13, color: C.green)),
                              const TextSpan(text: ' · '),
                              TextSpan(text: 'x₂', style: mono(fontSize: 13, color: C.blue)),
                              const TextSpan(text: ' + '),
                              TextSpan(text: 'b', style: mono(fontSize: 13, color: C.yellow)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('z = ${z.toStringAsFixed(3)}', style: mono(fontSize: 12, color: C.muted)),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: mono(fontSize: 13, color: C.txt),
                            children: [
                              const TextSpan(text: 'output = '),
                              TextSpan(text: 'σ', style: mono(fontSize: 13, color: C.purple)),
                              const TextSpan(text: '(z) = 1 / (1 + e⁻ᶻ)'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('output = ${output.toStringAsFixed(3)}', style: mono(fontSize: 12, color: C.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sigmoid curve
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: CustomPaint(
                      size: const Size(double.infinity, 120),
                      painter: _SigmoidCurvePainter(z: z, output: output),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Inputs (fixed)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INPUTS (fixed)', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('x₁', style: inter(fontSize: 11, color: C.muted)),
                                  Text(widget.x1.toStringAsFixed(2), style: mono(fontSize: 14, color: C.blue)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('x₂', style: inter(fontSize: 11, color: C.muted)),
                                  Text(widget.x2.toStringAsFixed(2), style: mono(fontSize: 14, color: C.blue)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Weight sliders
                  _buildSlider('Weight w₁', widget.w1, -2.0, 2.0, C.green, (v) {
                    setState(() => _discoverSteps++);
                    widget.onUpdate(v, widget.w2, widget.bias);
                  }),
                  const SizedBox(height: 8),

                  _buildSlider('Weight w₂', widget.w2, -2.0, 2.0, C.green, (v) {
                    setState(() => _discoverSteps++);
                    widget.onUpdate(widget.w1, v, widget.bias);
                  }),
                  const SizedBox(height: 8),

                  _buildSlider('Bias b', widget.bias, -2.0, 2.0, C.yellow, (v) {
                    setState(() => _discoverSteps++);
                    widget.onUpdate(widget.w1, widget.w2, v);
                  }),
                  const SizedBox(height: 16),

                  FeedbackBar(type: _feedbackType, message: _feedbackMsg),
                  const SizedBox(height: 16),

                  if (unlocked) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: SecondaryBtn(label: 'I understand — show me the math →', onPressed: widget.onNext),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double val, double min, double max, Color color, ValueChanged<double> onChange) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: S.borderMd,
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${val >= 0 ? "+" : ""}${val.toStringAsFixed(2)}', style: mono(fontSize: 13, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: C.surface3,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: val.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChange,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeuronDiagramPainter extends CustomPainter {
  final double x1, x2, w1, w2, bias, z, output;

  _NeuronDiagramPainter({
    required this.x1, required this.x2, required this.w1, required this.w2,
    required this.bias, required this.z, required this.output,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final x1Pos = Offset(w * 0.20, h * 0.35);
    final x2Pos = Offset(w * 0.20, h * 0.65);
    final neuronPos = Offset(w * 0.65, h * 0.50);
    final outputPos = Offset(w * 0.90, h * 0.50);

    // Connection lines
    final connPaint = Paint()..strokeWidth = 2;
    connPaint.color = C.green.withValues(alpha: 0.6);
    canvas.drawLine(x1Pos, neuronPos, connPaint);
    canvas.drawLine(x2Pos, neuronPos, connPaint);

    // Weight labels
    _drawText(canvas, 'w₁=${w1.toStringAsFixed(2)}', Offset(w * 0.38, h * 0.28), 10, C.green);
    _drawText(canvas, 'w₂=${w2.toStringAsFixed(2)}', Offset(w * 0.38, h * 0.68), 10, C.green);

    // Output line
    canvas.drawLine(neuronPos + const Offset(28, 0), outputPos, Paint()..color = C.purple.withValues(alpha: 0.6)..strokeWidth = 2);

    // Input nodes
    _drawNode(canvas, x1Pos, 'x₁', x1.toStringAsFixed(2), C.blue);
    _drawNode(canvas, x2Pos, 'x₂', x2.toStringAsFixed(2), C.blue);

    // Neuron (with bias)
    canvas.drawCircle(neuronPos, 28, Paint()..color = C.purple.withValues(alpha: 0.15));
    canvas.drawCircle(neuronPos, 28, Paint()..color = C.purple..style = PaintingStyle.stroke..strokeWidth = 2);
    _drawCenteredText(canvas, 'σ', neuronPos - const Offset(0, 8), 14, C.purple, FontWeight.bold);
    _drawCenteredText(canvas, 'b=${bias.toStringAsFixed(2)}', neuronPos + const Offset(0, 10), 9, C.yellow, FontWeight.normal);

    // Output marker
    canvas.drawCircle(outputPos, 8, Paint()..color = C.accentLight);
  }

  void _drawNode(Canvas canvas, Offset center, String label, String val, Color col) {
    canvas.drawCircle(center, 18, Paint()..color = col.withValues(alpha: 0.15));
    canvas.drawCircle(center, 18, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.5);
    _drawCenteredText(canvas, label, center - const Offset(0, 4), 11, col, FontWeight.bold);
    _drawCenteredText(canvas, val, center + const Offset(0, 7), 9, Colors.white.withValues(alpha: 0.9), FontWeight.normal);
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'JetBrains Mono')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawCenteredText(Canvas canvas, String text, Offset center, double size, Color col, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: col, fontSize: size, fontFamily: 'JetBrains Mono', fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_NeuronDiagramPainter old) => w1 != old.w1 || w2 != old.w2 || bias != old.bias;
}

class _SigmoidCurvePainter extends CustomPainter {
  final double z;
  final double output;

  _SigmoidCurvePainter({required this.z, required this.output});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const padL = 32.0;
    const padR = 16.0;
    const padT = 16.0;
    const padB = 16.0;
    final iw = w - padL - padR;
    final ih = h - padT - padB;

    double toX(double zVal) => padL + (zVal + 5) / 10 * iw;
    double toY(double yVal) => padT + (1 - yVal) * ih;

    // Grid
    final gridPaint = Paint()..color = C.dim..strokeWidth = 1;
    canvas.drawLine(Offset(padL, toY(0.5)), Offset(w - padR, toY(0.5)), gridPaint);

    // Sigmoid curve
    final curvePath = Path();
    for (double zVal = -5.0; zVal <= 5.0; zVal += 0.1) {
      final y = nn_utils.sigmoid(zVal);
      final px = toX(zVal);
      final py = toY(y);
      if (zVal == -5.0) {
        curvePath.moveTo(px, py);
      } else {
        curvePath.lineTo(px, py);
      }
    }
    canvas.drawPath(
      curvePath,
      Paint()..color = C.purple.withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 2,
    );

    // Current point marker
    canvas.drawCircle(
      Offset(toX(z), toY(output)),
      5,
      Paint()..color = C.accentLight,
    );

    // Labels
    _drawText(canvas, '0', Offset(padL - 18, toY(0) - 6), 10, C.muted);
    _drawText(canvas, '1', Offset(padL - 18, toY(1) - 6), 10, C.muted);
    _drawText(canvas, 'z', Offset(w - padR - 10, padT + ih + 4), 10, C.muted);
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'JetBrains Mono')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_SigmoidCurvePainter old) => z != old.z;
}
