import 'package:flutter/material.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';

class _Question {
  final String prompt;
  final List<String> options;
  final IconData icon;
  const _Question({required this.prompt, required this.options, required this.icon});
}

const _questions = [
  _Question(
    prompt: 'Which explanation clicks for you?',
    options: [
      'It’s like rolling a ball downhill to find the lowest valley',
      'The algorithm reduces error by adjusting values step by step',
      'Parameters are iteratively updated via the negative gradient of the loss',
    ],
    icon: Icons.lightbulb_outline,
  ),
  _Question(
    prompt: 'Pick the version that feels easiest to read:',
    options: [
      'The learning speed controls how big each step is',
      'Learning rate controls the size of each parameter update',
      'α scales the gradient: θ ← θ − α∇L(θ)',
    ],
    icon: Icons.menu_book_outlined,
  ),
  _Question(
    prompt: 'How would you find the best price for a product?',
    options: [
      'Try a bunch of prices and see which one sells best',
      'Plot sales vs price and look for the sweet spot',
      'Model demand as f(p) and optimize revenue = p · f(p)',
    ],
    icon: Icons.psychology_outlined,
  ),
];

class DiagnosticScreen extends StatefulWidget {
  final ValueChanged<ComprehensionLevel> onNext;
  final VoidCallback onBack;
  const DiagnosticScreen({super.key, required this.onNext, required this.onBack});
  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  int _qi = 0;
  final Map<int, int> _answers = {};

  _Question get _q => _questions[_qi];
  bool get _answered => _answers.containsKey(_qi);
  bool get _isLast => _qi == _questions.length - 1;

  void _select(int idx) {
    setState(() => _answers[_qi] = idx);
  }

  ComprehensionLevel _computeLevel() {
    int total = 0;
    for (int i = 0; i < _questions.length; i++) {
      total += _answers[i] ?? 0;
    }
    if (total >= 5) return ComprehensionLevel.advanced;
    if (total >= 3) return ComprehensionLevel.intermediate;
    return ComprehensionLevel.beginner;
  }

  void _advance() {
    if (_isLast) {
      widget.onNext(_computeLevel());
      return;
    }
    setState(() => _qi++);
  }

  void _goBack() {
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
          MLabHeader(label: 'About You', onBack: _goBack),
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
                  const SizedBox(height: 16),
                  if (_qi == 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: C.accent.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: C.accent.withValues(alpha: 0.18)),
                        ),
                        child: Text(
                          'No wrong answers — this helps us speak your language.',
                          style: inter(fontSize: 13, color: C.accent),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Icon(_q.icon, size: 22, color: C.muted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_q.prompt, style: spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  for (int idx = 0; idx < _q.options.length; idx++) ...[
                    _optionButton(idx),
                    const SizedBox(height: 12),
                  ],
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
    final isSelected = _answers[_qi] == idx;
    Color bgColor = C.surface2.withValues(alpha: 0.6);
    Color border = Colors.white.withValues(alpha: 0.08);
    Color textColor = C.txt;

    if (isSelected) {
      bgColor = C.accent.withValues(alpha: 0.1);
      border = C.accent;
      textColor = C.accent;
    }

    return GestureDetector(
      onTap: () => _select(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(_q.options[idx], style: inter(fontSize: 14, fontWeight: FontWeight.w400, color: textColor)),
      ),
    );
  }
}
