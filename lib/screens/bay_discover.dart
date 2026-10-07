import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/bayes.dart' as bay_utils;

class BAYDiscoverScreen extends StatefulWidget {
  final double prior;
  final double sensitivity;
  final double specificity;
  final int steps;
  final void Function(double p, double se, double sp) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BAYDiscoverScreen({
    super.key,
    required this.prior,
    required this.sensitivity,
    required this.specificity,
    required this.steps,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BAYDiscoverScreen> createState() => _BAYDiscoverScreenState();
}

class _BAYDiscoverScreenState extends State<BAYDiscoverScreen> {
  int _discoverSteps = 0;
  final Set<String> _adjustedSliders = {};

  String get _feedbackMsg {
    final prior = widget.prior;
    final sensitivity = widget.sensitivity;
    final specificity = widget.specificity;

    if (prior < 0.02 && sensitivity > 0.90) {
      return 'Low prior + positive test ≠ high probability — the base rate matters!';
    }
    if (sensitivity > 0.95 && specificity > 0.95) {
      return 'Sensitivity catches true cases, specificity rules out false alarms.';
    }
    if (prior < 0.05 && specificity < 0.95) {
      return 'False positives dominate when disease is rare — even with a good test.';
    }
    if (sensitivity < 0.80) {
      return 'Low sensitivity = many false negatives (missed cases).';
    }
    if (specificity < 0.80) {
      return 'Low specificity = many false positives (false alarms).';
    }
    return 'Adjust all three parameters to see how they interact.';
  }

  String get _feedbackType {
    final prior = widget.prior;
    final posterior = bay_utils.calcPosterior(prior, widget.sensitivity, widget.specificity);
    if (posterior > 0.7) return 'ok';
    if (prior < 0.02) return 'warn';
    return 'info';
  }

  @override
  Widget build(BuildContext context) {
    final stats = bay_utils.calcPopStats(widget.prior, widget.sensitivity, widget.specificity);
    final posterior = stats.posterior;
    final postColor = posterior < 0.3 ? C.pink : (posterior < 0.7 ? C.yellow : C.green);
    final unlocked = _adjustedSliders.length >= 3 && _discoverSteps >= 5;

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
                        Text("BAYES' THEOREM", style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        Text('Explore test accuracy.', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  StepCounter(steps: widget.steps),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Natural frequency tree visualization
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: postColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('POPULATION: 1,000 PEOPLE', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        const SizedBox(height: 16),
                        _buildFrequencyTree(stats),
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Posterior P(Disease | +Test)', style: inter(fontSize: 11, color: C.muted)),
                                const SizedBox(height: 4),
                                Text(
                                  '${(posterior * 100).toStringAsFixed(1)}%',
                                  style: mono(fontSize: 20, fontWeight: FontWeight.bold, color: postColor),
                                ),
                              ],
                            ),
                            Text('${stats.truePositive} TP / ${stats.truePositive + stats.falsePositive} total +',
                              style: mono(fontSize: 11, color: C.muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prior Slider
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Prior P(Disease)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('${(widget.prior * 100).toStringAsFixed(1)}%', style: mono(fontSize: 13, color: C.yellow)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.yellow,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.yellow,
                            overlayColor: C.yellow.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: widget.prior.clamp(0.005, 0.30),
                            min: 0.005,
                            max: 0.30,
                            onChanged: (v) {
                              setState(() {
                                _discoverSteps++;
                                _adjustedSliders.add('prior');
                              });
                              widget.onUpdate(v, widget.sensitivity, widget.specificity);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Sensitivity Slider
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sensitivity (True + rate)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('${(widget.sensitivity * 100).toStringAsFixed(0)}%', style: mono(fontSize: 13, color: C.purple)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.purple,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.purple,
                            overlayColor: C.purple.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: widget.sensitivity.clamp(0.70, 0.99),
                            min: 0.70,
                            max: 0.99,
                            onChanged: (v) {
                              setState(() {
                                _discoverSteps++;
                                _adjustedSliders.add('sensitivity');
                              });
                              widget.onUpdate(widget.prior, v, widget.specificity);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Specificity Slider
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Specificity (True − rate)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('${(widget.specificity * 100).toStringAsFixed(0)}%', style: mono(fontSize: 13, color: C.blue)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: C.blue,
                            inactiveTrackColor: C.surface3,
                            thumbColor: C.blue,
                            overlayColor: C.blue.withValues(alpha: 0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: widget.specificity.clamp(0.70, 0.99),
                            min: 0.70,
                            max: 0.99,
                            onChanged: (v) {
                              setState(() {
                                _discoverSteps++;
                                _adjustedSliders.add('specificity');
                              });
                              widget.onUpdate(widget.prior, widget.sensitivity, v);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  FeedbackBar(type: _feedbackType, message: _feedbackMsg),
                  const SizedBox(height: 16),

                  if (unlocked) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: SecondaryBtn(label: 'I understand — show me the math →', onPressed: widget.onNext),
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

  Widget _buildFrequencyTree(bay_utils.PopStats stats) {
    return Column(
      children: [
        // Root: 1000 people
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: C.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text('1,000 people', style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),

        // Split: Disease / No Disease
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: C.pink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: C.pink.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('Disease', style: spaceGrotesk(fontSize: 11, color: C.pink)),
                        Text('${stats.hasDisease}', style: mono(fontSize: 16, fontWeight: FontWeight.bold, color: C.pink)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Test outcomes for diseased
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: C.surface2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Test +', style: inter(fontSize: 10, color: C.muted)),
                            Text('${stats.truePositive}', style: mono(fontSize: 11, color: C.purple, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Test −', style: inter(fontSize: 10, color: C.muted)),
                            Text('${stats.falseNegative}', style: mono(fontSize: 11, color: C.muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: C.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: C.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('No Disease', style: spaceGrotesk(fontSize: 11, color: C.green)),
                        Text('${stats.doesntHaveDisease}', style: mono(fontSize: 16, fontWeight: FontWeight.bold, color: C.green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Test outcomes for non-diseased
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: C.surface2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Test +', style: inter(fontSize: 10, color: C.muted)),
                            Text('${stats.falsePositive}', style: mono(fontSize: 11, color: C.pink, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Test −', style: inter(fontSize: 10, color: C.muted)),
                            Text('${stats.trueNegative}', style: mono(fontSize: 11, color: C.muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
