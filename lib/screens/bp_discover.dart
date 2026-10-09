import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/neuralnet.dart' as nn;

class BPDiscoverScreen extends StatefulWidget {
  final nn.BPState bp;
  final VoidCallback onStep;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BPDiscoverScreen({
    super.key,
    required this.bp,
    required this.onStep,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BPDiscoverScreen> createState() => _BPDiscoverScreenState();
}

class _BPDiscoverScreenState extends State<BPDiscoverScreen> {
  int _maxSeen = 0;

  @override
  void initState() {
    super.initState();
    _maxSeen = widget.bp.step;
  }

  @override
  void didUpdateWidget(covariant BPDiscoverScreen old) {
    super.didUpdateWidget(old);
    if (widget.bp.step > _maxSeen) _maxSeen = widget.bp.step;
  }

  bool get _allSeen => _maxSeen >= 4;

  static const _stepTitles = [
    'Forward pass: compute output & loss',
    'Output gradient: ∂L/∂y → ∂L/∂z₂',
    'Hidden→output weight: ∂L/∂wₕ',
    'Input gradients: ∂L/∂w₁, ∂L/∂w₂',
    'All gradients — ready for update',
  ];

  static const _stepDescriptions = [
    'The network computes y from inputs through hidden layer. Loss = (y − y*)² measures the error.',
    'The chain rule starts at the loss. ∂L/∂y = 2(y − y*). Then ∂L/∂z₂ = ∂L/∂y · σ\'(z₂) — the sigmoid derivative gates the gradient.',
    'The gradient for wₕ is: ∂L/∂wₕ = ∂L/∂z₂ · h. The hidden activation scales how much this weight contributed to the error.',
    'Gradients flow further back. ∂L/∂w₁ = ∂L/∂z₁ · x₁. Each input weight gets a gradient proportional to its input value.',
    'Every parameter now has a gradient. Subtract lr × gradient from each weight to reduce the loss. This is one step of training.',
  ];

  @override
  Widget build(BuildContext context) {
    final net = widget.bp.net;
    final x1 = widget.bp.x1;
    final x2 = widget.bp.x2;
    final step = widget.bp.step;

    final fwd = nn.networkForward(net, x1, x2);
    final bwd = nn.networkBackward(net, x1, x2);
    final loss = fwd['loss']!;
    final y = fwd['y']!;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(
            label: 'Backpropagation',
            onBack: widget.onBack,
            right: StepCounter(steps: step, max: 4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How gradients flow.', style: spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Step through the backward pass to see the chain rule in action.',
                      style: inter(fontSize: 14, color: C.muted)),
                  const SizedBox(height: 16),

                  // Network diagram
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: CustomPaint(
                      painter: _NetworkPainter(
                        net: net, x1: x1, x2: x2,
                        fwd: fwd, bwd: bwd, step: step,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Step info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.accent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('step ${step + 1}/5', style: spaceGrotesk(fontSize: 11, color: C.accent, letterSpacing: 0.06)),
                        const SizedBox(height: 4),
                        Text(_stepTitles[step],
                            style: spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(_stepDescriptions[step],
                            style: inter(fontSize: 13, color: const Color(0xFFD1D5DB))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Gradient values
                  if (step >= 0) _valueRow('y (output)', y, C.txt),
                  if (step >= 0) _valueRow('Loss', loss, loss < 0.05 ? C.green : C.pink),
                  if (step >= 1) _gradRow('∂L/∂y', bwd['dL_dy']!),
                  if (step >= 1) _gradRow('∂L/∂z₂', bwd['dL_dz2']!),
                  if (step >= 2) _gradRow('∂L/∂wₕ', bwd['dL_dwh']!),
                  if (step >= 3) _gradRow('∂L/∂w₁', bwd['dL_dw1']!),
                  if (step >= 3) _gradRow('∂L/∂w₂', bwd['dL_dw2']!),

                  if (step == 4) ...[
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: C.green.withValues(alpha: 0.08),
                          borderRadius: S.borderMd,
                          border: Border.all(color: C.green.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          'Each weight now has a gradient. w_new = w_old − lr × gradient.',
                          style: inter(fontSize: 13, color: C.green),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  if (step < 4)
                    PrimaryBtn(label: 'Next step →', onPressed: widget.onStep),
                  if (_allSeen) ...[
                    if (step == 4) ...[
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 400),
                        slideDistance: 12,
                        child: PrimaryBtn(label: 'Continue', onPressed: widget.onNext),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 400),
                        slideDistance: 12,
                        child: SecondaryBtn(label: 'Continue →', onPressed: widget.onNext),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueRow(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: inter(fontSize: 12, color: C.muted)),
          const Spacer(),
          Text(val.toStringAsFixed(4), style: mono(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Widget _gradRow(String label, double val) {
    final color = val > 0 ? C.pink : (val < 0 ? C.blue : C.muted);
    final arrow = val > 0 ? '↑' : (val < 0 ? '↓' : '—');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: mono(fontSize: 12, color: color)),
          const Spacer(),
          Text('$arrow ${val.toStringAsFixed(4)}', style: mono(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final nn.MiniNetwork net;
  final double x1, x2;
  final Map<String, double> fwd, bwd;
  final int step;

  _NetworkPainter({
    required this.net, required this.x1, required this.x2,
    required this.fwd, required this.bwd, required this.step,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Node positions
    final inX = w * 0.15;
    final hidX = w * 0.45;
    final outX = w * 0.75;
    final in1Y = h * 0.35;
    final in2Y = h * 0.65;
    final hidY = h * 0.5;
    final outY = h * 0.5;

    final dimColor = Colors.white.withValues(alpha: 0.15);
    final activeColor = C.accentLight;

    // Connections
    _drawEdge(canvas, Offset(inX, in1Y), Offset(hidX, hidY),
        step >= 3 ? C.blue : (step >= 0 ? activeColor : dimColor),
        step >= 3 ? 2.5 : 1.5,
        step >= 3 ? 'w₁' : null);
    _drawEdge(canvas, Offset(inX, in2Y), Offset(hidX, hidY),
        step >= 3 ? C.accentLight : (step >= 0 ? activeColor : dimColor),
        step >= 3 ? 2.5 : 1.5,
        step >= 3 ? 'w₂' : null);
    _drawEdge(canvas, Offset(hidX, hidY), Offset(outX, outY),
        step >= 2 ? C.yellow : (step >= 0 ? activeColor : dimColor),
        step >= 2 ? 2.5 : 1.5,
        step >= 2 ? 'wₕ' : null);

    // Gradient arrows (backward flow)
    if (step >= 1) {
      _drawGradArrow(canvas, Offset(outX + 30, outY), Offset(outX, outY), C.pink);
    }
    if (step >= 2) {
      _drawGradArrow(canvas, Offset(outX, outY), Offset(hidX + 20, hidY), C.pink);
    }
    if (step >= 3) {
      _drawGradArrow(canvas, Offset(hidX, hidY), Offset(inX + 20, in1Y), C.pink);
      _drawGradArrow(canvas, Offset(hidX, hidY), Offset(inX + 20, in2Y), C.pink);
    }

    // Nodes
    _drawNode(canvas, Offset(inX, in1Y), 'x₁', step >= 0 ? C.blue : dimColor, 16);
    _drawNode(canvas, Offset(inX, in2Y), 'x₂', step >= 0 ? C.accentLight : dimColor, 16);
    _drawNode(canvas, Offset(hidX, hidY), 'h', step >= 0 ? C.green : dimColor, 20);
    _drawNode(canvas, Offset(outX, outY), 'y', step >= 1 ? C.yellow : (step >= 0 ? C.txt : dimColor), 20);

    // Loss label
    final lossVal = fwd['loss']!;
    _drawLabel(canvas, 'L=${lossVal.toStringAsFixed(3)}', Offset(outX + 10, outY - 28),
        step >= 0 ? (lossVal < 0.05 ? C.green : C.pink) : dimColor);
  }

  void _drawEdge(Canvas canvas, Offset from, Offset to, Color color, double width, String? label) {
    canvas.drawLine(from, to, Paint()..color = color..strokeWidth = width);
    if (label != null) {
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2 - 10);
      _drawLabel(canvas, label, mid, color);
    }
  }

  void _drawGradArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final ux = dx / len;
    final uy = dy / len;
    final endX = to.dx - ux * 12;
    final endY = to.dy - uy * 12;

    canvas.drawLine(from, Offset(endX, endY), paint);

    // arrowhead
    const arrowLen = 6.0;
    const arrowAngle = pi / 5;
    final angle = atan2(dy, dx);
    final p1 = Offset(endX - arrowLen * cos(angle - arrowAngle), endY - arrowLen * sin(angle - arrowAngle));
    final p2 = Offset(endX - arrowLen * cos(angle + arrowAngle), endY - arrowLen * sin(angle + arrowAngle));
    final path = Path()..moveTo(endX, endY)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.5));
  }

  void _drawNode(Canvas canvas, Offset center, String label, Color color, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = color.withValues(alpha: 0.15));
    canvas.drawCircle(center, radius, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5);
    final tp = TextPainter(
      text: TextSpan(text: label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawLabel(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 10, fontFamily: 'JetBrains Mono')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_NetworkPainter old) => step != old.step;
}
