import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/loss_fns.dart' as lf_utils;

const _lossTypes = ['mse', 'mae', 'huber'];
const _moveNeeded = 6;

class LFPlayScreen extends StatefulWidget {
  final String selectedLoss;
  final double prediction;
  final void Function(double pred, String loss) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LFPlayScreen({
    super.key,
    required this.selectedLoss,
    required this.prediction,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LFPlayScreen> createState() => _LFPlayScreenState();
}

class _LFPlayScreenState extends State<LFPlayScreen> {
  int _sliderMoves = 0;
  late Set<String> _lossesVisited;

  @override
  void initState() {
    super.initState();
    _lossesVisited = {widget.selectedLoss};
  }

  double _computeLoss(String type, double pred) {
    if (type == 'mse') return lf_utils.mseLoss(pred, lf_utils.truth);
    if (type == 'mae') return lf_utils.maeLoss(pred, lf_utils.truth);
    return lf_utils.huberLoss(pred, lf_utils.truth);
  }

  String? _getHint(String type, double pred) {
    final err = (pred - lf_utils.truth).abs();
    if (type == 'mse' && err > 0.3) {
      return 'MSE punishes large errors with a big penalty — the cost grows quadratically.';
    }
    if (type == 'mae' && err > 0.3) {
      return 'MAE grows linearly — large errors cost the same per unit as small ones.';
    }
    if (type == 'huber' && err > 0.3) {
      return 'Huber switches from quadratic to linear past the delta threshold — bounded sensitivity.';
    }
    if (err < 0.05) {
      return 'Near the truth — all three losses approach zero. The model is well-calibrated here.';
    }
    return null;
  }

  void _handleLossChange(String type) {
    widget.onUpdate(widget.prediction, type);
    setState(() {
      _lossesVisited.add(type);
    });
  }

  void _handleSlider(double pred) {
    widget.onUpdate(pred, widget.selectedLoss);
    setState(() {
      _sliderMoves++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedLoss = widget.selectedLoss;
    final prediction = widget.prediction;
    final currentLoss = _computeLoss(selectedLoss, prediction);
    final gradient = lf_utils.lossGradient(selectedLoss, prediction, lf_utils.truth);
    final hint = _getHint(selectedLoss, prediction);

    final allExplored = _lossTypes.every((t) => _lossesVisited.contains(t));
    final enoughMoves = _sliderMoves >= _moveNeeded;
    final unlocked = allExplored && enoughMoves;

    final lossColor = Color(lf_utils.lossColors[selectedLoss] ?? 0xFF8B5CF6);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Loss Functions', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Which loss hurts more?',
                      style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Try all three functions and move the slider to unlock.',
                      style: inter(fontSize: 14)),
                  const SizedBox(height: 16),

                  // Plot
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: CustomPaint(
                      painter: _LFPlotPainter(
                        selectedLoss: selectedLoss,
                        prediction: prediction,
                        currentLoss: currentLoss,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Loss type switcher tabs
                  Row(
                    children: _lossTypes.map((type) {
                      final active = selectedLoss == type;
                      final seen = _lossesVisited.contains(type);
                      final col = Color(lf_utils.lossColors[type] ?? 0xFF8B5CF6);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => _handleLossChange(type),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: active
                                    ? col.withValues(alpha: 0.18)
                                    : (seen ? col.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.03)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? col.withValues(alpha: 0.5)
                                      : (seen ? col.withValues(alpha: 0.2) : Colors.transparent),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    lf_utils.lossNames[type] ?? type.toUpperCase(),
                                    style: spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: active ? col : (seen ? col.withValues(alpha: 0.8) : const Color(0xFF6B7280)),
                                    ),
                                  ),
                                  if (seen && !active) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.check, size: 12, color: col.withValues(alpha: 0.8)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    lf_utils.lossDescriptions[selectedLoss] ?? '',
                    style: inter(fontSize: 12, color: C.muted),
                  ),
                  const SizedBox(height: 14),

                  // Prediction slider
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('prediction ŷ', style: inter(fontSize: 12, color: C.muted)),
                            Text('ŷ = ${prediction.toStringAsFixed(2)}',
                                style: mono(fontSize: 13, color: lossColor)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: lossColor,
                            inactiveTrackColor: C.surface3,
                            thumbColor: lossColor,
                            overlayColor: lossColor.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: prediction.clamp(0.0, 1.0),
                            min: 0,
                            max: 1,
                            onChanged: _handleSlider,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0', style: mono(fontSize: 11, color: C.muted)),
                            Text('truth = ${lf_utils.truth}', style: mono(fontSize: 11, color: C.green)),
                            Text('1', style: mono(fontSize: 11, color: C.muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Live stats
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Loss L(ŷ)', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(currentLoss.toStringAsFixed(4), style: mono(fontSize: 16, color: lossColor)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: C.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('slope ∂L/∂ŷ', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(
                                '${gradient >= 0 ? '+' : ''}${gradient.toStringAsFixed(3)}',
                                style: mono(
                                  fontSize: 16,
                                  color: gradient > 0 ? C.pink : (gradient < 0 ? C.green : const Color(0xFF6B7280)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (hint != null)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: lossColor, width: 2)),
                        ),
                        child: Text(hint, style: inter(fontSize: 13, color: lossColor)),
                      ),
                    ),
                  const SizedBox(height: 20),

                  PrimaryBtn(
                    label: unlocked
                        ? 'See the math'
                        : (!allExplored
                            ? 'Try all 3 loss types'
                            : 'Move slider ${_moveNeeded - _sliderMoves} more time${_moveNeeded - _sliderMoves > 1 ? 's' : ''}'),
                    disabled: !unlocked,
                    onPressed: unlocked ? widget.onNext : null,
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

class _LFPlotPainter extends CustomPainter {
  final String selectedLoss;
  final double prediction;
  final double currentLoss;

  _LFPlotPainter({
    required this.selectedLoss,
    required this.prediction,
    required this.currentLoss,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final padL = 32.0;
    final padR = 16.0;
    final padT = 16.0;
    final padB = 24.0;
    final iw = w - padL - padR;
    final ih = h - padT - padB;
    const yMax = 0.68;

    double toX(double pred) => padL + pred * iw;
    double toY(double loss) {
      final clamped = loss.clamp(0.0, yMax);
      return padT + ih - (clamped / yMax) * ih;
    }

    // Grid lines
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(padL, padT + ih * f), Offset(padL + iw, padT + ih * f), gridPaint);
    }

    // Y axis labels
    for (final v in [0.0, 0.2, 0.4, 0.6]) {
      _drawText(canvas, v.toStringAsFixed(1), Offset(padL - 26, toY(v) - 5), 8, Colors.grey.withValues(alpha: 0.6));
    }

    // Truth vertical dashed line
    final truthX = toX(lf_utils.truth);
    _drawDashedLine(
      canvas,
      Offset(truthX, padT),
      Offset(truthX, padT + ih),
      Paint()..color = C.green.withValues(alpha: 0.5)..strokeWidth = 1,
      3, 4,
    );
    _drawText(canvas, 'y', Offset(truthX + 3, padT + 2), 8, C.green.withValues(alpha: 0.8));

    // Prediction vertical line
    final predX = toX(prediction);
    _drawDashedLine(
      canvas,
      Offset(predX, padT),
      Offset(predX, padT + ih),
      Paint()..color = Colors.white.withValues(alpha: 0.25)..strokeWidth = 1,
      2, 3,
    );

    // Draw curves
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(padL, padT - 2, iw, ih + 4));

    for (final type in _lossTypes) {
      if (type == selectedLoss) continue;
      final curve = lf_utils.sampleLossCurve(type, 80);
      final col = Color(lf_utils.lossColors[type] ?? 0xFF8B5CF6);
      final p = Path();
      for (int i = 0; i < curve.length; i++) {
        final cx = toX(curve[i]['x']!);
        final cy = toY(curve[i]['loss']!);
        if (i == 0) {
          p.moveTo(cx, cy);
        } else {
          p.lineTo(cx, cy);
        }
      }
      canvas.drawPath(p, Paint()..color = col.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }

    // Active curve
    final activeCurve = lf_utils.sampleLossCurve(selectedLoss, 80);
    final activeColor = Color(lf_utils.lossColors[selectedLoss] ?? 0xFF8B5CF6);
    final activePath = Path();
    for (int i = 0; i < activeCurve.length; i++) {
      final cx = toX(activeCurve[i]['x']!);
      final cy = toY(activeCurve[i]['loss']!);
      if (i == 0) {
        activePath.moveTo(cx, cy);
      } else {
        activePath.lineTo(cx, cy);
      }
    }
    canvas.drawPath(
      activePath,
      Paint()
        ..color = activeColor.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    canvas.restore();

    // Ball at current prediction
    final ballY = toY(currentLoss);
    canvas.drawCircle(Offset(predX, ballY), 6, Paint()..color = activeColor);
    canvas.drawCircle(Offset(predX, ballY), 2.5, Paint()..color = Colors.white);

    // Legend
    for (int i = 0; i < _lossTypes.length; i++) {
      final t = _lossTypes[i];
      final col = Color(lf_utils.lossColors[t] ?? 0xFF8B5CF6);
      final isSel = t == selectedLoss;
      final lx = padL + iw - 65;
      final ly = padT + 8 + i * 14;
      canvas.drawLine(
        Offset(lx, ly),
        Offset(lx + 12, ly),
        Paint()
          ..color = col
          ..strokeWidth = isSel ? 2 : 1
          ..color = isSel ? col : col.withValues(alpha: 0.35),
      );
      _drawText(
        canvas,
        lf_utils.lossNames[t] ?? '',
        Offset(lx + 16, ly - 4),
        8,
        isSel ? col : Colors.grey.withValues(alpha: 0.6),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dash, double gap) {
    final dy = end.dy - start.dy;
    final dist = dy.abs();
    if (dist < 1) return;
    double d = 0;
    while (d < dist) {
      final y1 = start.dy + d;
      final y2 = start.dy + min(d + dash, dist);
      canvas.drawLine(Offset(start.dx, y1), Offset(start.dx, y2), paint);
      d += dash + gap;
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'JetBrains Mono'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LFPlotPainter old) =>
      selectedLoss != old.selectedLoss || prediction != old.prediction || currentLoss != old.currentLoss;
}
