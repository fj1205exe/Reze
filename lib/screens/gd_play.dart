import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

class _Task {
  final String title, instruction, insight;
  final double startTheta, lr;
  final int maxSteps;
  final bool userLr;
  const _Task({
    required this.title,
    required this.instruction,
    required this.insight,
    required this.startTheta,
    required this.lr,
    required this.maxSteps,
    this.userLr = false,
  });
}

const _tasks = [
  _Task(
    title: 'Step downhill',
    instruction: 'The ball is high on the curve.\nTap to step toward lower loss.',
    startTheta: 8.0,
    lr: 0.5,
    maxSteps: 4,
    insight: 'Each step moves toward lower loss. The direction is automatic — it always goes downhill.',
  ),
  _Task(
    title: 'From the other side',
    instruction: 'Now the ball starts on the left.\nDoes the same rule work?',
    startTheta: 2.0,
    lr: 0.5,
    maxSteps: 4,
    insight: 'Same rule, opposite direction. It always moves toward the minimum, regardless of starting position.',
  ),
  _Task(
    title: 'Bigger steps',
    instruction: 'What happens when the step size\nis much larger?',
    startTheta: 8.0,
    lr: 2.5,
    maxSteps: 3,
    insight: 'The step jumped PAST the minimum! This is called overshooting — the step size was too large.',
  ),
  _Task(
    title: 'Your turn',
    instruction: 'Reach the minimum in 6 steps.\nYou control the step size.',
    startTheta: 8.0,
    lr: 0.5,
    maxSteps: 6,
    userLr: true,
    insight: 'Not too big, not too small — you found the right balance. This tradeoff is the core of gradient descent.',
  ),
];

class GDPlayScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDPlayScreen({super.key, required this.onNext, required this.onBack});
  @override
  State<GDPlayScreen> createState() => _GDPlayScreenState();
}

class _GDPlayScreenState extends State<GDPlayScreen> {
  int _taskIdx = 0;
  double _theta = _tasks[0].startTheta;
  List<double> _history = [];
  int _steps = 0;
  double _userLr = 0.5;
  bool _showInsight = false;
  bool _failed = false;

  _Task get _task => _tasks[_taskIdx];
  double get _lr => _task.userLr ? _userLr : _task.lr;
  bool get _isLast => _taskIdx == _tasks.length - 1;

  void _step() {
    if (_showInsight || _failed) return;
    if (_steps >= _task.maxSteps) return;

    setState(() {
      _history.add(_theta);
      _theta = gd.clamp(gd.gdStep(_theta, _lr), gd.tMin, gd.tMax);
      _steps++;
    });

    final done = _task.userLr
        ? gd.isConverged(_theta)
        : _steps >= _task.maxSteps;
    final outOfSteps = _steps >= _task.maxSteps;

    if (done) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showInsight = true);
      });
    } else if (_task.userLr && outOfSteps && !gd.isConverged(_theta)) {
      setState(() => _failed = true);
    }
  }

  void _retry() => setState(() {
    _theta = _task.startTheta;
    _history = [];
    _steps = 0;
    _failed = false;
  });

  void _next() {
    if (_isLast) {
      widget.onNext();
      return;
    }
    final nextTask = _tasks[_taskIdx + 1];
    setState(() {
      _taskIdx++;
      _theta = nextTask.startTheta;
      _history = [];
      _steps = 0;
      _showInsight = false;
      _failed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loss = gd.lossFunc(_theta);
    final canStep = !_showInsight && !_failed && _steps < _task.maxSteps;

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
                      decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GRADIENT DESCENT', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                      Text(_task.title, style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  )),
                  ProgressPill(current: _taskIdx + (_showInsight ? 1 : 0), total: _tasks.length),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_task.instruction, style: inter(fontSize: 15, color: const Color(0xFFD1D5DB))),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _showInsight ? C.green.withValues(alpha: 0.2) : C.border),
              ),
              child: Stack(
                children: [
                  Positioned(top: 12, left: 12, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('loss', style: inter(fontSize: 12, color: C.muted)),
                      Text(loss.toStringAsFixed(2), style: mono(fontSize: 17, color: C.accentLight)),
                    ],
                  )),
                  if (_steps > 0)
                    Positioned(top: 12, right: 12, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                      child: Text('step $_steps / ${_task.maxSteps}', style: mono(fontSize: 12, color: C.muted)),
                    )),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: LossCurveWidget(theta: _theta, history: _history, showMinMarker: true, height: 210),
                  ),
                ],
              ),
            ),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(children: [
              if (!_showInsight && !_failed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: S.borderMd,
                    border: Border.all(color: C.border),
                  ),
                  child: Row(children: [
                    Text('Step size: ', style: inter(fontSize: 13, color: C.muted)),
                    Text('η = ${_lr.toStringAsFixed(2)}', style: mono(fontSize: 14, color: C.accent)),
                    if (_task.lr > 2 && !_task.userLr)
                      Text('  (large!)', style: inter(fontSize: 12, color: C.yellow)),
                  ]),
                ),
                if (_task.userLr)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.border),
                    ),
                    child: LrSlider(value: _userLr, onChange: (v) => setState(() => _userLr = v)),
                  ),
                if (canStep)
                  PrimaryBtn(label: 'Step', onPressed: _step),
              ],

              if (_failed) ...[
                FadeSlideIn(
                  duration: const Duration(milliseconds: 400),
                  slideDistance: 14,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: C.pink.withValues(alpha: 0.08),
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.pink.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Didn't reach the minimum.", style: inter(fontSize: 14, color: C.pink)),
                        const SizedBox(height: 4),
                        Text('Try adjusting η — too small is slow, too large overshoots.',
                          style: inter(fontSize: 13, color: C.pink.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 350),
                  slideDistance: 10,
                  child: PrimaryBtn(label: 'Try again', onPressed: _retry),
                ),
              ],

              if (_showInsight) ...[
                FadeSlideIn(
                  duration: const Duration(milliseconds: 450),
                  slideDistance: 16,
                  child: Container(
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
                          Icon(Icons.lightbulb_outline, size: 16, color: C.green),
                          const SizedBox(width: 8),
                          Text('INSIGHT', style: spaceGrotesk(fontSize: 11, color: C.green, letterSpacing: 0.1)),
                        ]),
                        const SizedBox(height: 12),
                        Text(_task.insight, style: inter(fontSize: 14, color: C.txt, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 400),
                  slideDistance: 12,
                  child: PrimaryBtn(
                    label: _isLast ? 'Explore step size →' : 'Continue',
                    onPressed: _next,
                  ),
                ),
              ],
            ]),
          )),
        ],
      ),
    );
  }
}
