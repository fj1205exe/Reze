import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/neuralnet.dart' as nn;

const _targetOutput = 0.7;
const _maxAttempts = 8;
const _x1 = 0.8;
const _x2 = 0.6;

class NNChallengeScreen extends StatefulWidget {
  final void Function(bool success, int attempts) onComplete;
  final VoidCallback onBack;

  const NNChallengeScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<NNChallengeScreen> createState() => _NNChallengeScreenState();
}

class _NNChallengeScreenState extends State<NNChallengeScreen> {
  double _w1 = 0.0;
  double _w2 = 0.0;
  double _bias = 0.0;
  int _lockIns = 0;
  bool _hasSucceeded = false;
  bool _hasMoved = false;

  Map<String, double> get _fwd => nn.neuronForward(_x1, _x2, _w1, _w2, _bias);
  double get _z => _fwd['z']!;
  double get _output => _fwd['output']!;
  bool get _exhausted => _lockIns >= _maxAttempts && !_hasSucceeded;
  bool get _done => _hasSucceeded || _exhausted;

  String get _feedback {
    if (_hasSucceeded) return 'Output ≥ $_targetOutput — neuron activated!';
    if (_exhausted) return 'Out of lock-ins. Retry with a fresh start.';
    if (_output < 0.3) return 'Output very low. Increase weights or add positive bias.';
    if (_output < 0.5) return 'Getting warmer. The weighted sum z needs to be higher for sigmoid to push past 0.5.';
    if (_output < _targetOutput) return 'Almost there! A small bias increase can push you over the threshold.';
    return 'Adjust the sliders, then lock in.';
  }

  String get _feedbackType {
    if (_hasSucceeded) return 'ok';
    if (_exhausted) return 'warn';
    if (_output >= 0.5) return 'info';
    return 'warn';
  }

  void _lockIn() {
    if (_done || !_hasMoved) return;
    setState(() {
      _lockIns++;
      _hasMoved = false;
      if (_output >= _targetOutput) _hasSucceeded = true;
    });
  }

  void _retry() {
    setState(() {
      _w1 = 0.0;
      _w2 = 0.0;
      _bias = 0.0;
      _lockIns = 0;
      _hasSucceeded = false;
      _hasMoved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final outputColor = _output >= _targetOutput ? C.green : (_output >= 0.5 ? C.yellow : C.pink);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(
            label: 'NN Challenge',
            onBack: widget.onBack,
            right: StepCounter(steps: _lockIns, max: _maxAttempts),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activate the neuron.', style: spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Set weights and bias so output ≥ $_targetOutput.', style: inter(fontSize: 14, color: C.muted)),
                  const SizedBox(height: 16),

                  // Computation card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: outputColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('forward pass', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        // Input × Weight rows
                        _computeRow('x₁ × w₁', _x1, _w1, _x1 * _w1, C.blue),
                        const SizedBox(height: 6),
                        _computeRow('x₂ × w₂', _x2, _w2, _x2 * _w2, C.accentLight),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('bias', style: inter(fontSize: 12, color: C.muted)),
                            const Spacer(),
                            Text(_bias.toStringAsFixed(3), style: mono(fontSize: 14, color: C.yellow)),
                          ],
                        ),
                        const Divider(color: C.surface3, height: 20),
                        Row(
                          children: [
                            Text('z = Σ(xᵢwᵢ) + b', style: inter(fontSize: 12, color: C.muted)),
                            const Spacer(),
                            Text(_z.toStringAsFixed(4), style: mono(fontSize: 16, fontWeight: FontWeight.w600, color: C.txt)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('σ(z) = output', style: inter(fontSize: 12, color: C.muted)),
                            const Spacer(),
                            Text(_output.toStringAsFixed(4), style: mono(fontSize: 20, fontWeight: FontWeight.w700, color: outputColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Output bar
                        Stack(
                          children: [
                            Container(
                              height: 12,
                              decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(6)),
                            ),
                            FractionallySizedBox(
                              widthFactor: _output.clamp(0, 1),
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(color: outputColor, borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                            Positioned(
                              left: _targetOutput * (MediaQuery.of(context).size.width - 64 - 32),
                              child: Container(width: 2, height: 12, color: Colors.white.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('target: $_targetOutput', style: inter(fontSize: 10, color: C.muted)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  FeedbackBar(message: _feedback, type: _feedbackType),
                  const SizedBox(height: 14),

                  if (!_done) ...[
                    _sliderCard('w₁', _w1, C.blue, (v) => setState(() { _w1 = v; _hasMoved = true; })),
                    const SizedBox(height: 10),
                    _sliderCard('w₂', _w2, C.accentLight, (v) => setState(() { _w2 = v; _hasMoved = true; })),
                    const SizedBox(height: 10),
                    _sliderCard('bias', _bias, C.yellow, (v) => setState(() { _bias = v; _hasMoved = true; })),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _hasMoved ? _lockIn : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: C.yellow,
                          disabledBackgroundColor: C.surface3,
                          foregroundColor: C.bg,
                          shape: RoundedRectangleBorder(borderRadius: S.borderSm),
                          elevation: 0,
                        ),
                        child: Text(
                          'LOCK IN  (${_maxAttempts - _lockIns} left)',
                          style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600,
                              color: _hasMoved ? C.bg : C.muted),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  if (_hasSucceeded)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: PrimaryBtn(label: 'Continue', onPressed: () => widget.onComplete(true, _lockIns)),
                    ),
                  if (_exhausted) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: SecondaryBtn(label: 'Retry', onPressed: _retry),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 250),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: PrimaryBtn(label: 'Continue anyway', onPressed: () => widget.onComplete(false, _lockIns)),
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

  Widget _computeRow(String label, double a, double b, double result, Color color) {
    return Row(
      children: [
        Text(label, style: inter(fontSize: 12, color: C.muted)),
        const Spacer(),
        Text('${a.toStringAsFixed(2)} × ${b.toStringAsFixed(3)} = ',
            style: mono(fontSize: 12, color: C.muted)),
        Text(result.toStringAsFixed(4), style: mono(fontSize: 14, color: color)),
      ],
    );
  }

  Widget _sliderCard(String label, double value, Color color, ValueChanged<double> onChange) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: S.borderMd,
        border: Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
              Text(value.toStringAsFixed(3), style: mono(fontSize: 13, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: C.surface3,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: -2.0,
              max: 2.0,
              onChanged: _done ? null : onChange,
            ),
          ),
        ],
      ),
    );
  }
}
