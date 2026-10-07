import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../widgets/loss_curve.dart';
import '../utils/sgd.dart' as sgd;

class SGDDiscoverScreen extends StatefulWidget {
  final double theta;
  final List<double> history;
  final double lr;
  final sgd.BatchSize batchSize;
  final VoidCallback onStep;
  final ValueChanged<double> onLrChange;
  final ValueChanged<sgd.BatchSize> onBatchChange;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SGDDiscoverScreen({
    super.key,
    required this.theta,
    required this.history,
    required this.lr,
    required this.batchSize,
    required this.onStep,
    required this.onLrChange,
    required this.onBatchChange,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<SGDDiscoverScreen> createState() => _SGDDiscoverScreenState();
}

class _SGDDiscoverScreenState extends State<SGDDiscoverScreen> {
  final Set<sgd.BatchSize> _tried = {};

  @override
  void initState() {
    super.initState();
    _tried.add(widget.batchSize);
  }

  @override
  void didUpdateWidget(SGDDiscoverScreen old) {
    super.didUpdateWidget(old);
    _tried.add(widget.batchSize);
  }

  bool get _allTried => _tried.length >= 3;

  String get _feedbackMsg {
    if (_tried.length == 1) {
      return 'Take a few steps, then switch to a different batch size.';
    }
    if (_tried.length == 2) {
      final missing = sgd.BatchSize.values.firstWhere((b) => !_tried.contains(b));
      return 'Now try ${sgd.batchLabels[missing]} to see the difference.';
    }
    if (widget.history.length < 6) {
      return 'All three tried. Take more steps to see the paths diverge.';
    }
    return 'Notice: smaller batches add noise but can escape flat regions.';
  }

  String get _feedbackType {
    if (_allTried && widget.history.length >= 6) return 'ok';
    return 'info';
  }

  @override
  Widget build(BuildContext context) {
    final noiseDesc = sgd.batchDescription[widget.batchSize] ?? '';

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'SGD — Discover', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How noise changes learning.',
                      style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Switch batch sizes and compare the paths.',
                      style: inter(fontSize: 14)),
                  const SizedBox(height: 14),

                  // Loss curve with history
                  Container(
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: LossCurveWidget(
                      theta: widget.theta,
                      history: widget.history,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Batch size selector — 3 cards
                  Row(
                    children: sgd.BatchSize.values.map((b) {
                      final selected = widget.batchSize == b;
                      final tried = _tried.contains(b);
                      final color = b == sgd.BatchSize.full
                          ? C.accent
                          : b == sgd.BatchSize.mini
                              ? C.blue
                              : C.yellow;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onBatchChange(b),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: b != sgd.BatchSize.stochastic ? 6 : 0,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withValues(alpha: 0.15)
                                  : C.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? color.withValues(alpha: 0.5)
                                    : tried
                                        ? color.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        b == sgd.BatchSize.full
                                            ? 'Full'
                                            : b == sgd.BatchSize.mini
                                                ? 'Mini'
                                                : 'Stoch',
                                        style: spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: selected ? color : C.muted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'noise: ${(sgd.noiseFactor[b]! * 100).round()}%',
                                  style: mono(fontSize: 10, color: C.muted),
                                ),
                                if (tried)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(Icons.check, size: 12, color: color),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  // Current mode description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sgd.batchLabels[widget.batchSize] ?? '',
                          style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(noiseDesc, style: inter(fontSize: 13, color: C.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Step info
                  Row(
                    children: [
                      StepCounter(steps: widget.history.length),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('θ = ', style: inter(fontSize: 12, color: C.muted)),
                            Text(
                              widget.theta.toStringAsFixed(2),
                              style: mono(fontSize: 13, color: C.accentLight),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_tried.length}/3 tried',
                        style: mono(fontSize: 11, color: _allTried ? C.green : C.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  FeedbackBar(message: _feedbackMsg, type: _feedbackType),
                  const SizedBox(height: 16),

                  PrimaryBtn(label: 'Step', onPressed: widget.onStep),
                  const SizedBox(height: 12),

                  if (_allTried && widget.history.length >= 6)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: SecondaryBtn(
                        label: 'Why does noise help? →',
                        onPressed: widget.onNext,
                      ),
                    )
                  else
                    PrimaryBtn(
                      label: _allTried
                          ? 'Take a few more steps...'
                          : 'Try all 3 batch sizes to continue',
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
