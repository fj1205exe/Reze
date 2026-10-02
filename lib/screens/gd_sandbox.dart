import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

class _RunLog {
  final double startTheta;
  final double lr;
  final int steps;
  final bool converged;
  final double finalLoss;
  const _RunLog({
    required this.startTheta,
    required this.lr,
    required this.steps,
    required this.converged,
    required this.finalLoss,
  });
}

class GDSandboxScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDSandboxScreen({super.key, required this.onNext, required this.onBack});
  @override
  State<GDSandboxScreen> createState() => _GDSandboxScreenState();
}

class _GDSandboxScreenState extends State<GDSandboxScreen> {
  double _startTheta = 8.0;
  double _theta = 8.0;
  double _lr = 0.8;
  List<double> _history = [];
  int _steps = 0;
  double _bestLoss = double.infinity;
  bool _autoRunning = false;
  Timer? _autoTimer;
  final List<_RunLog> _runs = [];

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  void _step() {
    if (gd.isConverged(_theta) && _steps > 0) return;
    setState(() {
      _history.add(_theta);
      _theta = gd.clamp(gd.gdStep(_theta, _lr), gd.tMin, gd.tMax);
      _steps++;
      final loss = gd.lossFunc(_theta);
      if (loss < _bestLoss) _bestLoss = loss;
    });

    if (gd.isConverged(_theta) || _steps >= 30) {
      _stopAuto();
      _logRun();
    }
  }

  void _toggleAuto() {
    if (_autoRunning) {
      _stopAuto();
    } else {
      setState(() => _autoRunning = true);
      _autoTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
        if (!mounted) {
          _stopAuto();
          return;
        }
        _step();
      });
    }
  }

  void _stopAuto() {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (mounted) setState(() => _autoRunning = false);
  }

  void _logRun() {
    if (_steps == 0) return;
    setState(() {
      _runs.insert(
        0,
        _RunLog(
          startTheta: _startTheta,
          lr: _lr,
          steps: _steps,
          converged: gd.isConverged(_theta),
          finalLoss: gd.lossFunc(_theta),
        ),
      );
      if (_runs.length > 3) _runs.removeLast();
    });
  }

  void _reset() {
    _stopAuto();
    if (_steps > 0) _logRun();
    setState(() {
      _theta = _startTheta;
      _history = [];
      _steps = 0;
      _bestLoss = double.infinity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loss = gd.lossFunc(_theta);
    final grad = gd.gradientOf(_theta);
    final converged = gd.isConverged(_theta) && _steps > 0;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
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
                          color: C.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: C.accent.withValues(alpha: 0.25)),
                        ),
                        child: Text('SANDBOX', style: spaceGrotesk(fontSize: 11, color: C.accent)),
                      ),
                      const SizedBox(height: 4),
                      Text('Free Play', style: spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  )),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: converged
                      ? C.green.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: 12, left: 12, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('J(θ)', style: inter(fontSize: 12, color: C.muted)),
                      Text(loss.toStringAsFixed(3), style: mono(fontSize: 16, color: C.accentLight)),
                    ],
                  )),
                  if (converged)
                    Positioned(top: 12, right: 12, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: C.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Converged!', style: mono(fontSize: 11, color: C.green)),
                    )),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: LossCurveWidget(theta: _theta, history: _history, showMinMarker: true, height: 190),
                  ),
                ],
              ),
            ),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(children: [
              // Stats row
              Row(children: [
                Expanded(child: _statBox('θ', _theta.toStringAsFixed(3))),
                const SizedBox(width: 8),
                Expanded(child: _statBox('∇J(θ)', grad.toStringAsFixed(3))),
                const SizedBox(width: 8),
                Expanded(child: _statBox('Steps', '$_steps')),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _statBox('Loss', loss.toStringAsFixed(3))),
                const SizedBox(width: 8),
                Expanded(child: _statBox('Best', _bestLoss == double.infinity ? '—' : _bestLoss.toStringAsFixed(3))),
              ]),
              const SizedBox(height: 12),

              // Start position slider
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Start position', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
                        Text('θ₀ = ${_startTheta.toStringAsFixed(1)}', style: mono(fontSize: 13, color: C.blue)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: C.blue,
                        inactiveTrackColor: C.surface3,
                        thumbColor: C.blue,
                        overlayColor: C.blue.withValues(alpha: 0.15),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _startTheta,
                        min: 0.5,
                        max: 9.5,
                        onChanged: _steps == 0 && !_autoRunning
                            ? (v) => setState(() {
                                _startTheta = v;
                                _theta = v;
                              })
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Learning rate', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500)),
                        Text('η = ${_lr.toStringAsFixed(2)}', style: mono(fontSize: 13, color: C.accent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LrSlider(
                      value: _lr,
                      onChange: (v) => setState(() => _lr = v),
                      max: 3.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleAuto,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: _autoRunning ? C.green.withValues(alpha: 0.08) : C.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _autoRunning
                              ? C.green.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _autoRunning ? C.green : C.surface3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _autoRunning ? 'STOP' : 'AUTO',
                            style: spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _autoRunning ? C.green : C.txt,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryBtn(
                    label: 'Step',
                    onPressed: !_autoRunning && !converged ? _step : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: SecondaryBtn(label: 'Reset', onPressed: _reset)),
              ]),
              const SizedBox(height: 16),

              // Run log
              if (_runs.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('STRATEGY LOG', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _runs.length; i++) ...[
                  _runCard(_runs[i], i + 1),
                  if (i < _runs.length - 1) const SizedBox(height: 6),
                ],
                const SizedBox(height: 16),
              ],

              // Insight after 3 runs
              if (_runs.length >= 3)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: C.green.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: C.green.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: C.green),
                        const SizedBox(width: 8),
                        Text('INSIGHT', style: spaceGrotesk(fontSize: 11, color: C.green, letterSpacing: 0.1)),
                      ]),
                      const SizedBox(height: 12),
                      Text(
                        'Different starting points and learning rates need different strategies. In real ML, algorithms adapt η automatically.',
                        style: inter(fontSize: 14, color: C.txt, height: 1.5),
                      ),
                    ],
                  ),
                ),

              PrimaryBtn(label: 'Continue →', onPressed: widget.onNext),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: inter(fontSize: 12, color: C.muted)),
          const SizedBox(height: 2),
          Text(value, style: mono(fontSize: 14, color: C.accentLight)),
        ],
      ),
    );
  }

  Widget _runCard(_RunLog run, int number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: run.converged
              ? C.green.withValues(alpha: 0.2)
              : C.pink.withValues(alpha: 0.2),
        ),
      ),
      child: Row(children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: run.converged
                ? C.green.withValues(alpha: 0.15)
                : C.pink.withValues(alpha: 0.15),
          ),
          child: Icon(
            run.converged ? Icons.check : Icons.close,
            size: 14,
            color: run.converged ? C.green : C.pink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'θ₀=${run.startTheta.toStringAsFixed(1)}  η=${run.lr.toStringAsFixed(2)}',
              style: mono(fontSize: 12, color: C.txt),
            ),
            Text(
              run.converged
                  ? '${run.steps} steps · loss ${run.finalLoss.toStringAsFixed(3)}'
                  : 'Diverged after ${run.steps} steps',
              style: inter(fontSize: 11, color: C.muted),
            ),
          ],
        )),
      ]),
    );
  }
}
