import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/bayes.dart' as bay_utils;

enum _BayPhase { guess, reveal, explore }

class BAYPlayScreen extends StatefulWidget {
  final double prior;
  final double sensitivity;
  final double specificity;
  final void Function(double p, double se, double sp) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BAYPlayScreen({
    super.key,
    required this.prior,
    required this.sensitivity,
    required this.specificity,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BAYPlayScreen> createState() => _BAYPlayScreenState();
}

class _BAYPlayScreenState extends State<BAYPlayScreen> {
  _BayPhase _phase = _BayPhase.guess;
  int? _selectedGuess;
  int _sliderMoves = 0;

  final _guessOptions = [
    {'label': '~5%', 'sub': 'Too low — even with 95% test?', 'correct': false},
    {'label': '~16%', 'sub': 'Surprisingly low', 'correct': true},
    {'label': '~50%', 'sub': 'Fifty-fifty chance', 'correct': false},
    {'label': '~95%', 'sub': 'Same as the test accuracy', 'correct': false},
  ];

  @override
  Widget build(BuildContext context) {
    final prior = widget.prior;
    final sensitivity = widget.sensitivity;
    final specificity = widget.specificity;

    final stats = bay_utils.calcPopStats(prior, sensitivity, specificity);
    final posterior = stats.posterior;
    final postColor = posterior < 0.3 ? C.pink : (posterior < 0.7 ? C.yellow : C.green);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: "Bayes' Theorem", onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_phase == _BayPhase.guess) ...[
                    Text('The Base Rate Fallacy', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      'A disease affects 1% of the population. A test is 95% accurate (95% sensitivity, 95% specificity). You test positive. What is the chance you actually have the disease?',
                      style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: List.generate(_guessOptions.length, (i) {
                        final opt = _guessOptions[i];
                        final isSel = _selectedGuess == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => setState(() => _selectedGuess = i),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSel ? C.accent.withValues(alpha: 0.15) : C.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSel ? C.accent : Colors.white.withValues(alpha: 0.06)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(opt['label'] as String, style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: isSel ? C.accentLight : C.txt)),
                                  Text(opt['sub'] as String, style: inter(fontSize: 12, color: C.muted)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    PrimaryBtn(
                      label: 'CONFIRM GUESS',
                      disabled: _selectedGuess == null,
                      onPressed: _selectedGuess != null ? () => setState(() => _phase = _BayPhase.reveal) : null,
                    ),
                  ] else if (_phase == _BayPhase.reveal) ...[
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedGuess == 1 ? 'Correct! ~16%' : 'Surprise: It is only ~16%',
                            style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: _selectedGuess == 1 ? C.green : C.yellow),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Out of 1,000 people:\n• 10 have the disease → ~9 test positive.\n• 990 do NOT have the disease → ~50 test false positive!\nOut of ~59 positive tests, only 9 actually have the disease: 9 / 59 ≈ 16%.',
                            style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildDotGrid(0.01, 0.95, 0.95),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 12,
                      child: PrimaryBtn(
                        label: 'EXPLORE WITH SLIDERS',
                        onPressed: () => setState(() => _phase = _BayPhase.explore),
                      ),
                    ),
                  ] else ...[
                    Text('Update beliefs with evidence.', style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Adjust prior, sensitivity, and specificity to observe posterior P(H|E).', style: inter(fontSize: 14)),
                    const SizedBox(height: 16),

                    // Population grid
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        children: [
                          _buildDotGrid(prior, sensitivity, specificity),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('True +', style: mono(fontSize: 10, color: C.muted)),
                              const SizedBox(width: 10),
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFB7185), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('False +', style: mono(fontSize: 10, color: C.muted)),
                              const SizedBox(width: 10),
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4B5563), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('False −', style: mono(fontSize: 10, color: C.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Posterior display card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: postColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Posterior P(Disease | +Test)', style: inter(fontSize: 12, color: C.muted)),
                              const SizedBox(height: 4),
                              Text(
                                '${(posterior * 100).toStringAsFixed(1)}%',
                                style: mono(fontSize: 22, fontWeight: FontWeight.bold, color: postColor),
                              ),
                            ],
                          ),
                          Text('${stats.truePositive} TP / ${stats.truePositive + stats.falsePositive} total +', style: mono(fontSize: 11, color: C.muted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Prior Slider
                    _buildSlider(
                      'Prior P(Disease)',
                      prior,
                      0.005,
                      0.30,
                      C.yellow,
                      (v) {
                        widget.onUpdate(v, sensitivity, specificity);
                        setState(() => _sliderMoves++);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Sensitivity Slider
                    _buildSlider(
                      'Sensitivity (True + rate)',
                      sensitivity,
                      0.70,
                      0.99,
                      C.accentLight,
                      (v) {
                        widget.onUpdate(prior, v, specificity);
                        setState(() => _sliderMoves++);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Specificity Slider
                    _buildSlider(
                      'Specificity (True − rate)',
                      specificity,
                      0.70,
                      0.99,
                      C.blue,
                      (v) {
                        widget.onUpdate(prior, sensitivity, v);
                        setState(() => _sliderMoves++);
                      },
                    ),
                    const SizedBox(height: 20),

                    PrimaryBtn(
                      label: 'See the math',
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

  Widget _buildSlider(String label, double val, double min, double max, Color color, ValueChanged<double> onChange) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Text(label, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${(val * 100).toStringAsFixed(1)}%', style: mono(fontSize: 13, color: color)),
            ],
          ),
          Slider(
            value: val.clamp(min, max),
            min: min,
            max: max,
            activeColor: color,
            onChanged: onChange,
          ),
        ],
      ),
    );
  }

  Widget _buildDotGrid(double prior, double sensitivity, double specificity) {
    final stats = bay_utils.calcPopStats(prior, sensitivity, specificity);
    final tp100 = (stats.truePositive / 10).round();
    final fp100 = (stats.falsePositive / 10).round();
    final fn100 = (stats.falseNegative / 10).round();

    final dots = <Color>[];
    for (int i = 0; i < tp100 && dots.length < 100; i++) {
      dots.add(const Color(0xFF8B5CF6));
    }
    for (int i = 0; i < fp100 && dots.length < 100; i++) {
      dots.add(const Color(0xFFFB7185));
    }
    for (int i = 0; i < fn100 && dots.length < 100; i++) {
      dots.add(const Color(0xFF4B5563));
    }
    while (dots.length < 100) {
      dots.add(const Color(0xFF1E242D));
    }

    return Center(
      child: SizedBox(
        width: 190,
        height: 190,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: 100,
          itemBuilder: (_, idx) => Container(
            decoration: BoxDecoration(
              color: dots[idx],
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
