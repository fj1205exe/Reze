import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;
import '../utils/sgd.dart' as sgd;

const _maxSteps = 15;
const _startTheta = 8.5;

class SGDChallengeScreen extends StatefulWidget {
  final void Function(bool success, int steps, double loss) onComplete;
  final VoidCallback onBack;

  const SGDChallengeScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<SGDChallengeScreen> createState() => _SGDChallengeScreenState();
}

class _SGDChallengeScreenState extends State<SGDChallengeScreen> {
  double _theta = _startTheta;
  List<double> _history = [];
  double _lr = 0.3;
  sgd.BatchSize _batch = sgd.BatchSize.full;
  int _steps = 0;

  bool get _converged => gd.isConverged(_theta);
  bool get _exhausted => _steps >= _maxSteps;
  bool get _done => _converged || _exhausted;

  String get _feedback {
    if (_converged) return 'Converged in $_steps steps!';
    if (_exhausted) return 'Out of steps. The strategy matters — try again.';
    if (_steps == 0) return 'Choose your batch size and learning rate, then step.';
    final loss = gd.lossFunc(_theta);
    if (loss > gd.lossFunc(_startTheta) * 0.95) {
      return 'Barely moved. Increase learning rate or try a different batch size.';
    }
    if (_steps > 8 && !_converged) {
      return 'Running low on steps. Are you overshooting?';
    }
    if (gd.lossFunc(_theta) > gd.lossFunc(_history.last)) {
      return 'Loss went up! You may be overshooting — lower the learning rate.';
    }
    return '${_maxSteps - _steps} steps left. Keep going.';
  }

  String get _feedbackType {
    if (_converged) return 'ok';
    if (_exhausted) return 'warn';
    if (_steps > 0 && _history.isNotEmpty && gd.lossFunc(_theta) > gd.lossFunc(_history.last)) {
      return 'warn';
    }
    return 'info';
  }

  void _step() {
    if (_done) return;
    setState(() {
      _history.add(_theta);
      final next = gd.clamp(
        sgd.sgdStep(_theta, _lr, _batch),
        gd.tMin,
        gd.tMax,
      );
      _theta = next;
      _steps++;
    });
  }

  void _retry() {
    setState(() {
      _theta = _startTheta;
      _history = [];
      _lr = 0.3;
      _batch = sgd.BatchSize.full;
      _steps = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'SGD Challenge', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Converge in $_maxSteps steps.',
                      style: spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Pick the right batch size and learning rate.',
                    style: inter(fontSize: 14, color: C.muted),
                  ),
                  const SizedBox(height: 12),

                  // Metrics row
                  Row(
                    children: [
                      StepCounter(steps: _steps, max: _maxSteps),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _converged
                              ? C.green.withValues(alpha: 0.12)
                              : C.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _converged
                                ? C.green.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Loss: ', style: inter(fontSize: 12, color: C.muted)),
                            Text(
                              gd.lossFunc(_theta).toStringAsFixed(3),
                              style: mono(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _converged ? C.green : C.accentLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Loss curve
                  Container(
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: LossCurveWidget(
                      theta: _theta,
                      history: _history,
                      height: 190,
                    ),
                  ),
                  const SizedBox(height: 14),

                  FeedbackBar(message: _feedback, type: _feedbackType),
                  const SizedBox(height: 14),

                  if (!_done) ...[
                    // Batch size selector
                    Text('Batch size', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: sgd.BatchSize.values.map((b) {
                        final sel = _batch == b;
                        final color = b == sgd.BatchSize.full
                            ? C.accent
                            : b == sgd.BatchSize.mini
                                ? C.blue
                                : C.yellow;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _batch = b),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: b != sgd.BatchSize.stochastic ? 6 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? color.withValues(alpha: 0.15) : C.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sel ? color : Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  b == sgd.BatchSize.full
                                      ? 'Full'
                                      : b == sgd.BatchSize.mini
                                          ? 'Mini'
                                          : 'Stochastic',
                                  style: spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sel ? color : C.muted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Learning rate slider
                    Container(
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
                              Text('Learning rate', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(_lr.toStringAsFixed(2), style: mono(fontSize: 13, color: C.accentLight)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: C.accentLight,
                              inactiveTrackColor: C.surface3,
                              thumbColor: C.accentLight,
                              overlayColor: C.accentLight.withValues(alpha: 0.15),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            ),
                            child: Slider(
                              value: _lr,
                              min: 0.01,
                              max: 1.0,
                              onChanged: (v) => setState(() => _lr = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    PrimaryBtn(label: 'Step', onPressed: _step),
                  ],

                  if (_done) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _converged
                            ? C.green.withValues(alpha: 0.1)
                            : C.pink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_converged ? C.green : C.pink).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _converged ? Icons.emoji_events : Icons.replay,
                                size: 18,
                                color: _converged ? C.yellow : C.pink,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _converged ? 'Challenge passed!' : 'Not quite — try again',
                                style: spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _converged
                                ? 'Converged in $_steps step${_steps == 1 ? '' : 's'} using ${sgd.batchLabels[_batch]} at lr=${ _lr.toStringAsFixed(2)}.'
                                : 'The default settings overshoot. Try lowering the learning rate or switching to mini-batch.',
                            style: inter(fontSize: 13, color: _converged ? C.green : C.pink),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_converged)
                      PrimaryBtn(label: 'Continue', onPressed: () => widget.onComplete(true, _steps, gd.lossFunc(_theta)))
                    else
                      PrimaryBtn(label: 'Retry', onPressed: _retry),
                    if (!_converged) ...[
                      const SizedBox(height: 12),
                      SecondaryBtn(label: 'Skip to results', onPressed: () => widget.onComplete(false, _steps, gd.lossFunc(_theta))),
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
}
