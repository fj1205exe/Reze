import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;

class GDIntroScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDIntroScreen({super.key, required this.onNext, required this.onBack});
  @override
  State<GDIntroScreen> createState() => _GDIntroScreenState();
}

class _GDIntroScreenState extends State<GDIntroScreen>
    with TickerProviderStateMixin {
  int _stage = 0;
  double _theta = gd.tMax + 1;
  List<double> _history = [];
  int _stepsTaken = 0;
  bool _textVisible = false;

  late final AnimationController _dropCtrl;
  late final Animation<double> _dropAnim;

  @override
  void initState() {
    super.initState();
    _dropCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dropAnim = Tween<double>(begin: gd.tMax + 1, end: 8.0).animate(
      CurvedAnimation(parent: _dropCtrl, curve: Curves.easeOut),
    );
    _dropCtrl.addListener(() {
      setState(() => _theta = _dropAnim.value);
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _textVisible = true);
    });
  }

  @override
  void dispose() {
    _dropCtrl.dispose();
    super.dispose();
  }

  void _dropBall() {
    _dropCtrl.forward().then((_) {
      if (mounted) {
        setState(() {
          _stage = 1;
          _textVisible = false;
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _textVisible = true);
        });
      }
    });
  }

  void _stepDownhill() {
    final prev = _theta;
    final next = gd.clamp(gd.gdStep(_theta, 0.6), gd.tMin, gd.tMax);
    setState(() {
      _history.add(prev);
      _theta = next;
      _stepsTaken++;
    });
    if (_stepsTaken >= 2) {
      setState(() {
        _textVisible = false;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _stage = 2;
            _textVisible = false;
          });
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _textVisible = true);
          });
        }
      });
    }
  }

  String get _stageTitle {
    switch (_stage) {
      case 0:
        return 'The landscape';
      case 1:
        return 'Feel the slope';
      case 2:
        return 'The goal';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBall = _stage >= 1 || _dropCtrl.isAnimating;
    final showMin = _stage == 2;
    final ballTheta = showBall ? _theta : gd.tMax + 1;

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
                        Text('GRADIENT DESCENT',
                            style: spaceGrotesk(
                                fontSize: 10,
                                color: C.muted,
                                letterSpacing: 0.12)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _stageTitle,
                            key: ValueKey(_stage),
                            style: spaceGrotesk(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProgressPill(current: _stage, total: 3),
                ],
              ),
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
                  color: showMin
                      ? C.green.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: LossCurveWidget(
                      theta: ballTheta,
                      history: _history,
                      showMinMarker: showMin,
                      height: 210,
                    ),
                  ),
                  if (_stage == 1 && _stepsTaken == 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: C.pink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: C.pink.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('slope → uphill ',
                                style: inter(fontSize: 11, color: C.pink)),
                            const Icon(Icons.north_east,
                                size: 12, color: C.pink),
                          ],
                        ),
                      ),
                    ),
                  if (_stage == 0)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Text('J(θ)',
                          style: inter(fontSize: 12, color: C.muted)),
                    ),
                  if (_stage >= 1)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('loss',
                              style: inter(fontSize: 12, color: C.muted)),
                          Text(gd.lossFunc(_theta).toStringAsFixed(2),
                              style: mono(fontSize: 16, color: C.accentLight)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Body content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStageContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case 0:
        return _stage0();
      case 1:
        return _stage1();
      case 2:
        return _stage2();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _stage0() {
    return Column(
      key: const ValueKey('stage-0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          opacity: _textVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Every ML model has a\nlandscape like this.',
                style: spaceGrotesk(
                    fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Peaks are bad — high loss means the model is wrong.\nValleys are good — low loss means the model fits.',
                style: inter(
                    fontSize: 15, color: const Color(0xFFD1D5DB)),
              ),
              const SizedBox(height: 8),
              Text(
                'But the model doesn\'t know where the valley is. It can only feel the slope under its feet.',
                style: inter(fontSize: 14, color: C.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryBtn(label: 'Drop the ball', onPressed: _dropBall),
      ],
    );
  }

  Widget _stage1() {
    return Column(
      key: const ValueKey('stage-1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          opacity: _textVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_stepsTaken == 0) ...[
                Text(
                  'The slope tells you which\nway is uphill.',
                  style: spaceGrotesk(
                      fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'You want to go the OTHER way — downhill, toward lower loss.',
                  style: inter(
                      fontSize: 15, color: const Color(0xFFD1D5DB)),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      Text('Gradient here: ',
                          style: inter(fontSize: 13, color: C.muted)),
                      Text(
                          gd.gradientOf(_theta).toStringAsFixed(2),
                          style: mono(fontSize: 14, color: C.pink)),
                      Text('  (positive → slope goes up)',
                          style:
                              inter(fontSize: 12, color: C.muted)),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'It moved!',
                  style: spaceGrotesk(
                      fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'The ball slid toward lower ground. One more step.',
                  style: inter(
                      fontSize: 15, color: const Color(0xFFD1D5DB)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryBtn(
          label: _stepsTaken == 0 ? 'Step downhill' : 'Step again',
          onPressed: _stepDownhill,
        ),
      ],
    );
  }

  Widget _stage2() {
    return Column(
      key: const ValueKey('stage-2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          opacity: _textVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'That green dot is\nthe minimum.',
                style: spaceGrotesk(
                    fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'The best your model can be. Your job: get there efficiently.',
                style: inter(
                    fontSize: 15, color: const Color(0xFFD1D5DB)),
              ),
              const SizedBox(height: 8),
              Text(
                'Too few steps and you won\'t reach it.\nToo many and you\'re wasting compute.\nToo big and you\'ll fly right past.',
                style: inter(fontSize: 14, color: C.muted),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: C.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: C.accent.withValues(alpha: 0.15)),
                ),
                child: Text(
                  'This tradeoff — step size, direction, and efficiency — is gradient descent.',
                  style: inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: C.accentLight),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryBtn(label: 'Begin →', onPressed: widget.onNext),
      ],
    );
  }
}
