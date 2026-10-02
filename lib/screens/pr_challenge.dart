import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/probability.dart' as pr_utils;

class PRChallengeScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PRChallengeScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PRChallengeScreen> createState() => _PRChallengeScreenState();
}

class _PRChallengeScreenState extends State<PRChallengeScreen> {
  static final _rng = Random();

  late List<double> _hiddenPs;
  late List<List<String>> _flipsPerRound;
  int _round = 0;
  double? _guess;
  bool _guessSubmitted = false;
  int _correctGuesses = 0;
  bool _gameFinished = false;

  @override
  void initState() {
    super.initState();
    _hiddenPs = List.generate(3, (_) {
      final raw = 0.2 + _rng.nextInt(13) * 0.05; // 0.20 to 0.80 in 0.05 steps
      return (raw * 20).round() / 20.0; // round to nearest 0.05
    });
    _flipsPerRound = _hiddenPs.map((p) {
      return List.generate(20, (_) => pr_utils.flip(p));
    }).toList();
  }

  bool get _isCorrect {
    if (_guess == null) return false;
    return (_guess! - _hiddenPs[_round]).abs() <= 0.15;
  }

  int get _roundHeads => _flipsPerRound[_round].where((f) => f == 'H').length;
  int get _roundTails => 20 - _roundHeads;

  void _submitGuess() {
    if (_guess == null) return;
    setState(() {
      _guessSubmitted = true;
      if (_isCorrect) _correctGuesses++;
    });
  }

  void _nextRound() {
    if (_round >= 2) {
      setState(() => _gameFinished = true);
      return;
    }
    setState(() {
      _round++;
      _guess = null;
      _guessSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentFlips = _flipsPerRound[_round];

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
                        Text("Guess the coin's bias.",
                          style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  ProgressPill(current: _round + 1, total: 3),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Score: ', style: inter(fontSize: 13, color: C.muted)),
                        Text('$_correctGuesses/3 correct', style: mono(fontSize: 13, color: _correctGuesses >= 2 ? C.green : C.txt)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Round label
                  Text('Round ${_round + 1} of 3', style: spaceGrotesk(fontSize: 14, color: C.muted)),
                  const SizedBox(height: 4),
                  Text('20 flips from a mystery coin:', style: inter(fontSize: 14, color: const Color(0xFFD1D5DB))),
                  const SizedBox(height: 12),

                  // Flip grid
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: currentFlips.map((f) {
                            final isH = f == 'H';
                            return Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isH ? C.accent.withValues(alpha: 0.2) : C.blue.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: isH ? C.accent : C.blue),
                              ),
                              child: Text(
                                f,
                                style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: isH ? C.accentLight : C.blue),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$_roundHeads H', style: mono(fontSize: 13, color: C.accentLight)),
                            Text(' / ', style: mono(fontSize: 13, color: C.muted)),
                            Text('$_roundTails T', style: mono(fontSize: 13, color: C.blue)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!_guessSubmitted) ...[
                    // Guess slider
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
                              Text('Your estimate of P(H)', style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(
                                _guess != null ? _guess!.toStringAsFixed(2) : '---',
                                style: mono(fontSize: 14, color: C.accent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0.0', style: inter(fontSize: 11, color: C.muted)),
                              Text('1.0', style: inter(fontSize: 11, color: C.muted)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: C.accent,
                              inactiveTrackColor: C.surface3,
                              thumbColor: C.accent,
                              overlayColor: C.accent.withValues(alpha: 0.15),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            ),
                            child: Slider(
                              value: _guess ?? 0.5,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (v) => setState(() => _guess = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryBtn(
                      label: 'Submit Guess',
                      disabled: _guess == null,
                      onPressed: _guess != null ? _submitGuess : null,
                    ),
                  ] else if (!_gameFinished) ...[
                    // Reveal
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCorrect ? C.green.withValues(alpha: 0.1) : C.pink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isCorrect ? C.green.withValues(alpha: 0.3) : C.pink.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCorrect ? 'Correct!' : 'Not quite.',
                            style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: _isCorrect ? C.green : C.pink),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Your guess:', style: inter(fontSize: 13, color: C.muted)),
                              Text(_guess!.toStringAsFixed(2), style: mono(fontSize: 14, color: C.txt)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('True bias:', style: inter(fontSize: 13, color: C.muted)),
                              Text(_hiddenPs[_round].toStringAsFixed(2), style: mono(fontSize: 14, color: C.accent)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Difference:', style: inter(fontSize: 13, color: C.muted)),
                              Text(
                                '${(_guess! - _hiddenPs[_round]).abs().toStringAsFixed(2)} (need < 0.15)',
                                style: mono(fontSize: 12, color: _isCorrect ? C.green : C.pink),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryBtn(
                      label: _round < 2 ? 'Next Round' : 'See Results',
                      onPressed: _round < 2 ? _nextRound : () {
                        _gameFinished = true;
                        widget.onNext();
                      },
                    ),
                  ] else ...[
                    // Game finished
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _correctGuesses >= 2 ? C.green.withValues(alpha: 0.1) : C.pink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _correctGuesses >= 2 ? C.green.withValues(alpha: 0.3) : C.pink.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _correctGuesses >= 2 ? 'Challenge passed!' : 'Challenge missed.',
                            style: spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: _correctGuesses >= 2 ? C.green : C.pink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_correctGuesses/3 rounds correct',
                            style: inter(fontSize: 14, color: C.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryBtn(label: 'See results', onPressed: widget.onNext),
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
