import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

class _Task {
  final String title, instruction, insight;
  final double startTheta, lr;
  final int maxSteps;
  const _Task({
    required this.title,
    required this.instruction,
    required this.insight,
    required this.startTheta,
    required this.lr,
    required this.maxSteps,
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
];

class GDGuidedScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDGuidedScreen({super.key, required this.onNext, required this.onBack});
  @override
  State<GDGuidedScreen> createState() => _GDGuidedScreenState();
}

class _GDGuidedScreenState extends State<GDGuidedScreen>
    with SingleTickerProviderStateMixin {
  int _taskIdx = 0;
  double _theta = _tasks[0].startTheta;
  double _displayTheta = _tasks[0].startTheta;
  List<double> _history = [];
  int _steps = 0;
  bool _showInsight = false;
  late AnimationController _ballAnim;
  Animation<double>? _ballTween;

  _Task get _task => _tasks[_taskIdx];
  bool get _isLast => _taskIdx == _tasks.length - 1;

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
    if (_steps >= _task.maxSteps) return;

    final oldTheta = _theta;
    final newTheta = gd.clamp(gd.gdStep(_theta, _task.lr), gd.tMin, gd.tMax);

    setState(() {
      _history.add(_theta);
      _theta = newTheta;
      _steps++;
    });

    _ballTween = Tween(begin: oldTheta, end: newTheta).animate(
      CurvedAnimation(parent: _ballAnim, curve: Curves.easeOutCubic),
    );
    _ballAnim.forward(from: 0);

    if (_steps >= _task.maxSteps) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showInsight = true);
      });
    }
  }

  void _next() {
    if (_isLast) {
      widget.onNext();
      return;
    }
    final nextTask = _tasks[_taskIdx + 1];
    setState(() {
      _taskIdx++;
      _theta = nextTask.startTheta;
      _displayTheta = nextTask.startTheta;
      _history = [];
      _steps = 0;
      _showInsight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loss = gd.lossFunc(_displayTheta);
    final canStep = !_showInsight && _steps < _task.maxSteps;

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
                      decoration: BoxDecoration(
                        color: C.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GUIDED', style: spaceGrotesk(
                        fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                      Text(_task.title, style: spaceGrotesk(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  )),
                  ProgressPill(
                    current: _taskIdx + (_showInsight ? 1 : 0),
                    total: _tasks.length,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_task.instruction,
                style: inter(fontSize: 15, color: const Color(0xFFD1D5DB))),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 220,
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
                  Positioned(top: 12, left: 12, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('loss', style: inter(fontSize: 12, color: C.muted)),
                      Text(loss.toStringAsFixed(2),
                        style: mono(fontSize: 17, color: C.accentLight)),
                    ],
                  )),
                  if (_steps > 0)
                    Positioned(top: 12, right: 12, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: C.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('step $_steps / ${_task.maxSteps}',
                        style: mono(fontSize: 12, color: C.muted)),
                    )),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: LossCurveWidget(
                      theta: _displayTheta,
                      history: _history,
                      showMinMarker: true,
                      height: 210,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(children: [
              if (!_showInsight) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(children: [
                    Text('Step size: ', style: inter(fontSize: 13, color: C.muted)),
                    Text('η = ${_task.lr.toStringAsFixed(2)}',
                      style: mono(fontSize: 14, color: C.accent)),
                  ]),
                ),
                if (canStep)
                  PrimaryBtn(label: _steps == 0 ? 'Step' : 'Step again', onPressed: _step),
              ],

              if (_showInsight) ...[
                AnimatedOpacity(
                  opacity: _showInsight ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
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
                          const Icon(Icons.lightbulb_outline, size: 16, color: C.green),
                          const SizedBox(width: 8),
                          Text('INSIGHT', style: spaceGrotesk(
                            fontSize: 11, color: C.green, letterSpacing: 0.1)),
                        ]),
                        const SizedBox(height: 12),
                        Text(_task.insight,
                          style: inter(fontSize: 14, color: C.txt, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryBtn(
                  label: _isLast ? 'Try bigger steps →' : 'Continue',
                  onPressed: _next,
                ),
              ],
            ]),
          )),
        ],
      ),
    );
  }
}
