import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class _QuizQ {
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;
  const _QuizQ({required this.question, required this.options, required this.correct, required this.explanation});
}

const _terms = [
  {'sym': 'θ', 'color': 0xFF38BDF8, 'label': 'Position', 'desc': 'Your current position on the loss curve — the parameter being optimized.'},
  {'sym': 'η', 'color': 0xFFFBBF24, 'label': 'Learning rate', 'desc': 'Controls step size. Small η = cautious. Large η = aggressive.'},
  {'sym': '∇J(θ)', 'color': 0xFFFB7185, 'label': 'Gradient', 'desc': 'Slope of the loss curve at θ — points uphill, toward higher loss.'},
  {'sym': '−', 'color': 0xFF4ADE80, 'label': 'Minus sign', 'desc': 'We subtract because the gradient points uphill. Subtracting moves us downhill.'},
];

const _quizzes = [
  _QuizQ(
    question: 'What does θ represent?',
    options: ['The loss value', 'Your current position (parameter)', 'The learning rate', 'The gradient'],
    correct: 1,
    explanation: 'θ is the parameter being optimized — your position on the curve.',
  ),
  _QuizQ(
    question: 'When η is very large, what happens?',
    options: ['Convergence speeds up', 'The ball overshoots the minimum', 'Nothing changes', 'Loss always decreases'],
    correct: 1,
    explanation: 'Large η means large steps — you jump past the minimum (overshoot).',
  ),
  _QuizQ(
    question: 'The gradient ∇J(θ) points in which direction?',
    options: ['Toward the minimum', 'Uphill — toward higher loss', 'Always left', 'Randomly'],
    correct: 1,
    explanation: 'The gradient points toward steepest ascent (uphill). We go the opposite way.',
  ),
  _QuizQ(
    question: 'Why do we SUBTRACT the gradient?',
    options: ['It\'s just convention', 'To move toward higher loss', 'Because the gradient points uphill, so subtracting goes downhill', 'To make the step smaller'],
    correct: 2,
    explanation: 'The gradient points uphill. Subtracting it moves us downhill — toward lower loss.',
  ),
];

class GDExplainScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDExplainScreen({super.key, required this.onNext, required this.onBack});
  @override
  State<GDExplainScreen> createState() => _GDExplainScreenState();
}

class _GDExplainScreenState extends State<GDExplainScreen> {
  int _revealedTerms = 0;
  int _quizIdx = 0;
  int _correctCount = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _quizDone = false;
  String? _highlighted;

  bool get _allRevealed => _revealedTerms >= _terms.length;
  bool get _canProceed => _quizDone && _correctCount >= 3;

  void _revealNext() {
    if (_revealedTerms < _terms.length) {
      setState(() {
        _highlighted = _terms[_revealedTerms]['sym'] as String;
        _revealedTerms++;
      });
    }
  }

