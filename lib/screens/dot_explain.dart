import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/vectors.dart';

class DOTExplainScreen extends StatelessWidget {
  final double angleA, angleB, magA, magB;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DOTExplainScreen({
    super.key,
    required this.angleA,
    required this.angleB,
    required this.magA,
    required this.magB,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final aRad = angleA * pi / 180;
    final bRad = angleB * pi / 180;
    final ax = magA * cos(aRad);
    final ay = magA * sin(aRad);
    final bx = magB * cos(bRad);
    final by = magB * sin(bRad);
    final dotVal = ax * bx + ay * by;
    final theta = vecAngle(Vec2(ax, ay), Vec2(bx, by));

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Dot Product Explained', onBack: onBack),
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
                  Text('The engine of ML.',
                      style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'The dot product has two equivalent formulas — one geometric (angles and lengths) and one algebraic (multiplying coordinates). Modern deep learning is largely millions of dot products evaluated per second.',
                    style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                  ),
                  const SizedBox(height: 16),

                  // Live value from playground
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('from your playground', style: inter(fontSize: 12, color: C.muted)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text('a · b = ', style: mono(fontSize: 14, color: C.txt)),
                                Text(
                                  dotVal.toStringAsFixed(3),
                                  style: mono(
                                    fontSize: 14,
                                    color: dotVal > 0.05 ? C.green : dotVal < -0.05 ? C.pink : C.txt,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('angle', style: inter(fontSize: 12, color: C.muted)),
                            const SizedBox(height: 2),
                            Text('θ = ${theta.toStringAsFixed(1)}°', style: mono(fontSize: 14, color: C.yellow)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Geometric vs Algebraic Formulas
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
                        Text('two faces of the same operation', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GEOMETRIC FORM', style: mono(fontSize: 10, color: C.blue)),
                              const SizedBox(height: 4),
                              Text('a · b = |a| |b| cos(θ)', style: mono(fontSize: 15, color: C.txt, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('Measures alignment: +1 (same direction), 0 (orthogonal), −1 (opposite).', style: inter(fontSize: 11, color: C.muted)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ALGEBRAIC FORM', style: mono(fontSize: 10, color: C.purple)),
                              const SizedBox(height: 4),
                              Text('a · b = a₁b₁ + a₂b₂ + ... + aₙbₙ', style: mono(fontSize: 14, color: C.txt, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('How computers execute it: multiply corresponding elements, then sum.', style: inter(fontSize: 11, color: C.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Applications in modern ML
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
                        Text('where dot products power AI', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        _buildAppRow('Attention Mechanism (LLMs)', 'score = Q · Kᵀ', 'How ChatGPT figures out which words relate to which.', C.accent),
                        const SizedBox(height: 10),
                        _buildAppRow('Cosine Similarity', 'sim = â · b̂', 'Searching vectors in RAG and vector databases.', C.blue),
                        const SizedBox(height: 10),
                        _buildAppRow('Neuron Activations', 'z = w · x + b', 'The forward pass of every dense layer.', C.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  PrimaryBtn(label: 'TAKE THE CHALLENGE', onPressed: onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppRow(String title, String formula, String desc, Color col) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: col, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: col)),
              Text(formula, style: mono(fontSize: 11, color: C.txt)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
