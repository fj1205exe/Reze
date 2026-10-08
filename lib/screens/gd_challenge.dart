import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

class _Round {
  final String title, brief;
  final double startTheta;
  final int maxSteps;
  final double lrMin, lrMax, defaultLr;
  const _Round({
    required this.title,
    required this.brief,
    required this.startTheta,
    required this.maxSteps,
    this.lrMin = 0.01,
    this.lrMax = 3.0,
    this.defaultLr = 0.8,
  });
}

const _rounds = [
  _Round(
    title: 'Speed',
    brief: 'Far away. Only 2 steps.',
    startTheta: 9.2,
    maxSteps: 2,
    defaultLr: 1.0,
  ),
  _Round(
    title: 'Constrained',
    brief: 'η locked between 1.0–1.5. 4 steps.',
    startTheta: 8.5,
    maxSteps: 4,
    lrMin: 1.0,
    lrMax: 1.5,
    defaultLr: 1.2,
  ),
  _Round(
    title: 'Adapt',
    brief: 'Change η between steps. 4 steps total.',
    startTheta: 9.5,
    maxSteps: 4,
    defaultLr: 1.0,
  ),
];

class GDChallengeScreen extends StatefulWidget {
  final void Function(int passed, int total, int totalSteps) onComplete;
  final VoidCallback onBack;
  const GDChallengeScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });
  @override
  State<GDChallengeScreen> createState() => _GDChallengeScreenState();
}

