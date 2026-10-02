import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/neuralnet.dart' as nn_utils;

class NNExplainScreen extends StatefulWidget {
  final double w1, w2, bias, x1, x2;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NNExplainScreen({
    super.key,
    required this.w1,
    required this.w2,
    required this.bias,
    required this.x1,
    required this.x2,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<NNExplainScreen> createState() => _NNExplainScreenState();
}

class _NNExplainScreenState extends State<NNExplainScreen> {
  String _activeAct = 'Sigmoid';
  String? _activeSym;

  final _terms = [
    {'sym': 'w', 'color': 0xFF4ADE80, 'label': 'Weights', 'desc': 'Learnable parameters — connection strength adjusted during training.'},
    {'sym': 'x', 'color': 0xFF38BDF8, 'label': 'Inputs', 'desc': 'Data fed into the neuron (e.g. pixels, embeddings, activations from prior layer).'},
    {'sym': 'b', 'color': 0xFFFBBF24, 'label': 'Bias', 'desc': 'Learnable offset — shifts activation threshold away from origin.'},
    {'sym': 'σ', 'color': 0xFF8B5CF6, 'label': 'Activation', 'desc': 'Non-linear function. Without it, deep networks collapse into a single linear equation.'},
  ];

  Widget _buildTermButton(String sym, int colorVal) {
    final isSel = _activeSym == sym;
    final color = Color(colorVal);
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeSym = isSel ? null : sym;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isSel ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(color: isSel ? color : Colors.transparent),
        ),
        child: Text(
          sym,
          style: mono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSel ? color : color.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forward = nn_utils.neuronForward(widget.x1, widget.x2, widget.w1, widget.w2, widget.bias);
    final z = forward['z']!;
    final output = forward['output']!;
    final selectedTerm = _terms.firstWhere(
      (t) => t['sym'] == _activeSym,
      orElse: () => <String, Object>{},
    );

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Neuron Architecture', onBack: widget.onBack),
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
                  Text('The neuron is just math.',
                      style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'A biological metaphor, but mathematical in practice: dot product of inputs and weights, shifted by bias, squashed by an activation function.',
                    style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                  ),
                  const SizedBox(height: 18),

                  // The Neuron Equation
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
                        Text('forward pass formula', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('output = ', style: mono(fontSize: 15, color: C.txt)),
                                  _buildTermButton('σ', 0xFF8B5CF6),
                                  Text('(', style: mono(fontSize: 15, color: C.muted)),
                                  _buildTermButton('w', 0xFF4ADE80),
                                  Text(' · ', style: mono(fontSize: 15, color: C.txt)),
                                  _buildTermButton('x', 0xFF38BDF8),
                                  Text(' + ', style: mono(fontSize: 15, color: C.txt)),
                                  _buildTermButton('b', 0xFFFBBF24),
                                  Text(')', style: mono(fontSize: 15, color: C.muted)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Tap a term to understand it', style: inter(fontSize: 11, color: C.muted)),
                            ],
                          ),
                        ),
                        if (_activeSym != null && selectedTerm.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(selectedTerm['color'] as int).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(selectedTerm['color'] as int).withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedTerm['label'] as String,
                                  style: spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(selectedTerm['color'] as int),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedTerm['desc'] as String,
                                  style: inter(fontSize: 12, color: C.txt),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('z (linear pre-activation): ${z.toStringAsFixed(3)}', style: mono(fontSize: 11, color: C.muted)),
                            Text('σ(z): ${output.toStringAsFixed(3)}', style: mono(fontSize: 11, color: C.accentLight)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activation functions tabs
                  Text('activation functions', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Sigmoid', 'ReLU'].map((name) {
                      final isSel = _activeAct == name;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() => _activeAct = name),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSel ? C.accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSel ? C.accent : Colors.transparent),
                              ),
                              child: Text(
                                name,
                                style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? C.accentLight : const Color(0xFF9CA3AF)),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _activeAct == 'Sigmoid'
                          ? 'Sigmoid: σ(z) = 1 / (1 + e⁻ᶻ)\nCompresses any real number into (0, 1). Perfect for probabilities, but suffers from vanishing gradients.'
                          : 'ReLU: σ(z) = max(0, z)\nThe workhorse of modern deep learning. Fast derivative (0 or 1), prevents vanishing gradients in deep layers.',
                      style: inter(fontSize: 12, color: const Color(0xFFD1D5DB)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // The Solution to XOR: Hidden Layers
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
                        Text('why xor needs hidden layers', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        Text(
                          'A single neuron can only draw one straight line. But stacking neurons in layers creates non-linear decision boundaries that bend, carve, and enclose arbitrary shapes.',
                          style: inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
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
