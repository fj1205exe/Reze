import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

class _Experiment {
  final String title, goal, hint, insight;
  final double startTheta;
  final int stepLimit;
  const _Experiment({
    required this.title,
    required this.goal,
    this.hint = '',
    required this.startTheta,
    required this.stepLimit,
    required this.insight,
  });
}

const _experiments = [
  _Experiment(
    title: 'Find the sweet spot',
    goal: 'Converge in exactly 3 steps.',
    hint: 'Try η values between 0.5 and 1.5.',
    startTheta: 8.0,
    stepLimit: 3,
    insight:
        'The right learning rate depends on the problem. For this curve, η ≈ 0.8 — 1.2 works well.',
  ),
  _Experiment(
    title: 'Different start',
    goal: 'Converge in 4 steps — starting closer.',
    hint: 'Does the same η work from a different position?',
    startTheta: 6.8,
    stepLimit: 4,
    insight:
        'Closer to the minimum, the gradient is smaller — the same η takes smaller steps automatically.',
  ),
  _Experiment(
    title: 'Speed run',
    goal: 'Converge in just 2 steps from far away.',
    hint: 'You need a larger η — but not too large.',
    startTheta: 9.0,
    stepLimit: 2,
    insight:
        'The fewer steps you have, the more precisely you must choose η. This precision is what optimization algorithms are all about.',
  ),
];

class GDTuningScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDTuningScreen(
      {super.key, required this.onNext, required this.onBack});
  @override
  State<GDTuningScreen> createState() => _GDTuningScreenState();
}

class _GDTuningScreenState extends State<GDTuningScreen>
    with SingleTickerProviderStateMixin {
  int _expIdx = 0;
  double _theta = _experiments[0].startTheta;
  double _displayTheta = _experiments[0].startTheta;
  List<double> _history = [];
  int _steps = 0;
  double _userLr = 0.8;
  bool _showInsight = false;
  bool _failed = false;
  bool _showHint = false;
  int _attempts = 0;
  late AnimationController _ballAnim;
  Animation<double>? _ballTween;

  _Experiment get _exp => _experiments[_expIdx];
  bool get _isLast => _expIdx == _experiments.length - 1;
  bool get _converged => gd.isConverged(_theta);

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
    if (_showInsight || _failed) return;
    if (_steps >= _exp.stepLimit) return;

    final oldTheta = _theta;
    final newTheta =
        gd.clamp(gd.gdStep(_theta, _userLr), gd.tMin, gd.tMax);

    setState(() {
      _history.add(_theta);
      _theta = newTheta;
      _steps++;
    });

    _ballTween = Tween(begin: oldTheta, end: newTheta).animate(
      CurvedAnimation(parent: _ballAnim, curve: Curves.easeOutCubic),
    );
    _ballAnim.forward(from: 0);

    if (gd.isConverged(newTheta)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showInsight = true);
      });
    } else if (_steps >= _exp.stepLimit) {
      setState(() {
        _failed = true;
        _attempts++;
        if (_attempts >= 2) _showHint = true;
      });
    }
  }

  void _retry() => setState(() {
        _theta = _exp.startTheta;
        _displayTheta = _exp.startTheta;
        _history = [];
        _steps = 0;
        _failed = false;
      });

  void _nextExp() {
    if (_isLast) {
      widget.onNext();
      return;
    }
    final next = _experiments[_expIdx + 1];
    setState(() {
      _expIdx++;
      _theta = next.startTheta;
      _displayTheta = next.startTheta;
      _history = [];
      _steps = 0;
      _showInsight = false;
      _failed = false;
      _showHint = false;
      _attempts = 0;
    });
  }

  String get _lrZone {
    if (_userLr < 0.15) return 'very slow';
    if (_userLr < 0.5) return 'slow';
    if (_userLr <= 1.5) return 'balanced';
    if (_userLr <= 2.5) return 'aggressive';
    return 'dangerous';
  }

  Color get _zoneColor {
    if (_userLr < 0.15) return C.blue;
    if (_userLr < 0.5) return C.teal;
    if (_userLr <= 1.5) return C.green;
    if (_userLr <= 2.5) return C.yellow;
    return C.pink;
  }

  @override
  Widget build(BuildContext context) {
    final loss = gd.lossFunc(_displayTheta);
    final canStep = !_showInsight && !_failed && _steps < _exp.stepLimit;

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
                      Text('TUNING',
                          style: spaceGrotesk(
                              fontSize: 10,
                              color: C.muted,
                              letterSpacing: 0.12)),
                      Text(_exp.title,
                          style: spaceGrotesk(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  )),
                  ProgressPill(
                    current: _expIdx + (_showInsight ? 1 : 0),
                    total: _experiments.length,
                  ),
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
                  color: _showInsight
                      ? C.green.withValues(alpha: 0.2)
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
                          border: Border.all(
                              color: _zoneColor.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _zoneColor)),
                              const SizedBox(width: 6),
                              Text(_lrZone,
                                  style: inter(
                                      fontSize: 11, color: _zoneColor)),
                            ]),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: C.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: C.accent.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_exp.goal,
                        style: spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: C.txt)),
                    if (_showHint && _exp.hint.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Hint: ${_exp.hint}',
                          style: inter(fontSize: 13, color: C.yellow)),
                    ],
                  ],
                ),
              ),
              if (!_showInsight && !_failed) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
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
                        value: _userLr,
                        onChange: (v) => setState(() => _userLr = v),
                        max: 3.0,
                      ),
                    ],
                  ),
                ),
                Row(children: [
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Steps',
                            style: inter(fontSize: 12, color: C.muted)),
                        Text('$_steps / ${_exp.stepLimit}',
                            style: mono(fontSize: 13, color: C.txt)),
                      ],
                    ),
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Distance',
                            style: inter(fontSize: 12, color: C.muted)),
                        Text(
                            (_theta - gd.trueMin)
                                .abs()
                                .toStringAsFixed(2),
                            style: mono(
                                fontSize: 13,
                                color: _converged ? C.green : C.txt)),
                      ],
                    ),
                  )),
                ]),
                const SizedBox(height: 12),
                if (canStep)
                  PrimaryBtn(label: 'Step', onPressed: _step),
              ],
              if (_failed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: C.pink.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: C.pink.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                      'Not quite — distance: ${(_theta - gd.trueMin).abs().toStringAsFixed(2)}',
                      style: inter(fontSize: 14, color: C.pink)),
                ),
                PrimaryBtn(label: 'Try again', onPressed: _retry),
              ],
              if (_showInsight) ...[
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: C.green.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: C.green.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.lightbulb_outline,
                              size: 16, color: C.green),
                          const SizedBox(width: 8),
                          Text('INSIGHT',
                              style: spaceGrotesk(
                                  fontSize: 11,
                                  color: C.green,
                                  letterSpacing: 0.1)),
                        ]),
                        const SizedBox(height: 12),
                        Text(_exp.insight,
                            style: inter(
                                fontSize: 14,
                                color: C.txt,
                                height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryBtn(
                  label: _isLast
                      ? 'Understand the gradient →'
                      : 'Next experiment',
                  onPressed: _nextExp,
                ),
              ],
            ]),
          )),
        ],
      ),
    );
  }
}
