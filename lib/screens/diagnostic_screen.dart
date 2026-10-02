import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class _Question {
  final int id;
  final String prompt;
  final List<String> options;
  final int correct;
  final String hint;
  const _Question({required this.id, required this.prompt, required this.options, required this.correct, required this.hint});
}

const _scoring = {
  1: {'skill': 'Optimization', 'points': 25},
  2: {'skill': 'Calculus', 'points': 25},
  3: {'skill': 'Optimization', 'points': 20},
};

const _questions = [
  _Question(
    id: 1,
    prompt: 'If this curve represents loss, which point is closer to the minimum?',
    options: ['Point A', 'Point B'],
    correct: 1,
    hint: 'The minimum is the lowest point on the curve.',
  ),
  _Question(
    id: 2,
    prompt: 'Which describes the gradient at the minimum of a smooth curve?',
    options: ['Gradient = 0', 'Gradient = 1'],
    correct: 0,
    hint: 'At the minimum, the slope (gradient) is flat — zero.',
  ),
  _Question(
    id: 3,
    prompt: 'A larger step size means…',
    options: ['Bigger update per step', 'Smaller update per step'],
    correct: 0,
    hint: 'The learning rate η controls how big each step is.',
  ),
];

class DiagnosticScreen extends StatefulWidget {
  final ValueChanged<Map<String, int>> onNext;
  final VoidCallback onBack;
  const DiagnosticScreen({super.key, required this.onNext, required this.onBack});
  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  int _qi = 0;
  final Map<int, int> _answers = {};
  bool _showHint = false;

  _Question get _q => _questions[_qi];
  bool get _answered => _answers.containsKey(_q.id);
  bool get _isLast => _qi == _questions.length - 1;

  void _answer(int idx) {
    if (_answered) return;
    setState(() {
      _answers[_q.id] = idx;
      _showHint = idx != _q.correct;
    });
  }

  Map<String, int> _computeScores() {
    final scores = {'Optimization': 0, 'Calculus': 0};
    for (final q in _questions) {
      if (_answers[q.id] == q.correct) {
        final rule = _scoring[q.id]!;
        final skill = rule['skill'] as String;
        scores[skill] = (scores[skill] ?? 0) + (rule['points'] as int);
      }
    }
    return scores;
  }

  void _advance() {
    setState(() => _showHint = false);
    if (_isLast) {
      widget.onNext(_computeScores());
      return;
    }
    setState(() => _qi++);
  }

  void _goBack() {
    setState(() => _showHint = false);
    if (_qi > 0) {
      setState(() => _qi--);
      return;
    }
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Diagnostic', onBack: _goBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ProgressPill(current: _qi + 1, total: _questions.length),
                      Text('${_qi + 1} / ${_questions.length}', style: mono(fontSize: 12, color: C.muted)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(_q.prompt, style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 24),
                  // Visual placeholder for Q1
                  if (_q.id == 1)
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: CustomPaint(painter: _DiagCurvePainter(selected: _answers[_q.id]), size: const Size(double.infinity, 140)),
                    ),
                  if (_q.id == 2)
                    Container(
                      height: 80,
                      alignment: Alignment.center,
                      child: CustomPaint(painter: _ValleyPainter(), size: const Size(200, 80)),
                    ),
                  if (_q.id == 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stepSizeCircle('Small η', 12, C.accent),
                        const SizedBox(width: 24),
                        _stepSizeCircle('Large η', 48, C.blue),
                      ],
                    ),
                  const SizedBox(height: 24),
                  for (int idx = 0; idx < _q.options.length; idx++) ...[
                    _optionButton(idx),
                    const SizedBox(height: 12),
                  ],
                  if (_showHint)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: C.yellow.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.yellow.withValues(alpha: 0.25)),
                      ),
                      child: Text(_q.hint, style: inter(fontSize: 14, color: C.yellow)),
                    ),
                  const Spacer(),
                  PrimaryBtn(
                    label: _isLast ? 'SEE YOUR MAP' : 'NEXT',
                    onPressed: _advance,
                    disabled: !_answered,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionButton(int idx) {
    final isSelected = _answers[_q.id] == idx;
    final isCorrect = idx == _q.correct;
    Color bg = C.surface2.withValues(alpha: 0.6);
    Color border = Colors.white.withValues(alpha: 0.08);
    Color textColor = C.txt;

    if (_answered) {
      if (isCorrect) {
        bg = C.green.withValues(alpha: 0.1);
        border = C.green.withValues(alpha: 0.35);
        textColor = C.green;
      } else if (isSelected) {
        bg = C.pink.withValues(alpha: 0.1);
        border = C.pink.withValues(alpha: 0.35);
        textColor = C.pink;
      }
    } else if (isSelected) {
      bg = C.accent.withValues(alpha: 0.1);
      border = C.accent;
    }

    return GestureDetector(
      onTap: () => _answer(idx),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(_q.options[idx], style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
      ),
    );
  }

  Widget _stepSizeCircle(String label, double size, Color color) {
    return Column(
      children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 8),
        Text(label, style: inter(fontSize: 11, color: C.muted)),
      ],
    );
  }
}

class _DiagCurvePainter extends CustomPainter {
  final int? selected;
  _DiagCurvePainter({this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(10, size.height - 10)
      ..quadraticBezierTo(size.width * 0.2, 10, size.width * 0.5, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.7, size.height + 20, size.width - 10, 20);
    canvas.drawPath(path, Paint()..color = C.accent..strokeWidth = 2..style = PaintingStyle.stroke);

    // Point A (high)
    final aColor = selected == 0 ? (0 == 1 ? C.green : C.pink) : C.accent;
    canvas.drawCircle(Offset(size.width * 0.25, 35), 8, Paint()..color = aColor);
    final atp = TextPainter(text: TextSpan(text: 'A', style: spaceGrotesk(fontSize: 11, color: C.txt)), textDirection: TextDirection.ltr)..layout();
    atp.paint(canvas, Offset(size.width * 0.25 - 4, 12));

    // Point B (low)
    final bColor = selected == 1 ? (1 == 1 ? C.green : C.pink) : C.accent;
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.68), 8, Paint()..color = bColor);
    final btp = TextPainter(text: TextSpan(text: 'B', style: spaceGrotesk(fontSize: 11, color: C.txt)), textDirection: TextDirection.ltr)..layout();
    btp.paint(canvas, Offset(size.width * 0.65 - 4, size.height * 0.68 - 20));
  }

  @override
  bool shouldRepaint(covariant _DiagCurvePainter old) => selected != old.selected;
}

class _ValleyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(10, 15)
      ..quadraticBezierTo(size.width / 2, 70, size.width - 10, 15);
    canvas.drawPath(path, Paint()..color = C.accent..strokeWidth = 2..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(size.width / 2, 43), 5, Paint()..color = C.blue);
    final tp = TextPainter(text: TextSpan(text: '?', style: mono(fontSize: 9, color: C.blue)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(size.width / 2 + 8, 38));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
