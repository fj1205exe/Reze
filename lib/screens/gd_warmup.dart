import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

class _Round {
  final String title, brief;
  final double startTheta;
  final int maxSteps;
  final double defaultLr;
  const _Round({
    required this.title,
    required this.brief,
    required this.startTheta,
    required this.maxSteps,
    this.defaultLr = 0.8,
  });
}

const _rounds = [
  _Round(
    title: 'Warm-up',
    brief: 'Converge in 6 steps. Easy start.',
    startTheta: 8.0,
    maxSteps: 6,
  ),
  _Round(
    title: 'Precision',
    brief: 'Start close. Converge in 3 steps.',
    startTheta: 6.2,
    maxSteps: 3,
    defaultLr: 0.3,
  ),
];

class GDWarmupScreen extends StatefulWidget {
  final void Function(int passed, int totalSteps) onNext;
  final VoidCallback onBack;
  const GDWarmupScreen(
      {super.key, required this.onNext, required this.onBack});
  @override
  State<GDWarmupScreen> createState() => _GDWarmupScreenState();
}

class _GDWarmupScreenState extends State<GDWarmupScreen>
    with SingleTickerProviderStateMixin {
  int _roundIdx = 0;
  double _theta = _rounds[0].startTheta;
  double _displayTheta = _rounds[0].startTheta;
  List<double> _history = [];
  int _steps = 0;
  double _lr = _rounds[0].defaultLr;
  bool _roundDone = false;
  bool _roundPassed = false;
  int _passed = 0;
  int _totalSteps = 0;
  late AnimationController _ballAnim;
  Animation<double>? _ballTween;

  _Round get _round => _rounds[_roundIdx];

  @override
  void initState() {
    super.initState();
    _ballAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        if (_ballTween != null) {
          setState(() => _displayTheta = _ballTween!.value);
        }
      });
  }

  @override
  void dispose() {
    _ballAnim.dispose();
    super.dispose();
  }

  void _step() {
    if (_roundDone || _steps >= _round.maxSteps) return;

    final oldTheta = _theta;
    final newTheta = gd.clamp(gd.gdStep(_theta, _lr), gd.tMin, gd.tMax);

    setState(() {
      _history.add(_theta);
      _theta = newTheta;
      _steps++;
      _totalSteps++;
    });

    _ballTween = Tween(begin: oldTheta, end: newTheta).animate(
      CurvedAnimation(parent: _ballAnim, curve: Curves.easeOutCubic),
    );
    _ballAnim.forward(from: 0);

    final converged = gd.isConverged(newTheta);
    final outOfSteps = _steps >= _round.maxSteps;

    if (converged || outOfSteps) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _roundDone = true;
            _roundPassed = converged;
            if (converged) _passed++;
          });
        }
      });
    }
  }

  void _nextRound() {
    if (_roundIdx >= _rounds.length - 1) {
      widget.onNext(_passed, _totalSteps);
      return;
    }
    final next = _rounds[_roundIdx + 1];
    setState(() {
      _roundIdx++;
      _theta = next.startTheta;
      _displayTheta = next.startTheta;
      _history = [];
      _steps = 0;
      _lr = next.defaultLr;
      _roundDone = false;
      _roundPassed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loss = gd.lossFunc(_displayTheta);
    final dist = (_theta - gd.trueMin).abs();
    final canStep = !_roundDone && _steps < _round.maxSteps;

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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: C.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: C.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: C.blue.withValues(alpha: 0.25)),
                        ),
                        child: Text('WARM-UP',
                            style: spaceGrotesk(
                                fontSize: 11, color: C.blue)),
                      ),
                      const SizedBox(height: 4),
                      Text('Round ${_roundIdx + 1}: ${_round.title}',
                          style: spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ],
                  )),
                  _roundIndicator(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_round.brief,
                  style: inter(
                      fontSize: 15,
                      color: const Color(0xFFD1D5DB))),
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
                  color: _roundDone
                      ? (_roundPassed ? C.green : C.pink)
                          .withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                      top: 12,
                      left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('J(θ)',
                              style: inter(fontSize: 12, color: C.muted)),
                          Text(loss.toStringAsFixed(3),
                              style:
                                  mono(fontSize: 16, color: C.accentLight)),
                        ],
                      )),
                  Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: C.surface2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                            '${_round.maxSteps - _steps} left',
                            style:
                                mono(fontSize: 12, color: C.yellow)),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: LossCurveWidget(
                      theta: _displayTheta,
                      history: _history,
                      showMinMarker: true,
                      height: 190,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(children: [
              if (!_roundDone) ...[
                Row(children: [
                  Expanded(child: _statBox('Steps', '$_steps / ${_round.maxSteps}')),
                  const SizedBox(width: 8),
                  Expanded(child: _statBox('Distance', dist.toStringAsFixed(2))),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Learning rate',
                          style: spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      LrSlider(
                        value: _lr.clamp(_round.lrMin, _round.lrMax),
                        onChange: (v) => setState(() => _lr = v),
                        min: _round.lrMin,
                        max: _round.lrMax,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (canStep)
                  PrimaryBtn(
                      label: _steps == 0 ? 'Start' : 'Step',
                      onPressed: _step),
              ],
              if (_roundDone) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (_roundPassed ? C.green : C.pink)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: (_roundPassed ? C.green : C.pink)
                            .withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _roundPassed
                            ? 'Converged in $_steps steps!'
                            : 'Not quite — distance: ${dist.toStringAsFixed(2)}',
                        style: spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _roundPassed ? C.green : C.pink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _roundPassed
                            ? 'η = ${_lr.toStringAsFixed(2)} worked well.'
                            : 'Try a different η next time.',
                        style: inter(
                            fontSize: 13,
                            color: (_roundPassed ? C.green : C.pink)
                                .withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),
                Text('Score: $_passed / ${_roundIdx + 1}',
                    style: mono(fontSize: 14, color: C.accent)),
                const SizedBox(height: 16),
                PrimaryBtn(
                  label: _roundIdx < _rounds.length - 1
                      ? 'Next round'
                      : 'Start the real challenge →',
                  onPressed: _nextRound,
                ),
              ],
            ]),
          )),
        ],
      ),
    );
  }

  Widget _roundIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_rounds.length, (i) {
        Color c;
        if (i < _roundIdx) {
          c = C.green;
        } else if (i == _roundIdx) {
          c = _roundDone
              ? (_roundPassed ? C.green : C.pink)
              : C.accent;
        } else {
          c = C.surface3;
        }
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(shape: BoxShape.circle, color: c),
        );
      }),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: inter(fontSize: 12, color: C.muted)),
          Text(value, style: mono(fontSize: 13, color: C.txt)),
        ],
      ),
    );
  }
}
