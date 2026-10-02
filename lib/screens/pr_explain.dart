import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/probability.dart' as pr_utils;

class PRExplainScreen extends StatefulWidget {
  final double p;
  final List<String> flips;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PRExplainScreen({
    super.key,
    required this.p,
    required this.flips,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PRExplainScreen> createState() => _PRExplainScreenState();
}

class _PRExplainScreenState extends State<PRExplainScreen> {
  String? _highlighted;

  static const _binomialTerms = [
    {'sym': 'C(n,k)', 'color': 0xFFA78BFA, 'label': 'Binomial coefficient', 'desc': 'Number of ways to choose k successes from n trials: n! / (k!(n-k)!)'},
    {'sym': 'p^k', 'color': 0xFF38BDF8, 'label': 'Success probability', 'desc': 'Probability of getting exactly k heads. Higher p means more heads.'},
    {'sym': '(1-p)^(n-k)', 'color': 0xFFFB7185, 'label': 'Failure probability', 'desc': 'Probability of getting exactly (n-k) tails.'},
  ];

  static const _evTerms = [
    {'sym': 'n', 'color': 0xFF4ADE80, 'label': 'Number of trials', 'desc': 'Total number of coin flips.'},
    {'sym': 'p', 'color': 0xFFFBBF24, 'label': 'Success probability', 'desc': 'Probability of heads on each flip.'},
  ];

  List<Map<String, dynamic>> get _allTerms => [..._binomialTerms, ..._evTerms];

  @override
  Widget build(BuildContext context) {
    final n = widget.flips.length;
    final h = pr_utils.countH(widget.flips);
    final empP = pr_utils.empiricalP(widget.flips);

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
                  Text('The law of large numbers.',
                    style: spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.01)),
                  const SizedBox(height: 20),
                  Text(
                    'As you collect more observations, empirical frequencies converge to true underlying probabilities. This guarantee underpins all of data science, sampling, and model evaluation.',
                    style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                  ),
                  const SizedBox(height: 20),

                  // Session summary
                  if (n > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('your experiment', style: spaceGrotesk(fontSize: 11, color: C.muted, letterSpacing: 0.06)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$h heads in $n flips', style: inter(fontSize: 13, color: C.txt)),
                                Text(
                                  '${(empP * 100).toStringAsFixed(1)}% observed vs ${(widget.p * 100).toStringAsFixed(0)}% true',
                                  style: mono(fontSize: 12, color: C.blue, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Formula 1: Simple probability
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
                        Text('COIN FLIP PROBABILITY', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: mono(fontSize: 22, color: C.txt),
                            children: [
                              const TextSpan(text: 'P(heads) = '),
                              TextSpan(text: 'p', style: mono(fontSize: 22, color: C.yellow)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Formula 2: Binomial distribution
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
                        Text('THE BINOMIAL DISTRIBUTION', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        const SizedBox(height: 16),
                        _binomialEquation(),
                        const SizedBox(height: 12),
                        Text('Tap a symbol to learn what it means.', style: inter(fontSize: 12, color: C.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final term in _binomialTerms) ...[
                    _termCard(term),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),

                  // Formula 3: Expected Value
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
                        Text('EXPECTED VALUE', style: spaceGrotesk(fontSize: 10, color: C.muted, letterSpacing: 0.12)),
                        const SizedBox(height: 16),
                        _evEquation(),
                        const SizedBox(height: 12),
                        Text('Tap a symbol to learn what it means.', style: inter(fontSize: 12, color: C.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final term in _evTerms) ...[
                    _termCard(term),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),

                  // Connection to ML
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
                        Text('connection to machine learning', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        Text(
                          '• Classification output probabilities: Softmax and Sigmoid outputs estimate p.\n• Cross-Entropy Loss: Minimizes the divergence between predicted probability distributions and empirical ground truth.\n• Monte Carlo methods: Sampling used in diffusion models and reinforcement learning.',
                          style: inter(fontSize: 13, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryBtn(label: 'TAKE THE CHALLENGE', onPressed: widget.onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _binomialEquation() {
    final parts = [
      {'text': 'P(k)', 'term': null},
      {'text': ' = ', 'term': null},
      {'text': 'C(n,k)', 'term': 'C(n,k)'},
      {'text': ' ', 'term': null},
      {'text': 'p', 'term': 'p^k', 'sup': 'k'},
      {'text': ' ', 'term': null},
      {'text': '(1-p)', 'term': '(1-p)^(n-k)', 'sup': 'n-k'},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        final termData = part['term'] != null
            ? _allTerms.cast<Map<String, dynamic>>().firstWhere(
                (t) => t['sym'] == part['term'],
                orElse: () => <String, dynamic>{},
              )
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
            child: RichText(
              text: TextSpan(
                text: part['text'] as String,
                style: mono(fontSize: part['term'] != null ? 22 : 18, fontWeight: FontWeight.w500, color: color),
                children: part.containsKey('sup') ? [
                  WidgetSpan(
                    child: Transform.translate(
                      offset: const Offset(0, -8),
                      child: Text(part['sup'] as String, style: mono(fontSize: 12, color: color)),
                    ),
                  ),
                ] : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _evEquation() {
    final parts = [
      {'text': 'E[X]', 'term': null},
      {'text': ' = ', 'term': null},
      {'text': 'n', 'term': 'n'},
      {'text': ' × ', 'term': null},
      {'text': 'p', 'term': 'p'},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        final termData = part['term'] != null
            ? _allTerms.cast<Map<String, dynamic>>().firstWhere(
                (t) => t['sym'] == part['term'],
                orElse: () => <String, dynamic>{},
              )
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

  Widget _termCard(Map<String, dynamic> term) {
    final isHl = _highlighted == term['sym'];
    final color = Color(term['color'] as int);
    return GestureDetector(
      onTap: () => setState(() => _highlighted = _highlighted == term['sym'] ? null : term['sym'] as String?),
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
              width: 40, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Text(
                (term['sym'] as String).length > 3 ? (term['sym'] as String).substring(0, 3) : term['sym'] as String,
                style: mono(fontSize: 13, color: color),
              ),
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
