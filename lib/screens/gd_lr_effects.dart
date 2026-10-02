import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

class _Experiment {
  final String title, goal, hint, insight;
  final double startTheta;
  final double lockLr;
  final int stepLimit;
  const _Experiment({
    required this.title,
    required this.goal,
    this.hint = '',
    required this.startTheta,
    required this.lockLr,
    required this.stepLimit,
    required this.insight,
  });
}

const _experiments = [
  _Experiment(
    title: 'Experiment 1: Tiny steps',
    goal: 'Step 8 times with η = 0.05.',
    hint: 'Watch how slowly the ball moves.',
    startTheta: 8.0,
    lockLr: 0.05,
    stepLimit: 8,
    insight:
        'Small learning rate = safe but very slow. You barely moved after 8 steps.',
  ),
  _Experiment(
    title: 'Experiment 2: Giant step',
    goal: 'Step 3 times with η = 3.0.',
    hint: 'Watch what happens to the ball.',
    startTheta: 8.0,
    lockLr: 3.0,
    stepLimit: 3,
    insight:
        'Large learning rate = fast but unstable. The ball bounced wildly past the minimum each time.',
  ),
];

class GDLrEffectsScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDLrEffectsScreen(
      {super.key, required this.onNext, required this.onBack});
  @override
  State<GDLrEffectsScreen> createState() => _GDLrEffectsScreenState();
}

class _GDLrEffectsScreenState extends State<GDLrEffectsScreen>
    with SingleTickerProviderStateMixin {
  int _expIdx = 0;
  double _theta = _experiments[0].startTheta;
  double _displayTheta = _experiments[0].startTheta;
  List<double> _history = [];
  int _steps = 0;
  bool _showInsight = false;
  late AnimationController _ballAnim;
  Animation<double>? _ballTween;

  _Experiment get _exp => _experiments[_expIdx];
  bool get _isLast => _expIdx == _experiments.length - 1;

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
    if (_showInsight) return;
    if (_steps >= _exp.stepLimit) return;

    final oldTheta = _theta;
    final newTheta =
        gd.clamp(gd.gdStep(_theta, _exp.lockLr), gd.tMin, gd.tMax);

    setState(() {
      _history.add(_theta);
      _theta = newTheta;
      _steps++;
    });

    _ballTween = Tween(begin: oldTheta, end: newTheta).animate(
      CurvedAnimation(parent: _ballAnim, curve: Curves.easeOutCubic),
    );
    _ballAnim.forward(from: 0);

    if (_steps >= _exp.stepLimit) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showInsight = true);
      });
    }
  }

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
    });
  }

  String get _lrZone {
    if (_exp.lockLr < 0.15) return 'very slow';
    if (_exp.lockLr < 0.5) return 'slow';
    if (_exp.lockLr <= 1.5) return 'balanced';
    if (_exp.lockLr <= 2.5) return 'aggressive';
    return 'dangerous';
  }

  Color get _zoneColor {
    if (_exp.lockLr < 0.15) return C.blue;
    if (_exp.lockLr < 0.5) return C.teal;
    if (_exp.lockLr <= 1.5) return C.green;
    if (_exp.lockLr <= 2.5) return C.yellow;
    return C.pink;
  }

  @override
  Widget build(BuildContext context) {
    final loss = gd.lossFunc(_displayTheta);
    final canStep = !_showInsight && _steps < _exp.stepLimit;

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
                      Text('DISCOVER',
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
                    if (_exp.hint.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(_exp.hint,
                          style: inter(fontSize: 13, color: C.muted)),
                    ],
                  ],
                ),
              ),
              if (!_showInsight) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Text('η = ',
                        style: inter(fontSize: 13, color: C.muted)),
                    Text(_exp.lockLr.toStringAsFixed(2),
                        style: mono(fontSize: 15, color: C.accent)),
                    Text('  (locked)',
                        style: inter(fontSize: 12, color: C.muted)),
                  ]),
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
                            style: mono(fontSize: 13, color: C.txt)),
                      ],
                    ),
                  )),
                ]),
                const SizedBox(height: 12),
                if (canStep)
                  PrimaryBtn(label: 'Step', onPressed: _step),
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
                  label: _isLast ? 'Now find the sweet spot →' : 'Next experiment',
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
