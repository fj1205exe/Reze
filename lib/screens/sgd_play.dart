import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/gd.dart' as gd;
import '../utils/sgd.dart' as sgd;

const int _stepsToAdvance = 8;

class SGDPlayScreen extends StatelessWidget {
  final double theta;
  final List<double> history;
  final int steps;
  final double lr;
  final sgd.BatchSize batchSize;
  final VoidCallback onStep;
  final ValueChanged<double> onLrChange;
  final ValueChanged<sgd.BatchSize> onBatchChange;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SGDPlayScreen({
    super.key,
    required this.theta,
    required this.history,
    required this.steps,
    required this.lr,
    required this.batchSize,
    required this.onStep,
    required this.onLrChange,
    required this.onBatchChange,
    required this.onNext,
    required this.onBack,
  });

  Color _batchColor(sgd.BatchSize b) {
    if (b == sgd.BatchSize.full) return C.accent;
    if (b == sgd.BatchSize.mini) return C.blue;
    return C.yellow;
  }

  @override
  Widget build(BuildContext context) {
    final currentLoss = gd.lossFunc(theta);
    final color = _batchColor(batchSize);
    final canAdvance = steps >= _stepsToAdvance;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'SGD', onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How noisy should your gradient be?',
                      style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Pick a batch size, set the learning rate, and step. Watch the tradeoff.',
                      style: inter(fontSize: 14)),
                  const SizedBox(height: 16),

                  // Loss curve card
                  Container(
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        LossCurve(
                          theta: theta,
                          history: history,
                          showMinMarker: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('J(θ)', style: inter(fontSize: 12, color: C.muted)),
                              Text(currentLoss.toStringAsFixed(4), style: mono(fontSize: 15, color: color)),
                              Row(
                                children: [
                                  Text('θ = ', style: inter(fontSize: 12, color: C.muted)),
                                  Text(theta.toStringAsFixed(3), style: mono(fontSize: 13, color: C.purple)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Batch type selector
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('batch type', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 10),
                        Row(
                          children: sgd.BatchSize.values.map((b) {
                            final active = batchSize == b;
                            final bColor = _batchColor(b);
                            final label = b == sgd.BatchSize.full
                                ? 'Full batch'
                                : (b == sgd.BatchSize.mini ? 'Mini-batch' : 'Single sample');

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: InkWell(
                                  onTap: () => onBatchChange(b),
                                  borderRadius: S.borderSm,
                                  child: Container(
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: active ? bColor.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.03),
                                      borderRadius: S.borderSm,
                                      border: Border.all(
                                        color: active ? bColor.withValues(alpha: 0.5) : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: spaceGrotesk(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: active ? bColor : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sgd.batchDescription[batchSize] ?? '',
                          style: inter(fontSize: 12, color: C.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Learning rate slider
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Learning rate (η)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('η = ${lr.toStringAsFixed(2)}', style: mono(fontSize: 13, color: color)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: color,
                            inactiveTrackColor: C.surface3,
                            thumbColor: color,
                            overlayColor: color.withValues(alpha: 0.15),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: lr.clamp(0.05, 1.0),
                            min: 0.05,
                            max: 1.0,
                            onChanged: onLrChange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Step button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: S.borderMd),
                        elevation: 0,
                      ),
                      child: Text(
                        'STEP (SGD)',
                        style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.04),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Steps taken: $steps', style: mono(fontSize: 12, color: C.muted)),
                      Text('Goal: $_stepsToAdvance steps', style: mono(fontSize: 12, color: C.muted)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (canAdvance)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: PrimaryBtn(
                        label: 'See the math',
                        onPressed: onNext,
                      ),
                    )
                  else
                    PrimaryBtn(
                      label: 'Take ${_stepsToAdvance - steps} more steps to advance',
                      disabled: true,
                      onPressed: null,
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
