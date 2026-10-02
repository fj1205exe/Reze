import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

const _stageTitles = [
  'What is the gradient?',
  'Gradient near the minimum',
  'Gradient = step direction',
  'Why magnitude matters',
];

class GDGradientScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDGradientScreen({super.key, required this.onNext, required this.onBack});
  @override
  State<GDGradientScreen> createState() => _GDGradientScreenState();
}

class _GDGradientScreenState extends State<GDGradientScreen> {
  int _stage = 0;
  double _theta = 8.0;
  List<double> _history = [];
  bool _insightVisible = false;

  // Stage 3 state
  bool _calculated = false;
  double _preCalcTheta = 8.0;

  // Stage 4 state
  bool _stage4Revealed = false;

  void _advance() {
    if (_stage >= 3) {
      widget.onNext();
      return;
    }
    setState(() {
      _stage++;
      _insightVisible = false;
      _calculated = false;
      _history = [];
      switch (_stage) {
        case 1:
          _theta = 6.0;
        case 2:
          _theta = 8.0;
          _preCalcTheta = 8.0;
        case 3:
          _stage4Revealed = false;
      }
    });
  }

  Color get _gradColor {
    final g = gd.gradientOf(_theta);
    if (g.abs() < 0.05) return C.green;
    return g > 0 ? C.pink : C.blue;
  }