class _GDChallengeScreenState extends State<GDChallengeScreen>
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
  bool _allDone = false;
  late AnimationController _ballAnim;
  Animation<double>? _ballTween;

  _Round get _round => _rounds[_roundIdx];
  bool get _mastered => _passed >= 2;

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
      setState(() => _allDone = true);
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

  void _finish() {
    widget.onComplete(_passed, _rounds.length, _totalSteps);
  }

  @override
  Widget build(BuildContext context) {
    final loss = gd.lossFunc(_displayTheta);
    final dist = (_theta - gd.trueMin).abs();
    final canStep = !_roundDone && _steps < _round.maxSteps;

    if (_allDone) return _summaryView();

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
                        borderRadius: S.borderSm,
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
                          color: C.yellow.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: C.yellow.withValues(alpha: 0.25)),
                        ),
                        child: Text('CHALLENGE',
                            style: spaceGrotesk(
                                fontSize: 11, color: C.yellow)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          'Round ${_roundIdx + 3}: ${_round.title}',
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
                      : C.border,
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
                          borderRadius: S.borderSm,
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
                  Expanded(
                      child:
                          _statBox('Steps', '$_steps / ${_round.maxSteps}')),
                  const SizedBox(width: 8),
                  Expanded(
                      child:
                          _statBox('Distance', dist.toStringAsFixed(2))),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: C.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Learning rate',
                              style: spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          if (_round.lrMin > 0.01 ||
                              _round.lrMax < 3.0)
                            Text(
                                '${_round.lrMin.toStringAsFixed(1)}–${_round.lrMax.toStringAsFixed(1)}',
                                style: mono(
                                    fontSize: 11, color: C.yellow)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LrSlider(
                        value:
                            _lr.clamp(_round.lrMin, _round.lrMax),
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
                FadeSlideIn(
                  duration: const Duration(milliseconds: 400),
                  slideDistance: 14,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: (_roundPassed ? C.green : C.pink)
                          .withValues(alpha: 0.08),
                      borderRadius: S.borderMd,
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
                ),
                Text('Score: $_passed / ${_roundIdx + 1}',
                    style: mono(fontSize: 14, color: C.accent)),
                const SizedBox(height: 16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 400),
                  slideDistance: 12,
                  child: PrimaryBtn(
                    label: _roundIdx < _rounds.length - 1
                        ? 'Next round'
                        : 'See results',
                    onPressed: _roundIdx < _rounds.length - 1
                        ? _nextRound
                        : () => setState(() => _allDone = true),
                  ),
                ),
              ],
            ]),
          )),
        ],
      ),
    );
  }

  Widget _summaryView() {
    final mastered = _mastered;
    return Container(
      color: C.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                duration: const Duration(milliseconds: 450),
                slideDistance: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (mastered ? C.green : C.yellow)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: (mastered ? C.green : C.yellow)
                                .withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        mastered ? 'CHALLENGE COMPLETE' : 'GOOD EFFORT',
                        style: spaceGrotesk(
                            fontSize: 12,
                            color: mastered ? C.green : C.yellow,
                            letterSpacing: 0.1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Gradient Descent',
                        style: spaceGrotesk(
                            fontSize: 28, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: _metricCard('Rounds',
                        '$_passed / ${_rounds.length}', mastered ? C.green : C.yellow)),
                const SizedBox(width: 12),
                Expanded(
                    child: _metricCard(
                        'Total steps', '$_totalSteps', C.accent)),
              ]),
              const SizedBox(height: 12),
              for (int i = 0; i < _rounds.length; i++) ...[
                _roundResultTile(
                    i,
                    i < _roundIdx ||
                        (i == _roundIdx && _roundPassed)),
                if (i < _rounds.length - 1) const SizedBox(height: 8),
              ],
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: S.borderMd,
                  border: Border.all(
                      color: C.border),
                ),
                child: Text(
                  mastered
                      ? 'You\'ve demonstrated control over learning rate across different scenarios — the core skill of gradient descent.'
                      : 'Pass 2 of ${_rounds.length} rounds to master this concept. Each round tests a different aspect of choosing the right learning rate.',
                  style:
                      inter(fontSize: 14, color: C.txt, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                duration: const Duration(milliseconds: 400),
                slideDistance: 12,
                child: Column(children: [
                  if (mastered)
                    PrimaryBtn(
                        label: 'Free play sandbox →', onPressed: _finish)
                  else ...[
                    PrimaryBtn(
                        label: 'Retry challenge',
                        onPressed: () {
                          final first = _rounds[0];
                          setState(() {
                            _roundIdx = 0;
                            _theta = first.startTheta;
                            _displayTheta = first.startTheta;
                            _history = [];
                            _steps = 0;
                            _lr = first.defaultLr;
                            _roundDone = false;
                            _roundPassed = false;
                            _passed = 0;
                            _totalSteps = 0;
                            _allDone = false;
                          });
                        }),
                    const SizedBox(height: 12),
                    SecondaryBtn(
                        label: 'Continue anyway', onPressed: _finish),
                  ],
                ]),
              ),
            ],
          ),
        ),
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
        borderRadius: S.borderSm,
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

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: S.borderMd,
        border:
            Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: inter(fontSize: 12, color: C.muted)),
          const SizedBox(height: 6),
          Text(value,
              style: mono(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }

  Widget _roundResultTile(int roundNum, bool passed) {
    final names = [
      'Speed',
      'Constrained',
      'Adapt',
    ];
    final attempted = roundNum <= _roundIdx;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: S.borderSm,
        border: Border.all(
            color: attempted
                ? (passed ? C.green : C.pink)
                    .withValues(alpha: 0.2)
                : C.dim),
      ),
      child: Row(children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: attempted
                ? (passed ? C.green : C.pink)
                    .withValues(alpha: 0.15)
                : C.surface2,
          ),
          child: Icon(
            attempted
                ? (passed ? Icons.check : Icons.close)
                : null,
            size: 14,
            color: passed ? C.green : C.pink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text('Round ${roundNum + 1} — ${names[roundNum]}',
                style: inter(
                    fontSize: 13,
                    color: attempted ? C.txt : C.muted))),
        Text(
            attempted ? (passed ? 'Passed' : 'Failed') : '',
            style: inter(
                fontSize: 12,
                color: passed ? C.green : C.pink)),
      ]),
    );
  }
}
