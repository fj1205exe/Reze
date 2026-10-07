import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/loss_fns.dart' as lf;

const _outlierY = 0.95;

class LFDiscoverScreen extends StatefulWidget {
  final String selectedLoss;
  final double prediction;
  final void Function(double pred, String loss) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LFDiscoverScreen({
    super.key,
    required this.selectedLoss,
    required this.prediction,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LFDiscoverScreen> createState() => _LFDiscoverScreenState();
}

class _LFDiscoverScreenState extends State<LFDiscoverScreen> {
  bool _outlierOn = false;
  bool _triedNearOutlier = false;
  bool _triedFarFromOutlier = false;
  bool _toggledOutlier = false;

  double _lossFor(String type, double pred) {
    final targets = _outlierOn ? [lf.truth, _outlierY] : [lf.truth];
    double total = 0;
    for (final t in targets) {
      if (type == 'mse') {
        total += lf.mseLoss(pred, t);
      } else if (type == 'mae') {
        total += lf.maeLoss(pred, t);
      } else {
        total += lf.huberLoss(pred, t);
      }
    }
    return total / targets.length;
  }

  String get _feedback {
    final pred = widget.prediction;
    final mseLoss = _lossFor('mse', pred);
    final maeLoss = _lossFor('mae', pred);
    if (!_outlierOn) {
      if ((pred - lf.truth).abs() < 0.08) return 'All three losses agree near the truth.';
      return 'Move the prediction — watch how each loss reacts differently to distance.';
    }
    if (mseLoss > maeLoss * 2.5) return 'MSE explodes near outliers — it squares the error.';
    if ((pred - _outlierY).abs() < 0.15) return 'Prediction near the outlier: MSE is dragged up hard.';
    return 'With outliers, robust losses (MAE, Huber) stay calm while MSE panics.';
  }

  String get _feedbackType {
    if (!_outlierOn) return 'info';
    final mseLoss = _lossFor('mse', widget.prediction);
    final maeLoss = _lossFor('mae', widget.prediction);
    if (mseLoss > maeLoss * 2.5) return 'warn';
    return 'info';
  }

  void _handleSlider(double v) {
    widget.onUpdate(v, widget.selectedLoss);
    setState(() {
      if (_outlierOn) {
        if ((v - _outlierY).abs() < 0.15) _triedNearOutlier = true;
        if ((v - _outlierY).abs() > 0.4) _triedFarFromOutlier = true;
      }
    });
  }

  bool get _unlocked => _toggledOutlier && _triedNearOutlier && _triedFarFromOutlier;

  @override
  Widget build(BuildContext context) {
    final pred = widget.prediction;
    final mseLoss = _lossFor('mse', pred);
    final maeLoss = _lossFor('mae', pred);
    final huberLoss = _lossFor('huber', pred);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Loss Functions — Discover', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why do different losses exist?',
                      style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Toggle the outlier and drag the prediction.',
                      style: inter(fontSize: 14)),
                  const SizedBox(height: 16),

                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: CustomPaint(
                      painter: _DiscoverPlotPainter(
                        prediction: pred,
                        outlierOn: _outlierOn,
                        mseLoss: mseLoss,
                        maeLoss: maeLoss,
                        huberLoss: huberLoss,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Outlier toggle
                  GestureDetector(
                    onTap: () => setState(() {
                      _outlierOn = !_outlierOn;
                      _toggledOutlier = true;
                    }),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _outlierOn
                            ? C.pink.withValues(alpha: 0.12)
                            : C.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _outlierOn
                              ? C.pink.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _outlierOn ? Icons.warning_amber : Icons.add_circle_outline,
                            size: 18,
                            color: _outlierOn ? C.pink : C.muted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _outlierOn ? 'Outlier ON at y = $_outlierY' : 'Tap to add an outlier',
                              style: spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _outlierOn ? C.pink : C.muted,
                              ),
                            ),
                          ),
                          Container(
                            width: 40, height: 22,
                            decoration: BoxDecoration(
                              color: _outlierOn ? C.pink : C.surface3,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: _outlierOn ? Alignment.centerRight : Alignment.centerLeft,
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: 18, height: 18,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                            Text('prediction', style: inter(fontSize: 12, color: C.muted)),
                            Text('ŷ = ${pred.toStringAsFixed(2)}', style: mono(fontSize: 13, color: C.txt)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.accent,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.accent,
                            overlayColor: C.accent.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: pred.clamp(0.0, 1.0),
                            min: 0, max: 1,
                            onChanged: _handleSlider,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Loss comparison cards
                  Row(
                    children: [
                      _lossCard('MSE', mseLoss, const Color(0xFF8B5CF6)),
                      const SizedBox(width: 6),
                      _lossCard('MAE', maeLoss, const Color(0xFF38BDF8)),
                      const SizedBox(width: 6),
                      _lossCard('Huber', huberLoss, const Color(0xFFFBBF24)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  FeedbackBar(type: _feedbackType, message: _feedback),
                  const SizedBox(height: 20),

                  if (!_toggledOutlier)
                    PrimaryBtn(label: 'Toggle the outlier first', disabled: true, onPressed: null)
                  else if (!_unlocked)
                    PrimaryBtn(
                      label: 'Move prediction near & far from outlier',
                      disabled: true,
                      onPressed: null,
                    )
                  else
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: PrimaryBtn(label: 'Now I see why — continue', onPressed: widget.onNext),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lossCard(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 4),
            Text(value.toStringAsFixed(4), style: mono(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _DiscoverPlotPainter extends CustomPainter {
  final double prediction;
  final bool outlierOn;
  final double mseLoss, maeLoss, huberLoss;

  _DiscoverPlotPainter({
    required this.prediction,
    required this.outlierOn,
    required this.mseLoss,
    required this.maeLoss,
    required this.huberLoss,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const padL = 32.0, padR = 16.0, padT = 16.0, padB = 24.0;
    final iw = w - padL - padR;
    final ih = h - padT - padB;
    const yMax = 0.5;

    double toX(double v) => padL + v * iw;
    double toY(double loss) => padT + ih - (loss.clamp(0, yMax) / yMax) * ih;

    // Grid
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(padL, padT + ih * f), Offset(padL + iw, padT + ih * f), gridPaint);
    }

    // Truth marker
    final truthX = toX(lf.truth);
    canvas.drawLine(
      Offset(truthX, padT), Offset(truthX, padT + ih),
      Paint()..color = C.green.withValues(alpha: 0.5)..strokeWidth = 1,
    );
    canvas.drawCircle(Offset(truthX, toY(0)), 5, Paint()..color = C.green);
    _text(canvas, 'y=${lf.truth}', Offset(truthX + 4, padT + ih + 4), 8, C.green);

    // Outlier marker
    if (outlierOn) {
      final ox = toX(_outlierY);
      canvas.drawLine(
        Offset(ox, padT), Offset(ox, padT + ih),
        Paint()..color = C.pink.withValues(alpha: 0.4)..strokeWidth = 1,
      );
      canvas.drawCircle(Offset(ox, toY(0)), 5, Paint()..color = C.pink);
      _text(canvas, 'outlier', Offset(ox - 16, padT + ih + 4), 8, C.pink);
    }

    // Draw all 3 loss curves
    final targets = outlierOn ? [lf.truth, _outlierY] : [lf.truth];
    final types = ['mse', 'mae', 'huber'];
    final colors = [const Color(0xFF8B5CF6), const Color(0xFF38BDF8), const Color(0xFFFBBF24)];

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(padL, padT - 2, iw, ih + 4));

    for (int t = 0; t < 3; t++) {
      final path = Path();
      for (int i = 0; i <= 80; i++) {
        final x = i / 80.0;
        double loss = 0;
        for (final target in targets) {
          if (types[t] == 'mse') {
            loss += lf.mseLoss(x, target);
          } else if (types[t] == 'mae') {
            loss += lf.maeLoss(x, target);
          } else {
            loss += lf.huberLoss(x, target);
          }
        }
        loss /= targets.length;
        final px = toX(x), py = toY(loss);
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(path, Paint()
        ..color = colors[t]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2);
    }
    canvas.restore();

    // Prediction line + dots
    final predX = toX(prediction);
    canvas.drawLine(
      Offset(predX, padT), Offset(predX, padT + ih),
      Paint()..color = Colors.white.withValues(alpha: 0.25)..strokeWidth = 1,
    );
    final losses = [mseLoss, maeLoss, huberLoss];
    for (int i = 0; i < 3; i++) {
      final py = toY(losses[i]);
      canvas.drawCircle(Offset(predX, py), 5, Paint()..color = colors[i]);
      canvas.drawCircle(Offset(predX, py), 2, Paint()..color = Colors.white);
    }

    // Legend
    final labels = ['MSE', 'MAE', 'Huber'];
    for (int i = 0; i < 3; i++) {
      final lx = padL + iw - 58.0;
      final ly = padT + 6.0 + i * 14;
      canvas.drawLine(Offset(lx, ly), Offset(lx + 12, ly), Paint()..color = colors[i]..strokeWidth = 2);
      _text(canvas, labels[i], Offset(lx + 16, ly - 4), 8, colors[i]);
    }
  }

  void _text(Canvas c, String t, Offset o, double s, Color col) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: col, fontSize: s, fontFamily: 'JetBrains Mono')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, o);
  }

  @override
  bool shouldRepaint(_DiscoverPlotPainter old) =>
      prediction != old.prediction || outlierOn != old.outlierOn;
}
