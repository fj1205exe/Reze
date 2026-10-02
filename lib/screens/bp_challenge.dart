import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/neuralnet.dart' as nn;

class BPChallengeScreen extends StatefulWidget {
  final void Function(bool success, int correct, double loss) onComplete;
  final VoidCallback onBack;

  const BPChallengeScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<BPChallengeScreen> createState() => _BPChallengeScreenState();
}

enum _Dir { increase, decrease, noChange }

class _BPChallengeScreenState extends State<BPChallengeScreen> {
  final _net = const nn.MiniNetwork(w1: 0.4, w2: -0.3, wh: 0.6, b1: 0.1, b2: -0.1);
  final _x1 = 0.7;
  final _x2 = 0.9;

  _Dir? _ansW1;
  _Dir? _ansW2;
  _Dir? _ansWh;
  bool _submitted = false;
  int _retries = 0;

  Map<String, double> get _bwd => nn.networkBackward(_net, _x1, _x2);
  Map<String, double> get _fwd => nn.networkForward(_net, _x1, _x2);

  _Dir _correctDir(double grad) {
    if (grad > 0.001) return _Dir.decrease;
    if (grad < -0.001) return _Dir.increase;
    return _Dir.noChange;
  }

  bool _isCorrect(String weight) {
    final grads = _bwd;
    switch (weight) {
      case 'w1': return _ansW1 == _correctDir(grads['dL_dw1']!);
      case 'w2': return _ansW2 == _correctDir(grads['dL_dw2']!);
      case 'wh': return _ansWh == _correctDir(grads['dL_dwh']!);
      default: return false;
    }
  }

  int get _correctCount {
    int c = 0;
    if (_isCorrect('w1')) c++;
    if (_isCorrect('w2')) c++;
    if (_isCorrect('wh')) c++;
    return c;
  }

  bool get _passed => _correctCount >= 2;
  bool get _allAnswered => _ansW1 != null && _ansW2 != null && _ansWh != null;

  void _submit() => setState(() => _submitted = true);

  void _retry() {
    setState(() {
      _ansW1 = null;
      _ansW2 = null;
      _ansWh = null;
      _submitted = false;
      _retries++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fwd = _fwd;
    final bwd = _bwd;
    final loss = fwd['loss']!;
    final y = fwd['y']!;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'BP Challenge', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Predict the gradient.', style: spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Which direction should each weight move to reduce loss?',
                      style: inter(fontSize: 14, color: C.muted)),
                  const SizedBox(height: 16),

                  // Network state
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
                        Text('network state', style: spaceGrotesk(fontSize: 11, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        _paramRow('x₁', _x1, C.blue),
                        _paramRow('x₂', _x2, C.accentLight),
                        _paramRow('w₁', _net.w1, C.txt),
                        _paramRow('w₂', _net.w2, C.txt),
                        _paramRow('wₕ', _net.wh, C.txt),
                        const Divider(color: C.surface3, height: 14),
                        _paramRow('output y', y, C.yellow),
                        _paramRow('target y*', nn.yTrue, C.green),
                        _paramRow('loss (y−y*)²', loss, C.pink),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Questions
                  Text('For each weight, should it increase or decrease?',
                      style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  _weightQuestion('w₁', _ansW1, (d) => setState(() => _ansW1 = d),
                      _submitted ? _isCorrect('w1') : null,
                      _submitted ? bwd['dL_dw1']! : null),
                  const SizedBox(height: 10),
                  _weightQuestion('w₂', _ansW2, (d) => setState(() => _ansW2 = d),
                      _submitted ? _isCorrect('w2') : null,
                      _submitted ? bwd['dL_dw2']! : null),
                  const SizedBox(height: 10),
                  _weightQuestion('wₕ', _ansWh, (d) => setState(() => _ansWh = d),
                      _submitted ? _isCorrect('wh') : null,
                      _submitted ? bwd['dL_dwh']! : null),
                  const SizedBox(height: 20),

                  if (!_submitted) ...[
                    PrimaryBtn(
                      label: _allAnswered ? 'Check answers' : 'Answer all three',
                      disabled: !_allAnswered,
                      onPressed: _allAnswered ? _submit : null,
                    ),
                  ] else ...[
                    // Result
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _passed ? C.green.withValues(alpha: 0.1) : C.pink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: (_passed ? C.green : C.pink).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _passed
                                ? '$_correctCount/3 correct — you understand gradient direction!'
                                : '$_correctCount/3 correct — need at least 2. Look at the gradient signs.',
                            style: inter(fontSize: 14, color: _passed ? C.green : C.pink),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Positive gradient → weight contributed to increasing loss → decrease it.\n'
                            'Negative gradient → weight contributed to decreasing loss → increase it.',
                            style: inter(fontSize: 12, color: C.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_passed)
                      PrimaryBtn(label: 'Complete', onPressed: () => widget.onComplete(_passed, _correctCount, _fwd['loss']!)),
                    if (!_passed) ...[
                      SecondaryBtn(label: 'Retry', onPressed: _retry),
                      const SizedBox(height: 12),
                      if (_retries >= 2)
                        PrimaryBtn(label: 'Continue anyway', onPressed: () => widget.onComplete(false, _correctCount, _fwd['loss']!)),
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

  Widget _paramRow(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: inter(fontSize: 12, color: C.muted)),
          const Spacer(),
          Text(val.toStringAsFixed(3), style: mono(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Widget _weightQuestion(String label, _Dir? answer, ValueChanged<_Dir> onSelect,
      bool? correct, double? gradVal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: correct == null
              ? Colors.white.withValues(alpha: 0.06)
              : (correct ? C.green.withValues(alpha: 0.4) : C.pink.withValues(alpha: 0.4)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (correct != null)
                Icon(correct ? Icons.check_circle : Icons.cancel, size: 16,
                    color: correct ? C.green : C.pink),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _dirBtn('↑ Increase', _Dir.increase, answer, onSelect),
              const SizedBox(width: 6),
              _dirBtn('↓ Decrease', _Dir.decrease, answer, onSelect),
              const SizedBox(width: 6),
              _dirBtn('— Same', _Dir.noChange, answer, onSelect),
            ],
          ),
          if (correct != null && gradVal != null) ...[
            const SizedBox(height: 6),
            Text(
              'gradient = ${gradVal.toStringAsFixed(4)} → ${gradVal > 0.001 ? "decrease" : (gradVal < -0.001 ? "increase" : "no change")}',
              style: mono(fontSize: 11, color: C.muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dirBtn(String label, _Dir dir, _Dir? current, ValueChanged<_Dir> onSelect) {
    final selected = current == dir;
    return Expanded(
      child: GestureDetector(
        onTap: _submitted ? null : () => onSelect(dir),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? C.accent.withValues(alpha: 0.15) : C.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? C.accent : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: spaceGrotesk(fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? C.accentLight : C.muted),
          ),
        ),
      ),
    );
  }
}
