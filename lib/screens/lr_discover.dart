import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/lr.dart' as lr_utils;
import 'lr_play.dart' show LRScatterPainter;

class LRDiscoverScreen extends StatefulWidget {
  final double slope;
  final double intercept;
  final double lr;
  final int steps;
  final void Function(double slope, double intercept) onUpdate;
  final void Function(double newSlope, double newIntercept) onGradientStep;
  final ValueChanged<double> onLrChange;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LRDiscoverScreen({
    super.key,
    required this.slope,
    required this.intercept,
    required this.lr,
    required this.steps,
    required this.onUpdate,
    required this.onGradientStep,
    required this.onLrChange,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LRDiscoverScreen> createState() => _LRDiscoverScreenState();
}

class _LRDiscoverScreenState extends State<LRDiscoverScreen> {
  int _discoverSteps = 0;
  String? _feedbackType;
  String _feedbackMsg = '';
  double _prevMSE = double.infinity;

  void _updateFeedback(double mse, {bool wasGradientStep = false}) {
    setState(() {
      if (mse < 0.005) {
        _feedbackType = 'ok';
        _feedbackMsg = 'Good fit! MSE is very low';
      } else if (wasGradientStep && mse < _prevMSE) {
        _feedbackType = 'info';
        _feedbackMsg = 'The gradient points toward the steepest improvement';
      } else if (mse < 0.02) {
        _feedbackType = 'info';
        _feedbackMsg = 'Lower MSE = better fit';
      } else {
        _feedbackType = 'info';
        _feedbackMsg = 'MSE measures average squared error';
      }
      _prevMSE = mse;
    });
  }

  void _handleSliderUpdate(double slope, double intercept) {
    setState(() => _discoverSteps++);
    final mse = lr_utils.calcMSE(slope, intercept);
    _updateFeedback(mse);
    widget.onUpdate(slope, intercept);
  }

  void _handleGradientStep() {
    final n = lr_utils.dataPoints.length;
    double dSlope = 0;
    double dIntercept = 0;

    for (final pt in lr_utils.dataPoints) {
      final pred = widget.slope * pt.x + widget.intercept;
      dSlope += (pred - pt.y) * pt.x;
      dIntercept += (pred - pt.y);
    }
    dSlope = (2.0 / n) * dSlope;
    dIntercept = (2.0 / n) * dIntercept;

    final newSlope = (widget.slope - widget.lr * dSlope).clamp(-1.0, 2.0);
    final newIntercept =
        (widget.intercept - widget.lr * dIntercept).clamp(-0.3, 1.2);

    setState(() => _discoverSteps++);
    final mse = lr_utils.calcMSE(newSlope, newIntercept);
    _updateFeedback(mse, wasGradientStep: true);
    widget.onGradientStep(newSlope, newIntercept);
  }

  @override
  Widget build(BuildContext context) {
    final mse = lr_utils.calcMSE(widget.slope, widget.intercept);
    final goodFit = lr_utils.isGoodFit(widget.slope, widget.intercept);

    String mseZone;
    Color zoneColor;
    if (mse < 0.005) {
      mseZone = 'excellent';
      zoneColor = C.green;
    } else if (mse < 0.05) {
      mseZone = 'good fit';
      zoneColor = C.green;
    } else if (mse < 0.15) {
      mseZone = 'improving';
      zoneColor = C.yellow;
    } else {
      mseZone = 'high error';
      zoneColor = C.pink;
    }

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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: C.surface2,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_left,
                          color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LINEAR REGRESSION',
                            style: spaceGrotesk(
                                fontSize: 10,
                                color: C.muted,
                                letterSpacing: 0.12)),
                        Text('Explore slope, intercept & gradient.',
                            style: spaceGrotesk(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  StepCounter(steps: widget.steps),
                ],
              ),
            ),
          ),
          // Scatter plot with MSE and zone badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MSE',
                            style: inter(fontSize: 12, color: C.muted)),
                        Text(mse.toStringAsFixed(4),
                            style:
                                mono(fontSize: 17, color: C.accentLight)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14171C)
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: zoneColor.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: zoneColor)),
                          const SizedBox(width: 6),
                          Text(mseZone,
                              style:
                                  inter(fontSize: 12, color: zoneColor)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: AspectRatio(
                      aspectRatio: 350 / 200,
                      child: CustomPaint(
                        painter: LRScatterPainter(
                          slope: widget.slope,
                          intercept: widget.intercept,
                          goodFit: goodFit,
                        ),
                      ),
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
                  // Slope & intercept sliders
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Slope',
                                style: spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            Text(
                                'm = ${widget.slope.toStringAsFixed(2)}',
                                style: mono(
                                    fontSize: 13,
                                    color: C.accentLight)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.accent,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.accent,
                            overlayColor:
                                C.accent.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape:
                                const RoundSliderThumbShape(
                                    enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: widget.slope.clamp(-1.0, 2.0),
                            min: -1,
                            max: 2,
                            onChanged: (v) =>
                                _handleSliderUpdate(v, widget.intercept),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Intercept',
                                style: spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            Text(
                                'b = ${widget.intercept.toStringAsFixed(2)}',
                                style:
                                    mono(fontSize: 13, color: C.blue)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.blue,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.blue,
                            overlayColor:
                                C.blue.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape:
                                const RoundSliderThumbShape(
                                    enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value:
                                widget.intercept.clamp(-0.3, 1.2),
                            min: -0.3,
                            max: 1.2,
                            onChanged: (v) =>
                                _handleSliderUpdate(widget.slope, v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Learning rate slider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Learning rate',
                            style: spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        LrSlider(
                          value: widget.lr,
                          onChange: (v) {
                            setState(() => _feedbackType = null);
                            widget.onLrChange(v);
                          },
                          min: 0.01,
                          max: 1.0,
                        ),
                      ],
                    ),
                  ),
                  if (_feedbackType != null) ...[
                    const SizedBox(height: 16),
                    FeedbackBar(
                        type: _feedbackType!, message: _feedbackMsg),
                  ],
                  const SizedBox(height: 16),
                  PrimaryBtn(
                      label: 'Gradient Step',
                      onPressed: _handleGradientStep),
                  if (_discoverSteps >= 5) ...[
                    const SizedBox(height: 12),
                    SecondaryBtn(
                      label: 'I understand — show me the math →',
                      onPressed: widget.onNext,
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
}
