import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class CLExplainScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CLExplainScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CLExplainScreen> createState() => _CLExplainScreenState();
}

class _CLExplainScreenState extends State<CLExplainScreen> {
  String? _activeSym;

  static const _boundaryTerms = [
    {
      'sym': 'w',
      'color': 0xFFA78BFA,
      'label': 'Weights',
      'desc': 'Control the angle of the boundary. Each weight scales one feature.',
    },
    {
      'sym': 'x',
      'color': 0xFF38BDF8,
      'label': 'Input features',
      'desc': 'The coordinates of each data point.',
    },
    {
      'sym': 'b',
      'color': 0xFFFBBF24,
      'label': 'Bias',
      'desc': 'Shifts the boundary without changing its angle.',
    },
  ];

  static const _sigmoidTerms = [
    {
      'sym': 'σ',
      'color': 0xFF4ADE80,
      'label': 'Sigmoid function',
      'desc': 'Squashes any real number to a probability between 0 and 1.',
    },
    {
      'sym': 'z',
      'color': 0xFFFB7185,
      'label': 'Linear combination',
      'desc': 'z = w·x + b — the raw score before activation.',
    },
    {
      'sym': 'e',
      'color': 0xFFA78BFA,
      'label': "Euler's number",
      'desc': 'Mathematical constant ≈ 2.718. Base of the natural logarithm.',
    },
  ];

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
                      decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_left, color: C.muted, size: 18),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: C.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: C.green.withValues(alpha: 0.25)),
                          ),
                          child: Text('DISCOVERY', style: spaceGrotesk(fontSize: 12, color: C.green)),
                        ),
                        const SizedBox(height: 12),
                        Text('Where you draw the line matters.',
                          style: spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                        const SizedBox(height: 20),
                        Text(
                          'Classification is about finding a decision boundary that separates classes. '
                          'A linear classifier draws a straight line (or hyperplane in higher dimensions). '
                          'Points on each side receive a prediction label.',
                          style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Decision boundary formula
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        children: [
                          Text('THE DECISION BOUNDARY', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                          const SizedBox(height: 16),
                          _boundaryEquation(),
                          const SizedBox(height: 12),
                          Text('Tap a symbol to learn what it means.', style: inter(fontSize: 12, color: C.muted)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final term in _boundaryTerms) ...[
                    _termCard(term),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 20),

                  // Sigmoid activation formula
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      children: [
                        Text('SIGMOID ACTIVATION', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        const SizedBox(height: 16),
                        _sigmoidEquation(),
                        const SizedBox(height: 12),
                        Text('Converts the boundary score to a probability.', style: inter(fontSize: 12, color: C.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final term in _sigmoidTerms) ...[
                    _termCard(term),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 20),

                  // Intuition / scaling note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('scaling to high dimensions', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        Text(
                          'In 2D, the decision boundary is a line.\n'
                          'In 3D, it is a 2D plane.\n'
                          'In 1,000 dimensions, it is a 999-dimensional hyperplane. '
                          'The dot product w · x works identically in all dimensions.',
                          style: inter(fontSize: 13, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 350),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 12,
                    child: PrimaryBtn(label: 'TAKE THE CHALLENGE', onPressed: widget.onNext),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boundaryEquation() {
    final parts = [
      {'text': 'w₁', 'term': 'w'},
      {'text': 'x₁', 'term': 'x'},
      {'text': ' + ', 'term': null},
      {'text': 'w₂', 'term': 'w'},
      {'text': 'x₂', 'term': 'x'},
      {'text': ' + ', 'term': null},
      {'text': 'b', 'term': 'b'},
      {'text': ' = 0', 'term': null},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        final allTerms = [..._boundaryTerms, ..._sigmoidTerms];
        final termData = part['term'] != null
            ? allTerms.cast<Map<String, dynamic>>().firstWhere(
                (t) => t['sym'] == part['term'], orElse: () => <String, dynamic>{})
            : null;
        final isHl = part['term'] == _activeSym;
        final color = termData != null && termData.containsKey('color')
            ? Color(termData['color'] as int).withValues(alpha: isHl ? 1 : 0.6)
            : C.txt.withValues(alpha: 0.5);

        return GestureDetector(
          onTap: part['term'] != null
              ? () => setState(() => _activeSym = _activeSym == part['term'] ? null : part['term'])
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: isHl && termData != null ? Color(termData['color'] as int).withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              part['text'] as String,
              style: mono(fontSize: part['term'] != null ? 24 : 20, fontWeight: FontWeight.w500, color: color),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sigmoidEquation() {
    final parts = [
      {'text': 'σ', 'term': 'σ'},
      {'text': '(', 'term': null},
      {'text': 'z', 'term': 'z'},
      {'text': ') = ', 'term': null},
      {'text': '1 / (1 + ', 'term': null},
      {'text': 'e', 'term': 'e'},
      {'text': '⁻', 'term': null},
      {'text': 'z', 'term': 'z'},
      {'text': ')', 'term': null},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        final allTerms = [..._boundaryTerms, ..._sigmoidTerms];
        final termData = part['term'] != null
            ? allTerms.cast<Map<String, dynamic>>().firstWhere(
                (t) => t['sym'] == part['term'], orElse: () => <String, dynamic>{})
            : null;
        final isHl = part['term'] == _activeSym;
        final color = termData != null && termData.containsKey('color')
            ? Color(termData['color'] as int).withValues(alpha: isHl ? 1 : 0.6)
            : C.txt.withValues(alpha: 0.5);

        return GestureDetector(
          onTap: part['term'] != null
              ? () => setState(() => _activeSym = _activeSym == part['term'] ? null : part['term'])
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: isHl && termData != null ? Color(termData['color'] as int).withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              part['text'] as String,
              style: mono(fontSize: part['term'] != null ? 24 : 20, fontWeight: FontWeight.w500, color: color),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _termCard(Map<String, dynamic> term) {
    final isHl = _activeSym == term['sym'];
    final color = Color(term['color'] as int);
    return GestureDetector(
      onTap: () => setState(() => _activeSym = _activeSym == term['sym'] ? null : term['sym'] as String?),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHl ? color.withValues(alpha: 0.06) : C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isHl ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Text(term['sym'] as String, style: mono(fontSize: 15, color: color)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(term['label'] as String, style: spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(term['desc'] as String, style: inter(fontSize: 12, color: C.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
