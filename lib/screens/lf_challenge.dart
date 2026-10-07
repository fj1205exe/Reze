import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/loss_fns.dart' as lf;

class _Scenario {
  final String title;
  final String description;
  final String correct;
  final String explanation;
  _Scenario({required this.title, required this.description, required this.correct, required this.explanation});
}

final _scenarios = [
  _Scenario(
    title: 'Clean regression data',
    description: 'Your data has no outliers and you want the tightest possible fit. Which loss penalizes large errors most?',
    correct: 'mse',
    explanation: 'MSE squares errors, so it aggressively penalizes large deviations — perfect when data is clean.',
  ),
  _Scenario(
    title: 'Noisy sensor readings',
    description: 'Your dataset contains wild outlier spikes from sensor malfunctions. Which loss is most robust?',
    correct: 'mae',
    explanation: 'MAE treats all errors linearly — a 10× error costs 10×, not 100×. Outliers can\'t dominate the gradient.',
  ),
  _Scenario(
    title: 'Financial prediction',
    description: 'You want smooth gradients near zero but don\'t want rare large errors to dominate training. Best of both worlds?',
    correct: 'huber',
    explanation: 'Huber loss is quadratic near zero (smooth gradients) but linear far away (outlier-resistant). The δ parameter controls the transition.',
  ),
  _Scenario(
    title: 'Image reconstruction',
    description: 'You\'re training an autoencoder on clean images. A single blurry pixel matters. Which loss?',
    correct: 'mse',
    explanation: 'MSE\'s squared penalty makes every pixel count. In clean data, this drives the model to reconstruct precisely.',
  ),
  _Scenario(
    title: 'Median regression',
    description: 'You want your model to predict the median of the target distribution, not the mean. Which loss achieves this?',
    correct: 'mae',
    explanation: 'Minimizing MAE finds the median. Minimizing MSE finds the mean. When you want a robust central tendency, use MAE.',
  ),
];

class LFChallengeScreen extends StatefulWidget {
  final int steps;
  final void Function(bool success, int correct, int total) onComplete;
  final VoidCallback onBack;

  const LFChallengeScreen({
    super.key,
    this.steps = 0,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<LFChallengeScreen> createState() => _LFChallengeScreenState();
}

class _LFChallengeScreenState extends State<LFChallengeScreen> {
  int _current = 0;
  int _correct = 0;
  String? _selected;
  bool _answered = false;

  _Scenario get _scenario => _scenarios[_current];
  bool get _done => _current >= _scenarios.length;

  void _pick(String choice) {
    if (_answered) return;
    setState(() {
      _selected = choice;
      _answered = true;
      if (choice == _scenario.correct) _correct++;
    });
  }

  void _advance() {
    setState(() {
      _current++;
      _selected = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return _buildSummary();
    }

    final s = _scenario;
    final isRight = _selected == s.correct;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Loss Functions — Challenge', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProgressPill(current: _current, total: _scenarios.length),
                      const Spacer(),
                      Text('$_correct/$_current correct',
                          style: mono(fontSize: 12, color: C.muted)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(s.title, style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(s.description, style: inter(fontSize: 14, color: const Color(0xFFD1D5DB))),
                  const SizedBox(height: 20),

                  _optionTile('mse', 'MSE', 'Mean Squared Error', const Color(0xFF8B5CF6)),
                  const SizedBox(height: 10),
                  _optionTile('mae', 'MAE', 'Mean Absolute Error', const Color(0xFF38BDF8)),
                  const SizedBox(height: 10),
                  _optionTile('huber', 'Huber', 'Huber Loss', const Color(0xFFFBBF24)),
                  const SizedBox(height: 18),

                  if (_answered) ...[
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 14,
                      child: FeedbackBar(
                        type: isRight ? 'ok' : 'warn',
                        message: isRight ? 'Correct!' : 'Not quite — ${lf.lossNames[s.correct]} was the right pick.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 14,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Text(s.explanation, style: inter(fontSize: 13, color: const Color(0xFFD1D5DB))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: PrimaryBtn(
                        label: _current < _scenarios.length - 1 ? 'Next scenario' : 'See results',
                        onPressed: _current < _scenarios.length - 1 ? _advance : () => setState(() => _current = _scenarios.length),
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

  Widget _optionTile(String id, String label, String subtitle, Color color) {
    final isSelected = _selected == id;
    final isCorrect = _answered && id == _scenario.correct;
    final isWrong = _answered && isSelected && id != _scenario.correct;

    Color borderColor;
    Color bgColor;
    if (isCorrect) {
      borderColor = C.green;
      bgColor = C.green.withValues(alpha: 0.08);
    } else if (isWrong) {
      borderColor = C.pink;
      bgColor = C.pink.withValues(alpha: 0.08);
    } else if (isSelected) {
      borderColor = color;
      bgColor = color.withValues(alpha: 0.08);
    } else {
      borderColor = Colors.white.withValues(alpha: 0.06);
      bgColor = C.surface;
    }

    return GestureDetector(
      onTap: () => _pick(id),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(label, style: spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: inter(fontSize: 12, color: C.muted)),
                ],
              ),
            ),
            if (isCorrect) Icon(Icons.check_circle, color: C.green, size: 20),
            if (isWrong) Icon(Icons.cancel, color: C.pink, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final pct = (_correct / _scenarios.length * 100).round();
    final passed = pct >= 60;

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Loss Functions — Challenge', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                children: [
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 450),
                    slideDistance: 16,
                    child: Column(
                      children: [
                        Icon(
                          passed ? Icons.emoji_events : Icons.refresh,
                          size: 48,
                          color: passed ? C.yellow : C.muted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$_correct / ${_scenarios.length}',
                          style: spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          passed ? 'You know your losses!' : 'Review and try again.',
                          style: inter(fontSize: 14, color: C.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 350),
                    slideDistance: 10,
                    child: Column(
                      children: [
                        PrimaryBtn(label: passed ? 'Complete' : 'See results', onPressed: () => widget.onComplete(passed, _correct, _scenarios.length)),
                        if (!passed) ...[
                          const SizedBox(height: 10),
                          SecondaryBtn(
                            label: 'Retry challenge',
                            onPressed: () => setState(() {
                              _current = 0;
                              _correct = 0;
                              _selected = null;
                              _answered = false;
                            }),
                          ),
                        ],
                      ],
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
