import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/neuralnet.dart' as nn_utils;

class BPExplainScreen extends StatefulWidget {
  final nn_utils.BPState bp;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BPExplainScreen({
    super.key,
    required this.bp,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BPExplainScreen> createState() => _BPExplainScreenState();
}

class _BPExplainScreenState extends State<BPExplainScreen> {
  String? _selectedSym;

  final _chainFactors = [
    {
      'sym': '∂L/∂y',
      'color': 0xFFFB7185,
      'label': 'Loss gradient w.r.t output',
      'desc': '= 2(y − y*). How much does loss change when prediction shifts? The root error signal.',
    },
    {
      'sym': '∂y/∂z₂',
      'color': 0xFFFBBF24,
      'label': 'Output sigmoid derivative',
      'desc': '= y(1 − y). The slope of the activation function at the output neuron.',
    },
    {
      'sym': '∂z₂/∂h',
      'color': 0xFF8B5CF6,
      'label': 'Connection weight wₕ',
      'desc': '= wₕ. The weight bridging hidden layer to output directly scales backward flow.',
    },
    {
      'sym': '∂h/∂z₁',
      'color': 0xFF38BDF8,
      'label': 'Hidden sigmoid derivative',
      'desc': '= h(1 − h). Activation slope at hidden layer. Can saturate if h is near 0 or 1.',
    },
    {
      'sym': '∂z₁/∂w₁',
      'color': 0xFF4ADE80,
      'label': 'Input signal x₁',
      'desc': '= x₁. The input feature itself. Larger inputs receive proportionately larger updates.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Backpropagation Explained', onBack: widget.onBack),
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
                  Text('The chain rule, everywhere.',
                      style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Backpropagation is simply the multivariate chain rule from calculus applied repeatedly from output to input. It calculates exactly how much blame each parameter carries for the error.',
                    style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                  ),
                  const SizedBox(height: 18),

                  // The Full Chain Equation
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
                        Text('the chain of derivatives', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Text('∂L/∂w₁ = ', style: mono(fontSize: 14, color: C.txt)),
                                ...List.generate(_chainFactors.length, (i) {
                                  final f = _chainFactors[i];
                                  final col = Color(f['color'] as int);
                                  final isSel = _selectedSym == f['sym'];
                                  return Row(
                                    children: [
                                      InkWell(
                                        onTap: () => setState(() => _selectedSym = isSel ? null : (f['sym'] as String)),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSel ? col.withValues(alpha: 0.2) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            f['sym'] as String,
                                            style: mono(fontSize: 14, color: isSel ? col : col.withValues(alpha: 0.85), fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      if (i < _chainFactors.length - 1)
                                        Text(' · ', style: mono(fontSize: 14, color: const Color(0xFF6B7280))),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Factors list
                  Text('each link in the chain', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                  const SizedBox(height: 10),
                  Column(
                    children: _chainFactors.map((f) {
                      final isSel = _selectedSym == f['sym'];
                      final col = Color(f['color'] as int);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedSym = isSel ? null : (f['sym'] as String)),
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
                                  width: 58,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: col.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(f['sym'] as String, style: mono(fontSize: 12, fontWeight: FontWeight.bold, color: col)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(f['label'] as String, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(f['desc'] as String, style: inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
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

                  // Vanishing gradient note
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
                        Text('why deep networks are challenging', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        Text(
                          'Because all these terms multiply together, if derivatives are < 1 (like sigmoid max derivative = 0.25), backpropagating through 50 layers causes gradients to shrink to near zero — the Vanishing Gradient problem!',
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
