import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

const _terms = [
  {
    'sym': 'θ',
    'color': 0xFF38BDF8,
    'label': 'Position',
    'desc':
        'Your current position on the loss curve — the parameter being optimized.'
  },
  {
    'sym': 'η',
    'color': 0xFFFBBF24,
    'label': 'Learning rate',
    'desc': 'Controls step size. Small η = cautious. Large η = aggressive.'
  },
  {
    'sym': '∇J(θ)',
    'color': 0xFFFB7185,
    'label': 'Gradient',
    'desc':
        'Slope of the loss curve at θ — points uphill, toward higher loss.'
  },
  {
    'sym': '−',
    'color': 0xFF4ADE80,
    'label': 'Minus sign',
    'desc':
        'We subtract because the gradient points uphill. Subtracting moves us downhill.'
  },
];

class GDEquationScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const GDEquationScreen(
      {super.key, required this.onNext, required this.onBack});
  @override
  State<GDEquationScreen> createState() => _GDEquationScreenState();
}

class _GDEquationScreenState extends State<GDEquationScreen> {
  int _revealedTerms = 0;
  String? _highlighted;

  bool get _allRevealed => _revealedTerms >= _terms.length;

  void _revealNext() {
    if (_revealedTerms < _terms.length) {
      setState(() {
        _highlighted = _terms[_revealedTerms]['sym'] as String;
        _revealedTerms++;
      });
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
                          color: C.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: C.green.withValues(alpha: 0.25)),
                        ),
                        child: Text('THE MATH',
                            style: spaceGrotesk(
                                fontSize: 11, color: C.green)),
                      ),
                    ],
                  )),
                  ProgressPill(
                      current: _revealedTerms, total: _terms.length),
                ],
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You just performed\nGradient Descent.',
                    style: spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.01)),
                const SizedBox(height: 8),
                Text('Each step followed one simple rule:',
                    style: inter(
                        fontSize: 14,
                        color: const Color(0xFFD1D5DB))),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 16),
                    _equation(),
                    const SizedBox(height: 12),
                    Text(
                        !_allRevealed
                            ? 'Tap below to reveal each symbol.'
                            : 'Tap any symbol to review.',
                        style: inter(fontSize: 12, color: C.muted)),
                  ]),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < _terms.length; i++) ...[
                  if (i < _revealedTerms) ...[
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: _termCard(_terms[i]),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
                if (!_allRevealed) ...[
                  const SizedBox(height: 8),
                  PrimaryBtn(
                      label: 'Reveal next symbol',
                      onPressed: _revealNext),
                ],
                if (_allRevealed) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: C.accent.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                        'Now that you understand each piece, let\'s test your understanding.',
                        style: inter(
                            fontSize: 14,
                            color: C.txt,
                            height: 1.5)),
                  ),
                  const SizedBox(height: 16),
                  PrimaryBtn(
                      label: 'Take the quiz →', onPressed: widget.onNext),
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
      {
        'text': '∇J(θ)',
        'term': '∇J(θ)',
        'revealed': _revealedTerms >= 3
      },
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        final term = part['term'] as String?;
        final revealed = part['revealed'] as bool;
        final termData = term != null
            ? _terms.cast<Map<String, Object>?>().firstWhere(
                (t) => t != null && t['sym'] == term,
                orElse: () => null)
            : null;
        final isHl = term == _highlighted;
        final color = !revealed
            ? C.surface3
            : termData != null
                ? Color(termData['color'] as int)
                    .withValues(alpha: isHl ? 1 : 0.65)
                : C.txt.withValues(alpha: 0.5);

        return GestureDetector(
          onTap: revealed && term != null
              ? () => setState(
                  () => _highlighted = _highlighted == term ? null : term)
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isHl && termData != null
                  ? Color(termData['color'] as int).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: RichText(
              text: TextSpan(
                text: revealed ? part['text'] as String : '?',
                style: mono(
                    fontSize: term != null ? 26 : 22,
                    fontWeight: FontWeight.w500,
                    color: color),
                children: part.containsKey('sub') && revealed
                    ? [
                        TextSpan(
                            text: part['sub'] as String,
                            style: mono(
                                fontSize: 11,
                                color: color.withValues(alpha: 0.7)))
                      ]
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
      onTap: () => setState(() =>
          _highlighted =
              _highlighted == term['sym'] ? null : term['sym'] as String?),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHl ? color.withValues(alpha: 0.06) : C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isHl
                  ? color.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(term['sym'] as String,
                style: mono(fontSize: 15, color: color)),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(term['label'] as String,
                  style: spaceGrotesk(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(term['desc'] as String,
                  style: inter(fontSize: 12, color: C.muted)),
            ],
          )),
        ]),
      ),
    );
  }
}
