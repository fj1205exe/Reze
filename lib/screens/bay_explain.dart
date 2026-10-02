import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/bayes.dart' as bay_utils;

class BAYExplainScreen extends StatefulWidget {
  final double prior;
  final double sensitivity;
  final double specificity;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BAYExplainScreen({
    super.key,
    required this.prior,
    required this.sensitivity,
    required this.specificity,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BAYExplainScreen> createState() => _BAYExplainScreenState();
}

class _BAYExplainScreenState extends State<BAYExplainScreen> {
  String? _selectedSym;

  final _terms = [
    {
      'sym': 'P(H|E)',
      'color': 0xFF4ADE80,
      'label': 'Posterior',
      'desc': 'Probability of the hypothesis being true after observing the evidence. What we want to infer.',
    },
    {
      'sym': 'P(E|H)',
      'color': 0xFF8B5CF6,
      'label': 'Likelihood',
      'desc': 'Probability of observing this evidence if hypothesis is true. (Sensitivity in medical testing).',
    },
    {
      'sym': 'P(H)',
      'color': 0xFFFBBF24,
      'label': 'Prior',
      'desc': 'Baseline belief before observing any new evidence. (Disease prevalence in population).',
    },
    {
      'sym': 'P(E)',
      'color': 0xFF38BDF8,
      'label': 'Evidence Normalizer',
      'desc': 'Total probability of the evidence across all scenarios: P(E|H)P(H) + P(E|¬H)P(¬H).',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final posterior = bay_utils.calcPosterior(widget.prior, widget.sensitivity, widget.specificity);
    final pPositive = widget.sensitivity * widget.prior + (1 - widget.specificity) * (1 - widget.prior);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: "Bayes' Theorem Explained", onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
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
                  Text('Prior beliefs meet evidence.',
                      style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Bayesian reasoning updates prior beliefs when new evidence arrives. Even a test with high accuracy can produce mostly false positives when the prior probability of an event is tiny.',
                    style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                  ),
                  const SizedBox(height: 18),

                  // The Theorem formula box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("bayes' theorem", style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: mono(fontSize: 15, color: C.txt),
                              children: [
                                TextSpan(text: 'P(H|E)', style: mono(fontSize: 15, color: C.green, fontWeight: FontWeight.bold)),
                                const TextSpan(text: ' = ('),
                                TextSpan(text: 'P(E|H)', style: mono(fontSize: 15, color: C.purple, fontWeight: FontWeight.bold)),
                                const TextSpan(text: ' · '),
                                TextSpan(text: 'P(H)', style: mono(fontSize: 15, color: C.yellow, fontWeight: FontWeight.bold)),
                                const TextSpan(text: ') / '),
                                TextSpan(text: 'P(E)', style: mono(fontSize: 15, color: C.blue, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medical test live context
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('for our medical test', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('P(+|D) sensitivity', style: inter(fontSize: 11, color: C.muted)),
                                    const SizedBox(height: 2),
                                    Text('${(widget.sensitivity * 100).toStringAsFixed(0)}%', style: mono(fontSize: 14, color: C.purple)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('P(D) prior', style: inter(fontSize: 11, color: C.muted)),
                                    const SizedBox(height: 2),
                                    Text('${(widget.prior * 100).toStringAsFixed(1)}%', style: mono(fontSize: 14, color: C.yellow)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('P(+) normalizer', style: inter(fontSize: 11, color: C.muted)),
                                    const SizedBox(height: 2),
                                    Text('${(pPositive * 100).toStringAsFixed(1)}%', style: mono(fontSize: 14, color: C.blue)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('P(D|+) posterior', style: inter(fontSize: 11, color: C.muted)),
                                    const SizedBox(height: 2),
                                    Text('${(posterior * 100).toStringAsFixed(1)}%', style: mono(fontSize: 14, color: C.green)),
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

                  // Interactive terms
                  Text('anatomy of the equation', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                  const SizedBox(height: 10),
                  Column(
                    children: _terms.map((t) {
                      final isSel = _selectedSym == t['sym'];
                      final col = Color(t['color'] as int);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedSym = isSel ? null : (t['sym'] as String)),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSel ? col.withValues(alpha: 0.1) : C.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSel ? col.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: col.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(t['sym'] as String, style: mono(fontSize: 12, fontWeight: FontWeight.bold, color: col)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t['label'] as String, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(t['desc'] as String, style: inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Machine learning context
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
                        Text('bayesian thinking in modern AI', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        Text(
                          '• Naive Bayes: Text classification and spam detection.\n• Bayesian Neural Networks: Weights are probability distributions rather than single scalar values, giving calibrated uncertainty.\n• Bayesian Optimization: Tuning hyperparameters efficiently when evaluations are expensive.',
                          style: inter(fontSize: 13, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  PrimaryBtn(label: 'TAKE THE CHALLENGE', onPressed: widget.onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
