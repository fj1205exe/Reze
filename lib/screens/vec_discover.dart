import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/vectors.dart' as vec_utils;

class VECDiscoverScreen extends StatefulWidget {
  final double ax, ay, bx, by;
  final bool showSum, showDiff;
  final void Function(double x, double y) onUpdateA;
  final void Function(double x, double y) onUpdateB;
  final VoidCallback onToggleSum;
  final VoidCallback onToggleDiff;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const VECDiscoverScreen({
    super.key,
    required this.ax,
    required this.ay,
    required this.bx,
    required this.by,
    required this.showSum,
    required this.showDiff,
    required this.onUpdateA,
    required this.onUpdateB,
    required this.onToggleSum,
    required this.onToggleDiff,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<VECDiscoverScreen> createState() => _VECDiscoverScreenState();
}

class _VECDiscoverScreenState extends State<VECDiscoverScreen> {
  int _sliderMoves = 0;
  String? _feedbackType;
  String _feedbackMsg = '';
  double _scaleFactor = 1.0;
  bool _normalized = false;
  bool _sumToggled = false;
  bool _diffToggled = false;

  void _handleSliderA(double x, double y) {
    widget.onUpdateA(x, y);
    setState(() {
      _sliderMoves++;
      _feedbackType = 'info';
      _feedbackMsg = 'Adjust components to see how vectors change';
    });
  }

  void _handleSliderB(double x, double y) {
    widget.onUpdateB(x, y);
    setState(() {
      _sliderMoves++;
      _feedbackType = 'info';
      _feedbackMsg = 'Adjust components to see how vectors change';
    });
  }

  void _handleScale() {
    widget.onUpdateA(widget.ax * _scaleFactor, widget.ay * _scaleFactor);
    setState(() {
      _sliderMoves++;
      _feedbackType = 'info';
      _feedbackMsg = 'Scaling changes magnitude but not direction';
    });
  }

  void _handleNormalize() {
    setState(() {
      _normalized = !_normalized;
      _sliderMoves++;
      if (_normalized) {
        _feedbackType = 'info';
        _feedbackMsg = 'Normalized vectors always have |v| = 1';
      } else {
        _feedbackType = null;
      }
    });
  }

  void _handleToggleSum() {
    widget.onToggleSum();
    setState(() {
      _sumToggled = true;
      _sliderMoves++;
      _feedbackType = 'info';
      _feedbackMsg = 'Sum of two vectors follows the parallelogram rule';
    });
  }

  void _handleToggleDiff() {
    widget.onToggleDiff();
    setState(() {
      _diffToggled = true;
      _sliderMoves++;
      _feedbackType = 'info';
      _feedbackMsg = 'Difference gives the displacement from b to a';
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = vec_utils.Vec2(widget.ax, widget.ay);
    final b = vec_utils.Vec2(widget.bx, widget.by);
    final sumVec = vec_utils.vecAdd(a, b);
    final diffVec = vec_utils.vecSub(a, b);
    final magA = vec_utils.vecMagnitude(a);
    final magB = vec_utils.vecMagnitude(b);
    final magSum = vec_utils.vecMagnitude(sumVec);
    final magDiff = vec_utils.vecMagnitude(diffVec);
    final normA = vec_utils.vecNormalize(a);

    final unlocked = _sliderMoves >= 8 &&
        (_sumToggled || widget.showSum || _diffToggled || widget.showDiff);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VECTORS', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Explore vector operations.', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Canvas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: CustomPaint(
                painter: _DiscoverCanvasPainter(
                  a: a,
                  b: b,
                  sumVec: sumVec,
                  diffVec: diffVec,
                  showSum: widget.showSum,
                  showDiff: widget.showDiff,
                  showNormalized: _normalized,
                  normA: normA,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vector info cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: C.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: C.accent.withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vector a', style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: C.accentLight)),
                              const SizedBox(height: 2),
                              Text('(${a.x.toStringAsFixed(2)}, ${a.y.toStringAsFixed(2)})', style: mono(fontSize: 11, color: C.txt)),
                              Text('|a| = ${magA.toStringAsFixed(2)}', style: mono(fontSize: 10, color: C.muted)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: C.blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: C.blue.withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vector b', style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: C.blue)),
                              const SizedBox(height: 2),
                              Text('(${b.x.toStringAsFixed(2)}, ${b.y.toStringAsFixed(2)})', style: mono(fontSize: 11, color: C.txt)),
                              Text('|b| = ${magB.toStringAsFixed(2)}', style: mono(fontSize: 10, color: C.muted)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Sum/Diff toggles
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _handleToggleSum,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.showSum ? C.green.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widget.showSum ? C.green.withValues(alpha: 0.5) : Colors.transparent),
                            ),
                            child: Text(
                              '${widget.showSum ? "Hide" : "Show"} a + b (${magSum.toStringAsFixed(2)})',
                              style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: widget.showSum ? C.green : C.muted),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: _handleToggleDiff,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.showDiff ? C.pink.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widget.showDiff ? C.pink.withValues(alpha: 0.5) : Colors.transparent),
                            ),
                            child: Text(
                              '${widget.showDiff ? "Hide" : "Show"} a − b (${magDiff.toStringAsFixed(2)})',
                              style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: widget.showDiff ? C.pink : C.muted),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Vector A sliders
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vector a controls', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: C.accentLight)),
                        const SizedBox(height: 6),
                        _buildSlider('x', widget.ax, -1.2, 1.2, C.accentLight, (v) => _handleSliderA(v, widget.ay)),
                        _buildSlider('y', widget.ay, -1.2, 1.2, C.accentLight, (v) => _handleSliderA(widget.ax, v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Vector B sliders
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vector b controls', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: C.blue)),
                        const SizedBox(height: 6),
                        _buildSlider('x', widget.bx, -1.2, 1.2, C.blue, (v) => _handleSliderB(v, widget.by)),
                        _buildSlider('y', widget.by, -1.2, 1.2, C.blue, (v) => _handleSliderB(widget.bx, v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Scale & Normalize row
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transform', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: C.purple)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(width: 50, child: Text('Scale', style: inter(fontSize: 12, color: C.muted))),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: C.purple,
                                  inactiveTrackColor: C.surface3,
                                  thumbColor: C.purple,
                                  overlayColor: C.purple.withValues(alpha: 0.15),
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                ),
                                child: Slider(
                                  value: _scaleFactor.clamp(0.1, 3.0),
                                  min: 0.1,
                                  max: 3.0,
                                  onChanged: (v) => setState(() => _scaleFactor = v),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(_scaleFactor.toStringAsFixed(1), textAlign: TextAlign.right, style: mono(fontSize: 12, color: C.txt)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: _handleScale,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: C.purple.withValues(alpha: 0.15),
                                    foregroundColor: C.purple,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: Text('Scale a', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: C.purple)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: _handleNormalize,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _normalized ? C.green.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _normalized ? C.green.withValues(alpha: 0.5) : Colors.transparent),
                                  ),
                                  child: Text(
                                    _normalized ? 'Normalized ON' : 'Normalize a',
                                    style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: _normalized ? C.green : C.muted),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_feedbackType != null)
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: FeedbackBar(type: _feedbackType!, message: _feedbackMsg),
                      ),
                    ),

                  PrimaryBtn(
                    label: unlocked
                        ? 'Continue'
                        : _sliderMoves < 8
                            ? 'Explore more ($_sliderMoves/8 interactions)'
                            : 'Toggle sum or difference to unlock',
                    disabled: !unlocked,
                    onPressed: unlocked ? widget.onNext : null,
                  ),
                  if (unlocked) ...[
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: SecondaryBtn(
                        label: 'I understand — show me the math →',
                        onPressed: widget.onNext,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double val, double min, double max, Color color, ValueChanged<double> onChange) {
    return Row(
      children: [
        SizedBox(width: 14, child: Text(label, style: mono(fontSize: 12, color: C.muted))),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: C.surface3,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: val.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChange,
            ),
          ),
        ),
        SizedBox(width: 44, child: Text(val.toStringAsFixed(2), textAlign: TextAlign.right, style: mono(fontSize: 12, color: C.txt))),
      ],
    );
  }
}

class _DiscoverCanvasPainter extends CustomPainter {
  final vec_utils.Vec2 a, b, sumVec, diffVec, normA;
  final bool showSum, showDiff, showNormalized;

  _DiscoverCanvasPainter({
    required this.a,
    required this.b,
    required this.sumVec,
    required this.diffVec,
    required this.showSum,
    required this.showDiff,
    required this.showNormalized,
    required this.normA,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ox = size.width / 2;
    final oy = size.height / 2;
    final scale = min(size.width, size.height) * 0.35;

    Offset toScreen(vec_utils.Vec2 v) => Offset(ox + v.x * scale, oy - v.y * scale);
    final origin = Offset(ox, oy);

    // Axes
    final axisPaint = Paint()..color = Colors.white.withValues(alpha: 0.1)..strokeWidth = 1;
    canvas.drawLine(Offset(0, oy), Offset(size.width, oy), axisPaint);
    canvas.drawLine(Offset(ox, 0), Offset(ox, size.height), axisPaint);

    // Grid circles
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(origin, scale * 0.5, circlePaint);
    canvas.drawCircle(origin, scale * 1.0, circlePaint);

    // Sum
    if (showSum) {
      _drawArrow(canvas, origin, toScreen(sumVec), C.green);
      _drawText(canvas, 'a+b', toScreen(sumVec) + const Offset(4, 4), C.green);
    }

    // Diff
    if (showDiff) {
      _drawArrow(canvas, origin, toScreen(diffVec), C.pink);
      _drawText(canvas, 'a−b', toScreen(diffVec) + const Offset(4, 4), C.pink);
    }

    // Normalized A (dashed)
    if (showNormalized) {
      _drawDashedArrow(canvas, origin, toScreen(normA), C.green);
      _drawText(canvas, 'â', toScreen(normA) + const Offset(4, -8), C.green);
    }

    // Vector B
    _drawArrow(canvas, origin, toScreen(b), C.blue);
    _drawText(canvas, 'b', toScreen(b) + const Offset(4, -8), C.blue);

    // Vector A
    _drawArrow(canvas, origin, toScreen(a), C.accentLight);
    _drawText(canvas, 'a', toScreen(a) + const Offset(4, -8), C.accentLight);

    // Origin dot
    canvas.drawCircle(origin, 3, Paint()..color = Colors.white.withValues(alpha: 0.5));
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    canvas.drawLine(from, to, Paint()..color = color..strokeWidth = 2);

    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final angle = atan2(dy, dx);
    const arrowLen = 9.0;
    const arrowAngle = pi / 6;

    final p1 = Offset(to.dx - arrowLen * cos(angle - arrowAngle), to.dy - arrowLen * sin(angle - arrowAngle));
    final p2 = Offset(to.dx - arrowLen * cos(angle + arrowAngle), to.dy - arrowLen * sin(angle + arrowAngle));

    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  void _drawDashedArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = sqrt(dx * dx + dy * dy);
    const dashLen = 6.0;
    const gapLen = 4.0;
    var drawn = 0.0;
    while (drawn < dist) {
      final startFrac = drawn / dist;
      final endFrac = min((drawn + dashLen) / dist, 1.0);
      canvas.drawLine(
        Offset(from.dx + dx * startFrac, from.dy + dy * startFrac),
        Offset(from.dx + dx * endFrac, from.dy + dy * endFrac),
        paint,
      );
      drawn += dashLen + gapLen;
    }

    // Arrowhead
    final angle = atan2(dy, dx);
    const arrowLen = 8.0;
    const arrowAngle = pi / 6;
    final p1 = Offset(to.dx - arrowLen * cos(angle - arrowAngle), to.dy - arrowLen * sin(angle - arrowAngle));
    final p2 = Offset(to.dx - arrowLen * cos(angle + arrowAngle), to.dy - arrowLen * sin(angle + arrowAngle));
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 11, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_DiscoverCanvasPainter old) =>
      a.x != old.a.x || a.y != old.a.y || b.x != old.b.x || b.y != old.b.y ||
      showSum != old.showSum || showDiff != old.showDiff || showNormalized != old.showNormalized;
}