  String _gradSign(double g) {
    if (g > 0.01) return '+';
    if (g < -0.01) return '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          _header(),
          if (_stage < 3) _lossCurveCard(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: _stageContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: C.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: C.blue.withValues(alpha: 0.25)),
                  ),
                  child: Text('GRADIENT', style: spaceGrotesk(fontSize: 11, color: C.blue)),
                ),
                const SizedBox(height: 4),
                Text(_stageTitles[_stage], style: spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            )),
            ProgressPill(current: _stage, total: 4),
          ],
        ),
      ),
    );
  }

  Widget _lossCurveCard() {
    final grad = gd.gradientOf(_theta);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _insightVisible ? C.green.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06)),
        ),
        child: Stack(
          children: [
            Positioned(top: 12, left: 12, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('∇J(θ)', style: inter(fontSize: 12, color: C.muted)),
                Text('${_gradSign(grad)}${grad.toStringAsFixed(2)}',
                  style: mono(fontSize: 16, color: _gradColor)),
              ],
            )),
            Positioned(top: 12, right: 12, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: C.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gradColor.withValues(alpha: 0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  grad > 0.05 ? Icons.arrow_upward : grad < -0.05 ? Icons.arrow_downward : Icons.horizontal_rule,
                  size: 14, color: _gradColor,
                ),
                const SizedBox(width: 4),
                Text(
                  grad.abs() < 0.05 ? 'flat' : grad > 0 ? 'uphill →' : '← uphill',
                  style: inter(fontSize: 11, color: _gradColor),
                ),
              ]),
            )),
            Padding(
              padding: const EdgeInsets.all(4),
              child: LossCurveWidget(theta: _theta, history: _history, showMinMarker: true, height: 190),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stageContent() {
    switch (_stage) {
      case 0:
        return _stage1();
      case 1:
        return _stage2();
      case 2:
        return _stage3();
      case 3:
        return _stage4();
      default:
        return const SizedBox.shrink();
    }
  }

  // Stage 1: What is the gradient?
  Widget _stage1() {
    final grad = gd.gradientOf(_theta);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The gradient tells you the slope of the curve at your current position.',
          style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
        ),
        const SizedBox(height: 16),
        _infoCard(
          'At θ = ${_theta.toStringAsFixed(1)}, the gradient is ${_gradSign(grad)}${grad.toStringAsFixed(2)}',
          grad > 0
              ? 'Positive gradient → the curve slopes upward to the right.'
              : grad < -0.01
                  ? 'Negative gradient → the curve slopes downward to the right.'
                  : 'Nearly zero → you\'re at or near the bottom.',
        ),
        const SizedBox(height: 16),
        _sliderCard('Move θ to explore', gd.tMin + 0.5, gd.tMax - 0.5, _theta, (v) {
          setState(() => _theta = v);
        }),
        const SizedBox(height: 16),
        _gradientMeter(grad),
        const SizedBox(height: 20),
        PrimaryBtn(label: 'Continue', onPressed: _advance),
      ],
    );
  }

  // Stage 2: Gradient near the minimum
  Widget _stage2() {
    final grad = gd.gradientOf(_theta);
    final nearMin = (_theta - gd.trueMin).abs() < gd.convergenceRadius;

    if (nearMin && !_insightVisible) {
      Future.microtask(() {
        if (mounted) setState(() => _insightVisible = true);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Move the slider toward the minimum and watch the gradient shrink.',
          style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
        ),
        const SizedBox(height: 16),
        _sliderCard('θ position', 4.5, 6.0, _theta.clamp(4.5, 6.0), (v) {
          setState(() => _theta = v);
        }),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statBox('θ', _theta.toStringAsFixed(2))),
          const SizedBox(width: 8),
          Expanded(child: _statBox('∇J(θ)', '${_gradSign(grad)}${grad.toStringAsFixed(3)}')),
          const SizedBox(width: 8),
          Expanded(child: _statBox('Distance', (_theta - gd.trueMin).abs().toStringAsFixed(2))),
        ]),
        const SizedBox(height: 16),
        _gradientMeter(grad),
        const SizedBox(height: 16),
        AnimatedOpacity(
          opacity: _insightVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: _insightVisible
              ? Column(children: [
                  _insightCard('At the minimum, the gradient is nearly zero. That\'s how we know we\'ve arrived.'),
                  const SizedBox(height: 16),
                  PrimaryBtn(label: 'Continue', onPressed: _advance),
                ])
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Stage 3: Gradient = step direction
  Widget _stage3() {
    final grad = gd.gradientOf(_preCalcTheta);
    const eta = 0.5;
    final step = eta * grad;
    final newTheta = _preCalcTheta - step;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(children: [
            Text('THE UPDATE RULE', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
            const SizedBox(height: 12),
            RichText(text: TextSpan(children: [
              TextSpan(text: 'θ', style: mono(fontSize: 22, color: C.blue)),
              TextSpan(text: 'new', style: mono(fontSize: 11, color: C.blue.withValues(alpha: 0.7))),
              TextSpan(text: ' = ', style: mono(fontSize: 22, color: C.muted)),
              TextSpan(text: 'θ', style: mono(fontSize: 22, color: C.blue)),
              TextSpan(text: ' − ', style: mono(fontSize: 22, color: C.green)),
              TextSpan(text: 'η', style: mono(fontSize: 22, color: C.yellow)),
              TextSpan(text: '·', style: mono(fontSize: 22, color: C.muted)),
              TextSpan(text: '∇J(θ)', style: mono(fontSize: 22, color: C.pink)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _calculated ? C.green.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: LossCurveWidget(theta: _theta, history: _history, showMinMarker: true, height: 190),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Worked example', style: spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _calcStep('1. Current position', 'θ = ${_preCalcTheta.toStringAsFixed(1)}', C.blue, true),
        _calcStep('2. Gradient at θ', '∇J(θ) = ${grad.toStringAsFixed(2)}', C.pink, true),
        _calcStep('3. Multiply by η', 'η · ∇J(θ) = $eta × ${grad.toStringAsFixed(2)} = ${step.toStringAsFixed(2)}', C.yellow, _calculated),
        _calcStep('4. Subtract', 'θ − ${step.toStringAsFixed(2)} = ${newTheta.toStringAsFixed(2)}', C.green, _calculated),
        const SizedBox(height: 16),
        if (!_calculated)
          PrimaryBtn(label: 'Calculate step', onPressed: () {
            setState(() {
              _calculated = true;
              _history.add(_theta);
              _theta = gd.clamp(newTheta, gd.tMin, gd.tMax);
            });
          })
        else ...[
          _insightCard('The ball moved from ${_preCalcTheta.toStringAsFixed(1)} to ${newTheta.toStringAsFixed(2)} — exactly what the formula predicted.'),
          const SizedBox(height: 16),
          PrimaryBtn(label: 'Continue', onPressed: _advance),
        ],
      ],
    );
  }

  // Stage 4: Why magnitude matters
  Widget _stage4() {
    const thetaFar = 9.0;
    const thetaClose = 5.5;
    const eta = 0.5;
    final gradFar = gd.gradientOf(thetaFar);
    final gradClose = gd.gradientOf(thetaClose);
    final stepFar = eta * gradFar;
    final stepClose = eta * gradClose;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The gradient is larger when you\'re far from the minimum, and smaller when you\'re close.',
          style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _comparisonCard(
            'Far away',
            'θ = $thetaFar',
            '∇J = ${gradFar.toStringAsFixed(2)}',
            'Step = ${stepFar.toStringAsFixed(2)}',
            C.pink,
          )),
          const SizedBox(width: 12),
          Expanded(child: _comparisonCard(
            'Close',
            'θ = $thetaClose',
            '∇J = ${gradClose.toStringAsFixed(2)}',
            'Step = ${stepClose.toStringAsFixed(2)}',
            C.blue,
          )),
        ]),
        const SizedBox(height: 16),
        if (!_stage4Revealed)
          PrimaryBtn(label: 'Reveal insight', onPressed: () {
            setState(() => _stage4Revealed = true);
          })
        else ...[
          AnimatedOpacity(
            opacity: _stage4Revealed ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Column(children: [
              _insightCard(
                'Farther from the minimum = steeper slope = bigger steps. '
                'This natural deceleration helps GD converge — '
                'big jumps when far away, fine adjustments when close.',
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Step size ratio', style: inter(fontSize: 12, color: C.muted)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _barSegment(stepFar.abs(), 'Far', C.pink)),
                      const SizedBox(width: 8),
                      Expanded(child: _barSegment(stepClose.abs(), 'Close', C.blue)),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      '${(stepFar / stepClose).toStringAsFixed(1)}× larger step when far away',
                      style: mono(fontSize: 12, color: C.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryBtn(label: 'Continue →', onPressed: _advance),
            ]),
          ),
        ],
      ],
    );
  }

  // --- Reusable widgets ---

  Widget _sliderCard(String label, double min, double max, double value, ValueChanged<double> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
            Text('θ = ${value.toStringAsFixed(2)}', style: mono(fontSize: 13, color: C.accentLight)),
          ]),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: C.accent,
              inactiveTrackColor: C.surface3,
              thumbColor: C.accent,
              overlayColor: C.accent.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  Widget _gradientMeter(double grad) {
    final normalized = (grad / 2.5).clamp(-1.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Gradient magnitude', style: inter(fontSize: 12, color: C.muted)),
            Text(grad.abs().toStringAsFixed(3), style: mono(fontSize: 13, color: _gradColor)),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            height: 8,
            child: Stack(children: [
              Container(
                decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(4)),
              ),
              LayoutBuilder(builder: (ctx, constraints) {
                final center = constraints.maxWidth / 2;
                final barWidth = normalized.abs() * center;
                final left = normalized >= 0 ? center : center - barWidth;
                return Positioned(
                  left: left,
                  width: barWidth,
                  top: 0, bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(color: _gradColor, borderRadius: BorderRadius.circular(4)),
                  ),
                );
              }),
              LayoutBuilder(builder: (ctx, constraints) {
                return Positioned(
                  left: constraints.maxWidth / 2 - 1,
                  width: 2, top: 0, bottom: 0,
                  child: Container(color: C.muted.withValues(alpha: 0.4)),
                );
              }),
            ]),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('← downhill', style: inter(fontSize: 10, color: C.blue.withValues(alpha: 0.6))),
            Text('zero', style: inter(fontSize: 10, color: C.muted)),
            Text('uphill →', style: inter(fontSize: 10, color: C.pink.withValues(alpha: 0.6))),
          ]),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: C.txt)),
          const SizedBox(height: 6),
          Text(body, style: inter(fontSize: 13, color: C.muted)),
        ],
      ),
    );
  }

  Widget _insightCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.lightbulb_outline, size: 16, color: C.green),
            const SizedBox(width: 8),
            Text('INSIGHT', style: spaceGrotesk(fontSize: 11, color: C.green, letterSpacing: 0.1)),
          ]),
          const SizedBox(height: 12),
          Text(text, style: inter(fontSize: 14, color: C.txt, height: 1.5)),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(label, style: inter(fontSize: 11, color: C.muted)),
        const SizedBox(height: 2),
        Text(value, style: mono(fontSize: 13, color: C.txt)),
      ]),
    );
  }

  Widget _calcStep(String label, String value, Color color, bool visible) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 400),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: inter(fontSize: 11, color: C.muted)),
            const SizedBox(height: 2),
            Text(value, style: mono(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _comparisonCard(String title, String theta, String grad, String step, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 10),
          Text(theta, style: mono(fontSize: 13, color: C.txt)),
          const SizedBox(height: 4),
          Text(grad, style: mono(fontSize: 13, color: C.muted)),
          const SizedBox(height: 4),
          Text(step, style: mono(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _barSegment(double value, String label, Color color) {
    final fraction = (value / 2.0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: inter(fontSize: 10, color: C.muted)),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }
}
