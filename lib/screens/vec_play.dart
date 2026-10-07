import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/vectors.dart' as vec_utils;

class VECPlayScreen extends StatefulWidget {
  final double ax, ay, bx, by;
  final bool showSum, showDiff;
  final void Function(double, double)? onUpdateA;
  final void Function(double, double)? onUpdateB;
  final VoidCallback? onToggleSum;
  final VoidCallback? onToggleDiff;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const VECPlayScreen({
    super.key,
    this.ax = 0.8, this.ay = 0.6,
    this.bx = -0.5, this.by = 0.9,
    this.showSum = false, this.showDiff = false,
    this.onUpdateA, this.onUpdateB,
    this.onToggleSum, this.onToggleDiff,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<VECPlayScreen> createState() => _VECPlayScreenState();
}

class _VECPlayScreenState extends State<VECPlayScreen> {
  bool _tappedA = false;
  bool _tappedB = false;
  String? _inspecting; // 'a', 'b', or null

  void _handleCanvasTap(TapDownDetails details, BoxConstraints constraints) {
    final ox = constraints.maxWidth / 2;
    final oy = constraints.maxHeight / 2;
    final scale = min(constraints.maxWidth, constraints.maxHeight) * 0.35;
    final a = vec_utils.Vec2(widget.ax, widget.ay);
    final b = vec_utils.Vec2(widget.bx, widget.by);

    final tipA = Offset(ox + a.x * scale, oy - a.y * scale);
    final tipB = Offset(ox + b.x * scale, oy - b.y * scale);
    final tap = details.localPosition;

    final distA = (tap - tipA).distance;
    final distB = (tap - tipB).distance;

    const hitRadius = 36.0;

    setState(() {
      if (distA < hitRadius && distA <= distB) {
        _tappedA = true;
        _inspecting = 'a';
      } else if (distB < hitRadius) {
        _tappedB = true;
        _inspecting = 'b';
      } else {
        _inspecting = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = vec_utils.Vec2(widget.ax, widget.ay);
    final b = vec_utils.Vec2(widget.bx, widget.by);
    final magA = vec_utils.vecMagnitude(a);
    final magB = vec_utils.vecMagnitude(b);
    final unlocked = _tappedA && _tappedB;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Vectors', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vectors in 2D space.',
                      style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Tap each vector to inspect it.',
                      style: inter(fontSize: 14)),
                  const SizedBox(height: 16),

                  // Canvas
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onTapDown: (d) => _handleCanvasTap(d, constraints),
                          child: CustomPaint(
                            painter: _PlayCanvasPainter(
                              a: a,
                              b: b,
                              highlightA: _inspecting == 'a',
                              highlightB: _inspecting == 'b',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _inspectCard(
                          'Vector a',
                          a,
                          magA,
                          C.accentLight,
                          _tappedA,
                          _inspecting == 'a',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _inspectCard(
                          'Vector b',
                          b,
                          magB,
                          C.blue,
                          _tappedB,
                          _inspecting == 'b',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (!_tappedA || !_tappedB)
                    FeedbackBar(
                      type: 'info',
                      message: !_tappedA && !_tappedB
                          ? 'Tap the tip of each vector on the canvas.'
                          : _tappedA
                              ? 'Now tap vector b.'
                              : 'Now tap vector a.',
                    ),

                  if (unlocked) ...[
                    const SizedBox(height: 8),
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: FeedbackBar(type: 'ok', message: 'Both vectors inspected.'),
                    ),
                  ],

                  const SizedBox(height: 20),
                  PrimaryBtn(
                    label: unlocked ? 'Continue' : 'Tap both vectors to continue',
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
                        label: 'Try changing the vectors →',
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

  Widget _inspectCard(String label, vec_utils.Vec2 v, double mag, Color color, bool tapped, bool active) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? color.withValues(alpha: 0.5) : color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          if (tapped) ...[
            Text('(${v.x.toStringAsFixed(2)}, ${v.y.toStringAsFixed(2)})',
                style: mono(fontSize: 11, color: C.txt)),
            Text('|${label.split(' ').last}| = ${mag.toStringAsFixed(2)}',
                style: mono(fontSize: 10, color: C.muted)),
          ] else
            Text('Tap to inspect', style: inter(fontSize: 11, color: C.muted)),
        ],
      ),
    );
  }
}

class _PlayCanvasPainter extends CustomPainter {
  final vec_utils.Vec2 a, b;
  final bool highlightA, highlightB;

  _PlayCanvasPainter({
    required this.a,
    required this.b,
    required this.highlightA,
    required this.highlightB,
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

    // Highlight rings
    if (highlightA) {
      canvas.drawCircle(
        toScreen(a),
        14,
        Paint()
          ..color = C.accentLight.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
    }
    if (highlightB) {
      canvas.drawCircle(
        toScreen(b),
        14,
        Paint()
          ..color = C.blue.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
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
    canvas.drawLine(from, to, Paint()..color = color..strokeWidth = 2.5);

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

  void _drawText(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 11, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_PlayCanvasPainter old) =>
      highlightA != old.highlightA || highlightB != old.highlightB;
}