  void _selectAnswer(int idx) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = idx;
      _answered = true;
      if (idx == _quizzes[_quizIdx].correct) _correctCount++;
    });
  }

  void _nextQuiz() {
    if (_quizIdx < _quizzes.length - 1) {
      setState(() {
        _quizIdx++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() => _quizDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: C.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: C.green.withValues(alpha: 0.25)),
                        ),
                        child: Text('EXPLAIN', style: spaceGrotesk(fontSize: 11, color: C.green)),
                      ),
                    ],
                  )),
                  if (!_allRevealed)
                    ProgressPill(current: _revealedTerms, total: _terms.length)
                  else if (!_quizDone)
                    ProgressPill(current: _quizIdx + (_answered ? 1 : 0), total: _quizzes.length),
                ],
              ),
            ),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You just performed\nGradient Descent.',
                  style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                const SizedBox(height: 8),
                Text('Each step followed one simple rule:',
                  style: inter(fontSize: 14, color: const Color(0xFFD1D5DB))),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(children: [
                    Text('THE UPDATE RULE', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                    const SizedBox(height: 16),
                    _equation(),
                    const SizedBox(height: 12),
                    if (!_allRevealed)
                      Text('Tap each symbol to learn what it means.', style: inter(fontSize: 12, color: C.muted))
                    else
                      Text('Tap any symbol to review.', style: inter(fontSize: 12, color: C.muted)),
                  ]),
                ),
                const SizedBox(height: 16),

                for (int i = 0; i < _terms.length; i++) ...[
                  if (i < _revealedTerms) ...[
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 400),
                      slideDistance: 14,
                      child: _termCard(_terms[i]),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],

                if (!_allRevealed) ...[
                  const SizedBox(height: 8),
                  PrimaryBtn(label: 'Reveal next symbol', onPressed: _revealNext),
                ],

                if (_allRevealed && !_quizDone) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.accent.withValues(alpha: 0.06),
                      borderRadius: S.borderSm,
                      border: Border.all(color: C.accent.withValues(alpha: 0.15)),
                    ),
                    child: Text('CHECK YOUR UNDERSTANDING  ($_correctCount/${_quizIdx + (_answered ? 1 : 0)} correct)',
                      style: spaceGrotesk(fontSize: 11, color: C.accent, letterSpacing: 0.08)),
                  ),
                  const SizedBox(height: 16),
                  Text(_quizzes[_quizIdx].question,
                    style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  for (int i = 0; i < _quizzes[_quizIdx].options.length; i++) ...[
                    _quizOption(i, _quizzes[_quizIdx]),
                    const SizedBox(height: 8),
                  ],

                  if (_answered) ...[
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 12,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (_selectedAnswer == _quizzes[_quizIdx].correct ? C.green : C.yellow).withValues(alpha: 0.08),
                          borderRadius: S.borderMd,
                          border: Border.all(
                            color: (_selectedAnswer == _quizzes[_quizIdx].correct ? C.green : C.yellow).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          _selectedAnswer == _quizzes[_quizIdx].correct
                              ? 'Correct!'
                              : _quizzes[_quizIdx].explanation,
                          style: inter(fontSize: 14,
                            color: _selectedAnswer == _quizzes[_quizIdx].correct ? C.green : C.yellow),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 350),
                      slideDistance: 10,
                      child: PrimaryBtn(
                        label: _quizIdx < _quizzes.length - 1 ? 'Next question' : 'See results',
                        onPressed: _nextQuiz,
                      ),
                    ),
                  ],
                ],

                if (_quizDone) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (_canProceed ? C.green : C.yellow).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (_canProceed ? C.green : C.yellow).withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_canProceed ? 'Ready for the challenge!' : 'Almost there',
                          style: spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600,
                            color: _canProceed ? C.green : C.yellow)),
                        const SizedBox(height: 8),
                        Text('$_correctCount / ${_quizzes.length} correct',
                          style: mono(fontSize: 14, color: _canProceed ? C.green : C.yellow)),
                        if (!_canProceed) ...[
                          const SizedBox(height: 8),
                          Text('You need 3 correct to proceed. Review the symbols above and try again.',
                            style: inter(fontSize: 13, color: C.muted)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_canProceed)
                    PrimaryBtn(label: 'TAKE THE CHALLENGE', onPressed: widget.onNext)
                  else
                    PrimaryBtn(label: 'Review & retry', onPressed: () {
                      setState(() {
                        _quizIdx = 0;
                        _correctCount = 0;
                        _selectedAnswer = null;
                        _answered = false;
                        _quizDone = false;
                      });
                    }),
                ],
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _equation() {
    final parts = [
      {'text': 'θ', 'term': 'θ', 'sub': 'new', 'revealed': true},
      {'text': ' = ', 'term': null, 'revealed': true},
      {'text': 'θ', 'term': 'θ', 'sub': 'old', 'revealed': true},
      {'text': ' − ', 'term': '−', 'revealed': _revealedTerms >= 4},
      {'text': 'η', 'term': 'η', 'revealed': _revealedTerms >= 2},
      {'text': '∇J(θ)', 'term': '∇J(θ)', 'revealed': _revealedTerms >= 3},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        final term = part['term'] as String?;
        final revealed = part['revealed'] as bool;
        final termData = term != null
            ? _terms.cast<Map<String, Object>?>().firstWhere(
                (t) => t != null && t['sym'] == term, orElse: () => null)
            : null;
        final isHl = term == _highlighted;
        final color = !revealed
            ? C.surface3
            : termData != null
                ? Color(termData['color'] as int).withValues(alpha: isHl ? 1 : 0.65)
                : C.txt.withValues(alpha: 0.5);

        return GestureDetector(
          onTap: revealed && term != null ? () => setState(() => _highlighted = _highlighted == term ? null : term) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isHl && termData != null ? Color(termData['color'] as int).withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: RichText(
              text: TextSpan(
                text: revealed ? part['text'] as String : '?',
                style: mono(fontSize: term != null ? 26 : 22, fontWeight: FontWeight.w500, color: color),
                children: part.containsKey('sub') && revealed
                    ? [TextSpan(text: part['sub'] as String, style: mono(fontSize: 11, color: color.withValues(alpha: 0.7)))]
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _termCard(Map<String, dynamic> term) {
    final isHl = _highlighted == term['sym'];
    final color = Color(term['color'] as int);
    return GestureDetector(
      onTap: () => setState(() => _highlighted = _highlighted == term['sym'] ? null : term['sym'] as String?),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHl ? color.withValues(alpha: 0.06) : C.surface,
          borderRadius: S.borderMd,
          border: Border.all(color: isHl ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: S.borderSm),
            alignment: Alignment.center,
            child: Text(term['sym'] as String, style: mono(fontSize: 15, color: color)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(term['label'] as String, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(term['desc'] as String, style: inter(fontSize: 12, color: C.muted)),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _quizOption(int idx, _QuizQ q) {
    final selected = _selectedAnswer == idx;
    final isCorrect = idx == q.correct;
    Color borderColor = C.border;
    Color bgColor = C.surface;

    if (_answered) {
      if (isCorrect) {
        borderColor = C.green.withValues(alpha: 0.3);
        bgColor = C.green.withValues(alpha: 0.06);
      } else if (selected) {
        borderColor = C.pink.withValues(alpha: 0.3);
        bgColor = C.pink.withValues(alpha: 0.06);
      }
    } else if (selected) {
      borderColor = C.accent.withValues(alpha: 0.3);
      bgColor = C.accent.withValues(alpha: 0.06);
    }

    return GestureDetector(
      onTap: () => _selectAnswer(idx),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: S.borderMd,
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _answered && isCorrect ? C.green.withValues(alpha: 0.15) :
                     _answered && selected ? C.pink.withValues(alpha: 0.15) : C.surface2,
            ),
            alignment: Alignment.center,
            child: _answered
                ? Icon(isCorrect ? Icons.check : selected ? Icons.close : null,
                    size: 14, color: isCorrect ? C.green : C.pink)
                : Text(String.fromCharCode(65 + idx), style: mono(fontSize: 11, color: C.muted)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(q.options[idx], style: inter(fontSize: 14, color: C.txt))),
        ]),
      ),
    );
  }
}
