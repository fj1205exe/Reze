import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/follow_up.dart';
import '../utils/classification.dart' as cl_utils;

const _stepLimit = 8;

class CLChallengeScreen extends StatefulWidget {
  final double angle;
  final double offset;
  final int steps;
  final void Function(double a, double o) onUpdate;
  final void Function(bool success, int steps, double accuracy) onComplete;
  final VoidCallback onBack;

  const CLChallengeScreen({
    super.key,
    required this.angle,
    required this.offset,
    required this.steps,
    required this.onUpdate,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<CLChallengeScreen> createState() => _CLChallengeScreenState();
}

class _CLChallengeScreenState extends State<CLChallengeScreen> {
  bool _hasSucceeded = false;
  bool _hasMoved = false;
  bool _followUpDone = false;
  int _lockIns = 0;
  late double _angle;
  late double _offset;

  @override
  void initState() {
    super.initState();
    _angle = -20;
    _offset = 0.1;
  }

  double get _accuracy => cl_utils.calcAccuracyForDataset(
    _angle, _offset, cl_utils.challengeClassA, cl_utils.challengeClassB,
  );

  bool get _exhausted => _lockIns >= _stepLimit && !_hasSucceeded;
  bool get _done => _hasSucceeded || _exhausted;

  void _lockIn() {
    if (_done || !_hasMoved) return;
    setState(() {
      _lockIns++;
      _hasMoved = false;
      if (_accuracy >= 90.0) _hasSucceeded = true;
    });
    widget.onUpdate(_angle, _offset);
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = _accuracy;
    final isGood = accuracy >= 90.0;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: S.headerPad,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.yellow.withValues(alpha: 0.25)),
                          ),
                          child: Text('CHALLENGE', style: spaceGrotesk(fontSize: 12, color: C.yellow)),
                        ),
                        const SizedBox(height: 4),
                        Text('Achieve 90% accuracy.',
                          style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  StepCounter(steps: _lockIns, max: _stepLimit),
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
                  color: _done && _hasSucceeded
                      ? C.green.withValues(alpha: 0.3)
                      : _done && !_hasSucceeded
                          ? C.pink.withValues(alpha: 0.2)
                          : C.border,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: 12, left: 12, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accuracy', style: inter(fontSize: 12, color: C.muted)),
                      Text(
                        '${accuracy.round()}%',
                        style: mono(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isGood ? C.green : (accuracy >= 70 ? C.yellow : C.pink),
                        ),
                      ),
                    ],
                  )),
                  if (!_done)
                    Positioned(top: 12, right: 12, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14171C).withValues(alpha: 0.9),
                        borderRadius: S.borderSm,
                        border: Border.all(color: C.yellow.withValues(alpha: 0.25)),
                      ),
                      child: Text('${max(0, _stepLimit - _lockIns)} left', style: mono(fontSize: 12, color: C.yellow)),
                    )),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _ChallengePlotPainter(angle: _angle, offset: _offset),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  if (_done && _hasSucceeded)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: C.green.withValues(alpha: 0.1),
                          borderRadius: S.borderMd,
                          border: Border.all(color: C.green.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${accuracy.round()}% accuracy in $_lockIns lock-in${_lockIns == 1 ? '' : 's'}.',
                              style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, color: C.green)),
                            const SizedBox(height: 4),
                            Text('You found the right boundary.', style: inter(fontSize: 12, color: C.greenLight)),
                          ],
                        ),
                      ),
                    ),
                  if (_done && !_hasSucceeded)
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
                        child: Text(
                          'Ran out of adjustments — ${accuracy.round()}% accuracy. 90% needed. Try adjusting angle close to -45° with a small offset.',
                          style: inter(fontSize: 14, color: C.pink),
                        ),
                      ),
                    ),
                  if (!_done)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: S.borderMd,
                        border: Border.all(color: C.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Angle', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                              Text('${_angle.round()}', style: mono(fontSize: 13, color: C.accentLight)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: C.accent,
                              inactiveTrackColor: C.surface3,
                              thumbColor: C.accent,
                              overlayColor: C.accent.withValues(alpha: 0.15),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _angle,
                              min: -90,
                              max: 90,
                              onChanged: (v) => setState(() { _angle = v; _hasMoved = true; }),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Offset', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(_offset.toStringAsFixed(2), style: mono(fontSize: 13, color: C.yellow)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: C.yellow,
                              inactiveTrackColor: C.surface3,
                              thumbColor: C.yellow,
                              overlayColor: C.yellow.withValues(alpha: 0.15),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _offset,
                              min: -0.5,
                              max: 0.5,
                              onChanged: (v) => setState(() { _offset = v; _hasMoved = true; }),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _hasMoved ? _lockIn : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: C.yellow,
                                disabledBackgroundColor: C.surface3,
                                foregroundColor: C.bg,
                                shape: RoundedRectangleBorder(borderRadius: S.borderSm),
                                elevation: 0,
                              ),
                              child: Text(
                                'LOCK IN  (${_stepLimit - _lockIns} left)',
                                style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600,
                                    color: _hasMoved ? C.bg : C.muted),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!_done)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FeedbackBar(
                        type: accuracy >= 80 ? 'ok' : 'info',
                        message: '${accuracy.round()}% accuracy — ${max(0, _stepLimit - _lockIns)} lock-ins remaining.',
                      ),
                    ),
                  if (_hasSucceeded && !_followUpDone)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: FollowUpCard(
                        data: const FollowUpData(
                          question: 'Why is the angle of the boundary more important than the offset?',
                          options: [
                            'Offset is actually more important',
                            'Angle determines which side each class falls on; offset only shifts the line',
                            'Both contribute equally',
                          ],
                          correctIndex: 1,
                          explanation: 'The angle defines the orientation of the decision boundary — it determines the classification rule. Offset just translates the line without changing which regions map to which class.',
                        ),
                        onDismiss: () => setState(() => _followUpDone = true),
                      ),
                    ),
                  if (_done && (_followUpDone || !_hasSucceeded))
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => widget.onComplete(_hasSucceeded, _lockIns, _accuracy),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasSucceeded ? C.green : C.accent,
                            foregroundColor: _hasSucceeded ? C.bg : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: S.borderMd),
                            elevation: 0,
                          ),
                          child: Text('See results', style: spaceGrotesk(
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: _hasSucceeded ? C.bg : Colors.white, letterSpacing: 0.05,
                          )),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengePlotPainter extends CustomPainter {
  final double angle;
  final double offset;

  _ChallengePlotPainter({required this.angle, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const pad = 20.0;
    final iw = w - 2 * pad;
    final ih = h - 2 * pad;

    double toX(double xNorm) => pad + xNorm * iw;
    double toY(double yNorm) => h - pad - yNorm * ih;

    final gridPaint = Paint()..color = C.dim..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final f = i / 4;
      canvas.drawLine(Offset(toX(f), pad), Offset(toX(f), h - pad), gridPaint);
      canvas.drawLine(Offset(pad, toY(f)), Offset(w - pad, toY(f)), gridPaint);
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(pad, pad, iw, ih));

    final theta = angle * pi / 180;
    final cosT = cos(theta);
    final sinT = sin(theta);
    double cxN, cyN;
    if (cosT.abs() > 1e-4) {
      cxN = 0.5;
      cyN = 0.5 + offset / cosT;
    } else {
      cxN = 0.5 + offset / sinT;
      cyN = 0.5;
    }
    final cxS = toX(cxN);
    final cyS = toY(cyN);
    const l = 500.0;

    canvas.drawLine(
      Offset(cxS - l * cosT, cyS + l * sinT),
      Offset(cxS + l * cosT, cyS - l * sinT),
      Paint()..color = Colors.white..strokeWidth = 2,
    );

    canvas.restore();

    // Challenge dataset Class A (Purple)
    for (final p in cl_utils.challengeClassA) {
      final isCorrect = cl_utils.classify(p.x, p.y, angle, offset) == 1;
      canvas.drawCircle(
        Offset(toX(p.x), toY(p.y)),
        5,
        Paint()..color = isCorrect ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6).withValues(alpha: 0.35),
      );
      if (!isCorrect) {
        canvas.drawCircle(Offset(toX(p.x), toY(p.y)), 6.5,
          Paint()..color = C.pink..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }

    // Challenge dataset Class B (Blue)
    for (final p in cl_utils.challengeClassB) {
      final isCorrect = cl_utils.classify(p.x, p.y, angle, offset) == -1;
      canvas.drawCircle(
        Offset(toX(p.x), toY(p.y)),
        5,
        Paint()..color = isCorrect ? const Color(0xFF38BDF8) : const Color(0xFF38BDF8).withValues(alpha: 0.35),
      );
      if (!isCorrect) {
        canvas.drawCircle(Offset(toX(p.x), toY(p.y)), 6.5,
          Paint()..color = C.pink..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }
  }

  @override
  bool shouldRepaint(_ChallengePlotPainter old) => angle != old.angle || offset != old.offset;
}
