import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/bayes.dart' as bay_utils;

const _scenarios = [
  {
    'name': 'Rare Cancer Screening',
    'prior': 0.01,
    'sensitivity': 0.90,
    'specificity': 0.95,
    'desc': 'Cancer affects 1% of population. Test is 90% sensitive, 95% specific. You test positive.',
  },
  {
    'name': 'Common Flu Test',
    'prior': 0.20,
    'sensitivity': 0.85,
    'specificity': 0.80,
    'desc': '20% have flu. Test is 85% sensitive, 80% specific. You test positive.',
  },
  {
    'name': 'Genetic Marker',
    'prior': 0.05,
    'sensitivity': 0.98,
    'specificity': 0.92,
    'desc': 'Marker in 5% of people. Test is 98% sensitive, 92% specific. You test positive.',
  },
];

class BAYChallengeScreen extends StatefulWidget {
  final int steps;
  final void Function(bool success, int correct, int total) onComplete;
  final VoidCallback onBack;

  const BAYChallengeScreen({
    super.key,
    required this.steps,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<BAYChallengeScreen> createState() => _BAYChallengeScreenState();
}

class _BAYChallengeScreenState extends State<BAYChallengeScreen> {
  int _currentScenario = 0;
  double _userGuess = 50.0;
  bool _submitted = false;
  final List<bool> _results = [];
  bool _started = false;

  bool get _done => _results.length >= 3;
  int get _correctCount => _results.where((r) => r).length;
  bool get _passed => _correctCount >= 2;

  void _handleSubmit() {
    final scenario = _scenarios[_currentScenario];
    final truePosterior = bay_utils.calcPosterior(
      scenario['prior'] as double,
      scenario['sensitivity'] as double,
      scenario['specificity'] as double,
    ) * 100;

    final diff = (truePosterior - _userGuess).abs();
    final correct = diff <= 5.0;

    setState(() {
      _submitted = true;
      _results.add(correct);
    });
  }

  void _handleNext() {
    if (_currentScenario < _scenarios.length - 1) {
      setState(() {
        _currentScenario++;
        _userGuess = 50.0;
        _submitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return _buildStartScreen();
    }

    if (_done) {
      return _buildResultScreen();
    }

    return _buildScenarioScreen();
  }

  Widget _buildStartScreen() {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: S.headerPad,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.yellow.withValues(alpha: 0.25)),
                          ),
                          child: Text('CHALLENGE', style: spaceGrotesk(fontSize: 12, color: C.yellow)),
                        ),
                        const SizedBox(height: 4),
                        Text('Estimate the posterior.',
                          style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The Challenge', style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text(
                    'You will see 3 medical test scenarios. For each one, estimate the probability that you actually have the condition given a positive test result.',
                    style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rules', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Text('• Estimate the posterior probability (0-100%)\n• You must be within ±5% of the true value\n• Pass 2 out of 3 scenarios to succeed',
                          style: inter(fontSize: 13, color: const Color(0xFFD1D5DB))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryBtn(label: 'START CHALLENGE', onPressed: () => setState(() => _started = true)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioScreen() {
    final scenario = _scenarios[_currentScenario];
    final prior = scenario['prior'] as double;
    final sensitivity = scenario['sensitivity'] as double;
    final specificity = scenario['specificity'] as double;
    final truePosterior = bay_utils.calcPosterior(prior, sensitivity, specificity) * 100;
    final stats = bay_utils.calcPopStats(prior, sensitivity, specificity);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: S.headerPad,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: C.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.yellow.withValues(alpha: 0.25)),
                          ),
                          child: Text('CHALLENGE', style: spaceGrotesk(fontSize: 12, color: C.yellow)),
                        ),
                        const SizedBox(height: 4),
                        Text('Scenario ${_currentScenario + 1} / 3',
                          style: spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(3, (i) {
                      final color = i < _results.length
                          ? (_results[i] ? C.green : C.pink)
                          : const Color(0xFF4B5563);
                      return Container(
                        width: 8, height: 8,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scenario card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scenario['name'] as String, style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(scenario['desc'] as String, style: inter(fontSize: 14, color: const Color(0xFFD1D5DB))),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: C.surface2,
                                  borderRadius: S.borderSm,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Prior', style: inter(fontSize: 10, color: C.muted)),
                                    Text('${(prior * 100).toStringAsFixed(0)}%', style: mono(fontSize: 13, color: C.yellow)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: C.surface2,
                                  borderRadius: S.borderSm,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sensitivity', style: inter(fontSize: 10, color: C.muted)),
                                    Text('${(sensitivity * 100).toStringAsFixed(0)}%', style: mono(fontSize: 13, color: C.purple)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: C.surface2,
                                  borderRadius: S.borderSm,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Specificity', style: inter(fontSize: 10, color: C.muted)),
                                    Text('${(specificity * 100).toStringAsFixed(0)}%', style: mono(fontSize: 13, color: C.blue)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User guess slider
                  if (!_submitted)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: S.borderMd,
                        border: Border.all(color: C.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Your estimate', style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('${_userGuess.round()}%', style: mono(fontSize: 18, color: C.accent)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: C.accent,
                              inactiveTrackColor: C.surface3,
                              thumbColor: C.accent,
                              overlayColor: C.accent.withValues(alpha: 0.15),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _userGuess,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              onChanged: (v) => setState(() => _userGuess = v),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Result after submission
                  if (_submitted) ...[
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 450),
                      slideDistance: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (_userGuess - truePosterior).abs() <= 5.0
                              ? C.green.withValues(alpha: 0.1)
                              : C.pink.withValues(alpha: 0.08),
                          borderRadius: S.borderMd,
                          border: Border.all(
                            color: (_userGuess - truePosterior).abs() <= 5.0
                                ? C.green.withValues(alpha: 0.3)
                                : C.pink.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (_userGuess - truePosterior).abs() <= 5.0 ? 'Correct!' : 'Close, but not quite.',
                              style: spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: (_userGuess - truePosterior).abs() <= 5.0 ? C.green : C.pink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your guess: ${_userGuess.round()}% | True posterior: ${truePosterior.toStringAsFixed(1)}%',
                              style: inter(fontSize: 12, color: const Color(0xFFD1D5DB)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Natural frequency breakdown
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 14,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: S.borderMd,
                          border: Border.all(color: C.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('THE BREAKDOWN', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                            const SizedBox(height: 10),
                            Text(
                              'Out of 1,000 people:\n• ${stats.hasDisease} have the condition\n  → ${stats.truePositive} test positive (TP)\n• ${stats.doesntHaveDisease} do NOT have it\n  → ${stats.falsePositive} test false positive (FP)\n\nOut of ${stats.truePositive + stats.falsePositive} positive tests, only ${stats.truePositive} truly have it:\n${stats.truePositive} / ${stats.truePositive + stats.falsePositive} = ${truePosterior.toStringAsFixed(1)}%',
                              style: inter(fontSize: 12, color: const Color(0xFFD1D5DB)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  FadeSlideIn(
                    delay: _submitted ? const Duration(milliseconds: 250) : Duration.zero,
                    duration: const Duration(milliseconds: 350),
                    slideDistance: 10,
                    child: Builder(builder: (_) {
                      if (!_submitted) {
                        return PrimaryBtn(label: 'SUBMIT GUESS', onPressed: _handleSubmit);
                      } else if (_currentScenario < 2) {
                        return PrimaryBtn(label: 'NEXT SCENARIO', onPressed: _handleNext);
                      } else {
                        return PrimaryBtn(label: 'SEE RESULTS', onPressed: () => setState(() {}));
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: S.headerPad,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: C.surface2, borderRadius: S.borderSm),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _passed ? C.green.withValues(alpha: 0.1) : C.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _passed ? C.green.withValues(alpha: 0.25) : C.yellow.withValues(alpha: 0.25)),
                          ),
                          child: Text(_passed ? 'PASSED' : 'TRY AGAIN', style: spaceGrotesk(fontSize: 12, color: _passed ? C.green : C.yellow)),
                        ),
                        const SizedBox(height: 4),
                        Text('Challenge Complete',
                          style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 450),
                    slideDistance: 16,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _passed ? C.green.withValues(alpha: 0.1) : C.yellow.withValues(alpha: 0.08),
                        borderRadius: S.borderMd,
                        border: Border.all(color: _passed ? C.green.withValues(alpha: 0.3) : C.yellow.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _passed ? 'You correctly estimated $_correctCount / 3 posteriors!' : 'You got $_correctCount / 3 correct.',
                            style: spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _passed ? C.green : C.yellow,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _passed
                                ? 'Bayesian reasoning is now part of your intuition. You understand how base rates dominate inference.'
                                : 'The base rate is often counterintuitive — try the scenarios again to build your intuition.',
                            style: inter(fontSize: 13, color: const Color(0xFFD1D5DB)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Results', style: spaceGrotesk(fontSize: 14, color: C.muted)),
                        const SizedBox(height: 10),
                        for (int i = 0; i < _results.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  _results[i] ? Icons.check_circle : Icons.cancel,
                                  size: 16,
                                  color: _results[i] ? C.green : C.pink,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _scenarios[i]['name'] as String,
                                  style: inter(fontSize: 13, color: _results[i] ? C.txt : C.muted),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 250),
                    duration: const Duration(milliseconds: 350),
                    slideDistance: 10,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => widget.onComplete(_passed, _correctCount, 3),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _passed ? C.green : C.accent,
                          foregroundColor: _passed ? C.bg : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: S.borderMd),
                          elevation: 0,
                        ),
                        child: Text('See results', style: spaceGrotesk(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: _passed ? C.bg : Colors.white, letterSpacing: 0.05,
                        )),
                      ),
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
