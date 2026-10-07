import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/gd.dart' as gd;
import '../theme.dart';

class LossCurvePainter extends CustomPainter {
  final double theta;
  final List<double> history;
  final bool showMinMarker;

  LossCurvePainter({required this.theta, this.history = const [], this.showMinMarker = true});

  static const double pl = 30, pr = 20, pt = 20, pb = 30;

  double _xOf(double t, double w) {
    final iw = w - pl - pr;
    return pl + ((t - gd.tMin) / (gd.tMax - gd.tMin)) * iw;
  }

  double _yOf(double l, double h) {
    final ih = h - pt - pb;
    return pt + ih - ((l - gd.curveLossMin) / (gd.curveLossMax - gd.curveLossMin)) * ih;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final iw = w - pl - pr;
    final ih = h - pt - pb;

    // Background
    final bgPaint = Paint()..color = const Color(0xFF1B1F26).withValues(alpha: 0.4);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pl, pt, iw, ih), const Radius.circular(3)), bgPaint);

    // Grid lines
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.04)..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(pl, pt + ih * f), Offset(pl + iw, pt + ih * f), gridPaint);
    }

    // History dots
    for (int i = 0; i < history.length; i++) {
      final ht = history[i];
      final dotPaint = Paint()..color = C.accent.withValues(alpha: (i + 1) / history.length * 0.45);
      canvas.drawCircle(Offset(_xOf(ht, w), _yOf(gd.lossFunc(ht), h)), 2.5, dotPaint);
    }

    // Min marker
    if (showMinMarker) {
      final minX = _xOf(gd.trueMin, w);
      final minY = _yOf(gd.lossFunc(gd.trueMin), h);
      final dashPaint = Paint()
        ..color = C.green.withValues(alpha: 0.3)
        ..strokeWidth = 1;
      for (double y = pt; y < pt + ih; y += 8) {
        canvas.drawLine(Offset(minX, y), Offset(minX, y + 3), dashPaint);
      }
      canvas.drawCircle(Offset(minX, minY), 5, Paint()..color = C.green.withValues(alpha: 0.45));

      final tp = TextPainter(
        text: TextSpan(text: 'min', style: GoogleFonts.jetBrainsMono(color: C.green.withValues(alpha: 0.55), fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(minX + 5, pt + 3));
    }

    // Curve
    final samples = gd.sampleCurve(200);
    final curvePath = Path();
    for (int i = 0; i < samples.length; i++) {
      final x = _xOf(samples[i]['t']!, w);
      final y = _yOf(samples[i]['loss']!, h);
      if (i == 0) {
        curvePath.moveTo(x, y);
      } else {
        curvePath.lineTo(x, y);
      }
    }
    canvas.drawPath(curvePath, Paint()
      ..color = C.accent
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke);

    // Ball
    final ballX = _xOf(theta, w);
    final ballY = _yOf(gd.lossFunc(theta), h);
    canvas.drawCircle(Offset(ballX, ballY), 8, Paint()..color = C.accent);
    canvas.drawCircle(Offset(ballX, ballY), 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(LossCurvePainter oldDelegate) =>
      theta != oldDelegate.theta || !_listEquals(history, oldDelegate.history);
}

bool _listEquals(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class LossCurveWidget extends StatefulWidget {
  final double theta;
  final List<double> history;
  final bool showMinMarker;
  final double height;
  const LossCurveWidget({
    super.key,
    required this.theta,
    this.history = const [],
    this.showMinMarker = true,
    this.height = 200,
  });

  @override
  State<LossCurveWidget> createState() => _LossCurveWidgetState();
}

class _LossCurveWidgetState extends State<LossCurveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  double _displayTheta = 0;
  double _fromTheta = 0;

  @override
  void initState() {
    super.initState();
    _displayTheta = widget.theta;
    _fromTheta = widget.theta;
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    )..addListener(() {
        setState(() {
          final t = Curves.easeOutCubic.transform(_ctrl.value);
          _displayTheta = _fromTheta + (widget.theta - _fromTheta) * t;
        });
      });
  }

  @override
  void didUpdateWidget(LossCurveWidget old) {
    super.didUpdateWidget(old);
    if (old.theta != widget.theta) {
      _fromTheta = _displayTheta;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: CustomPaint(
        painter: LossCurvePainter(
          theta: _displayTheta,
          history: widget.history,
          showMinMarker: widget.showMinMarker,
        ),
      ),
    );
  }
}

typedef LossCurve = LossCurveWidget;
