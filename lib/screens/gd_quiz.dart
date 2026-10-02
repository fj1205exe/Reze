import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class _QuizQ {
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;
  const _QuizQ({
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
  });
}

const _quizzes = [
  _QuizQ(
    question: 'What does θ represent?',
    options: [
      'The loss value',
      'Your current position (parameter)',
      'The learning rate',
      'The gradient'
    ],
    correct: 1,
    explanation:
        'θ is the parameter being optimized — your position on the curve.',
  ),
  _QuizQ(
    question: 'When η is very large, what happens?',
    options: [
      'Convergence speeds up',
      'The ball overshoots the minimum',
      'Nothing changes',
      'Loss always decreases'
    ],
    correct: 1,
    explanation:
        'Large η means large steps — you jump past the minimum (overshoot).',
  ),
  _QuizQ(
    question: 'The gradient ∇J(θ) points in which direction?',
    options: [
      'Toward the minimum',
      'Uphill — toward higher loss',
      'Always left',
      'Randomly'
    ],
    correct: 1,
    explanation:
        'The gradient points toward steepest ascent (uphill). We go the opposite way.',
  ),
  _QuizQ(
    question: 'Why do we SUBTRACT the gradient?',
    options: [
      'It\'s just convention',
      'To move toward higher loss',
      'Because the gradient points uphill, so subtracting goes downhill',
      'To make the step smaller'
    ],
    correct: 2,
    explanation:
        'The gradient points uphill. Subtracting it moves us downhill — toward lower loss.',
  ),
];

class GDQuizScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDQuizScreen(
      {super.key, required this.onNext, required this.onBack});
  @override
  State<GDQuizScreen> createState() => _GDQuizScreenState();
}

class _GDQuizScreenState extends State<GDQuizScreen> {
  int _quizIdx = 0;
  int _correctCount = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _quizDone = false;

  bool get _canProceed => _quizDone && _correctCount >= 3;

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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: C.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: C.muted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: C.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: C.accent.withValues(alpha: 0.25)),
                        ),
                        child: Text('QUIZ',
                            style: spaceGrotesk(
                                fontSize: 11, color: C.accent)),
                      ),
                    ],
                  )),
                  if (!_quizDone)
                    ProgressPill(
                      current: _quizIdx + (_answered ? 1 : 0),
                      total: _quizzes.length,
                    ),
                ],
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_quizDone) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(children: [
                      Text('THE UPDATE RULE',
                          style: spaceGrotesk(
                              fontSize: 10,
                              color: C.muted,
                              letterSpacing: 0.12)),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'θ',
                              style: mono(
                                  fontSize: 22, color: C.blue)),
                          TextSpan(
                              text: 'new',
                              style: mono(
                                  fontSize: 10,
                                  color: C.blue
                                      .withValues(alpha: 0.7))),
                          TextSpan(
                              text: ' = ',
                              style: mono(
                                  fontSize: 20,
                                  color:
                                      C.txt.withValues(alpha: 0.5))),
                          TextSpan(
                              text: 'θ',
                              style: mono(
                                  fontSize: 22, color: C.blue)),
                          TextSpan(
                              text: 'old',
                              style: mono(
                                  fontSize: 10,
                                  color: C.blue
                                      .withValues(alpha: 0.7))),
                          TextSpan(
                              text: ' − ',
                              style: mono(
                                  fontSize: 20, color: C.green)),
                          TextSpan(
                              text: 'η',
                              style: mono(
                                  fontSize: 22, color: C.yellow)),
                          TextSpan(
                              text: '∇J(θ)',
                              style: mono(
                                  fontSize: 22, color: C.pink)),
                        ]),
                      ),
                    ]),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: C.accent.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                        'Question ${_quizIdx + 1} of ${_quizzes.length}  ·  $_correctCount correct',
                        style: spaceGrotesk(
                            fontSize: 11,
                            color: C.accent,
                            letterSpacing: 0.08)),
                  ),
                  const SizedBox(height: 16),
                  Text(_quizzes[_quizIdx].question,
                      style: spaceGrotesk(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  for (int i = 0;
                      i < _quizzes[_quizIdx].options.length;
                      i++) ...[
                    _quizOption(i, _quizzes[_quizIdx]),
                    const SizedBox(height: 8),
                  ],
                  if (_answered) ...[
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (_selectedAnswer ==
                                      _quizzes[_quizIdx].correct
                                  ? C.green
                                  : C.yellow)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (_selectedAnswer ==
                                        _quizzes[_quizIdx].correct
                                    ? C.green
                                    : C.yellow)
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          _selectedAnswer == _quizzes[_quizIdx].correct
                              ? 'Correct!'
                              : _quizzes[_quizIdx].explanation,
                          style: inter(
                              fontSize: 14,
                              color: _selectedAnswer ==
                                      _quizzes[_quizIdx].correct
                                  ? C.green
                                  : C.yellow),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryBtn(
                      label: _quizIdx < _quizzes.length - 1
                          ? 'Next question'
                          : 'See results',
                      onPressed: _nextQuiz,
                    ),
                  ],
                ],
                if (_quizDone) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (_canProceed ? C.green : C.yellow)
                          .withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: (_canProceed ? C.green : C.yellow)
                              .withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _canProceed
                                ? 'Ready for the challenge!'
                                : 'Almost there',
                            style: spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    _canProceed ? C.green : C.yellow)),
                        const SizedBox(height: 8),
                        Text(
                            '$_correctCount / ${_quizzes.length} correct',
                            style: mono(
                                fontSize: 14,
                                color:
                                    _canProceed ? C.green : C.yellow)),
                        if (!_canProceed) ...[
                          const SizedBox(height: 8),
                          Text(
                              'You need 3 correct to proceed. Review the equation and try again.',
                              style:
                                  inter(fontSize: 13, color: C.muted)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_canProceed)
                    PrimaryBtn(
                        label: 'START WARM-UP →',
                        onPressed: widget.onNext)
                  else
                    PrimaryBtn(
                        label: 'Review & retry',
                        onPressed: () {
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

  Widget _quizOption(int idx, _QuizQ q) {
    final selected = _selectedAnswer == idx;
    final isCorrect = idx == q.correct;
    Color borderColor = Colors.white.withValues(alpha: 0.06);
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _answered && isCorrect
                  ? C.green.withValues(alpha: 0.15)
                  : _answered && selected
                      ? C.pink.withValues(alpha: 0.15)
                      : C.surface2,
            ),
            alignment: Alignment.center,
            child: _answered
                ? Icon(
                    isCorrect
                        ? Icons.check
                        : selected
                            ? Icons.close
                            : null,
                    size: 14,
                    color: isCorrect ? C.green : C.pink)
                : Text(String.fromCharCode(65 + idx),
                    style: mono(fontSize: 11, color: C.muted)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(q.options[idx],
                  style: inter(fontSize: 14, color: C.txt))),
        ]),
      ),
    );
  }
}
