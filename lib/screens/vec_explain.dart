import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class VECExplainScreen extends StatefulWidget {
  final double ax, ay, bx, by;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const VECExplainScreen({
    super.key,
    required this.ax,
    required this.ay,
    required this.bx,
    required this.by,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<VECExplainScreen> createState() => _VECExplainScreenState();
}

class _VECExplainScreenState extends State<VECExplainScreen> {
  String? _highlighted;
  String? _activeTerm;

  static const _formulaTerms = [
    {'sym': 'v', 'color': 0xFF8B5CF6, 'label': 'Vector', 'desc': 'The full vector — an ordered list of numbers'},
    {'sym': 'v₁', 'color': 0xFF38BDF8, 'label': 'x-component', 'desc': 'The first component — horizontal displacement'},
    {'sym': 'v₂', 'color': 0xFFFBBF24, 'label': 'y-component', 'desc': 'The second component — vertical displacement'},
    {'sym': '|v|', 'color': 0xFF4ADE80, 'label': 'Magnitude', 'desc': 'The length of the vector — √(v₁² + v₂²)'},
  ];

  final _vocabTerms = [
    {
      'id': 'direction',
      'label': 'direction',
      'color': 0xFF8B5CF6,
      'def': 'Which way a vector points — represented as an angle or orientation in space.',
    },
    {
      'id': 'magnitude',
      'label': 'magnitude',
      'color': 0xFF38BDF8,
      'def': 'The length of the vector. Written |v|. Computed as √(v₁² + v₂²).',
    },
    {
      'id': 'components',
      'label': 'components',
      'color': 0xFFFBBF24,
      'def': 'The individual coordinates. A 2D vector has 2 numbers; a 768-dim embedding has 768.',
    },
    {
      'id': 'unit vector',
      'label': 'unit vector',
      'color': 0xFF4ADE80,
      'def': 'A vector with length 1. Formed by dividing any vector by its own magnitude: v / |v|.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final magA = sqrt(widget.ax * widget.ax + widget.ay * widget.ay);

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
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: C.green.withValues(alpha: 0.25)),
                          ),
                          child: Text('DISCOVERY',
                              style: spaceGrotesk(fontSize: 11, color: C.green, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Text('Everything in ML is a vector.',
                            style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          'Images are pixel vectors. Text tokens are embedding vectors. Model weights are parameter vectors. All machine learning algorithms are geometry performed on vectors.',
                          style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Interactive formula
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
                        border: Border.all(color: C.border),
                      ),
                      child: Column(
                        children: [
                          Text('THE VECTOR', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                          const SizedBox(height: 16),
                          _equation(),
                          const SizedBox(height: 8),
                          _magnitudeEquation(),
                          const SizedBox(height: 12),
                          Text('Tap a symbol to learn what it means.', style: inter(fontSize: 12, color: C.muted)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Formula term cards
                  for (final term in _formulaTerms) ...[
                    _termCard(term),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),

                  // Vector A sample display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.accent.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR VECTOR A', style: spaceGrotesk(fontSize: 11, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'a = [${widget.ax.toStringAsFixed(2)}, ${widget.ay.toStringAsFixed(2)}]',
                              style: mono(fontSize: 16, color: C.accentLight, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              '|a| = ${magA.toStringAsFixed(2)}',
                              style: mono(fontSize: 14, color: C.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vocabulary terms
                  Text('core vocabulary', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _vocabTerms.map((t) {
                      final isSelected = _activeTerm == t['id'];
                      final col = Color(t['color'] as int);
                      return InkWell(
                        onTap: () => setState(() => _activeTerm = isSelected ? null : (t['id'] as String)),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? col.withValues(alpha: 0.2) : C.dim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? col : Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Text(
                            t['label'] as String,
                            style: spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? col : C.txt),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_activeTerm != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: S.borderSm,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Text(
                        _vocabTerms.firstWhere((t) => t['id'] == _activeTerm)['def'] as String,
                        style: inter(fontSize: 13, color: const Color(0xFFD1D5DB)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // Operations
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
                        Text('fundamental operations', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        _buildOpCard('Addition', 'a + b = (a₁ + b₁, a₂ + b₂)', 'Add corresponding components together.', C.green),
                        const SizedBox(height: 10),
                        _buildOpCard('Magnitude', '|a| = √(a₁² + a₂²)', 'Pythagorean length from the origin.', C.blue),
                        const SizedBox(height: 10),
                        _buildOpCard('Scaling', 's · a = (s · a₁, s · a₂)', 'Multiply every component by a scalar number.', C.purple),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

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

  Widget _equation() {
    final parts = [
      {'text': 'v', 'term': 'v'},
      {'text': ' = [', 'term': null},
      {'text': 'v₁', 'term': 'v₁'},
      {'text': ', ', 'term': null},
      {'text': 'v₂', 'term': 'v₂'},
      {'text': ']', 'term': null},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        final termData = part['term'] != null
            ? _formulaTerms.firstWhere((t) => t['sym'] == part['term'], orElse: () => <String, Object>{})
            : null;
        final isHl = part['term'] == _highlighted;
        final color = termData != null && termData.containsKey('color')
            ? Color(termData['color'] as int).withValues(alpha: isHl ? 1 : 0.6)
            : C.txt.withValues(alpha: 0.5);

        return GestureDetector(
          onTap: part['term'] != null ? () => setState(() => _highlighted = _highlighted == part['term'] ? null : part['term']) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isHl && termData != null ? Color(termData['color'] as int).withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              part['text'] as String,
              style: mono(fontSize: part['term'] != null ? 26 : 22, fontWeight: FontWeight.w500, color: color),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _magnitudeEquation() {
    final term = _formulaTerms.firstWhere((t) => t['sym'] == '|v|');
    final isHl = _highlighted == '|v|';
    final color = Color(term['color'] as int).withValues(alpha: isHl ? 1 : 0.6);

    return GestureDetector(
      onTap: () => setState(() => _highlighted = _highlighted == '|v|' ? null : '|v|'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isHl ? Color(term['color'] as int).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '|v| = √(v₁² + v₂²)',
          style: mono(fontSize: 20, fontWeight: FontWeight.w500, color: color),
        ),
      ),
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
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: S.borderSm),
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

  Widget _buildOpCard(String title, String formula, String desc, Color col) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.06),
        borderRadius: S.borderSm,
        border: Border(left: BorderSide(color: col, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: col)),
              Flexible(child: Text(formula, style: mono(fontSize: 12, color: C.txt))),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
