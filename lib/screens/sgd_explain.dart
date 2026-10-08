import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/sgd.dart' as sgd;

class SGDExplainScreen extends StatelessWidget {
  final double theta;
  final List<double> history;
  final sgd.BatchSize batchSize;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SGDExplainScreen({
    super.key,
    required this.theta,
    required this.history,
    required this.batchSize,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Stochastic GD Explained', onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
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
                        Text('Noise is a feature, not a bug.',
                            style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          'Classic gradient descent computes the exact gradient over the entire dataset on every step. That is computationally prohibitive on millions of items. SGD trades precision for speed by estimating the gradient from small random batches.',
                          style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Why noise helps
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('why noise helps', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        _buildBenefitRow('⚡', 'Speed', 'Each step requires a tiny fraction of computation — orders of magnitude faster.'),
                        const SizedBox(height: 10),
                        _buildBenefitRow('🏔', 'Escaping local minima', 'Stochastic fluctuations can kick the optimizer out of suboptimal saddles and valleys.'),
                        const SizedBox(height: 10),
                        _buildBenefitRow('🎯', 'Implicit regularization', 'The noise acts like an implicit regularizer, preventing early over-memorization.'),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),

                  // Batch size comparison
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: C.surface,
                      borderRadius: S.borderMd,
                      border: Border.all(color: C.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('batch size tradeoffs', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 12),
                        _buildTradeoffCard('Full Batch (GD)', C.accent, 'Exact gradient, slow per step, deterministic path.'),
                        const SizedBox(height: 8),
                        _buildTradeoffCard('Mini-Batch (SGD)', C.blue, 'Modern standard (32–512 samples). Balanced speed and variance.'),
                        const SizedBox(height: 8),
                        _buildTradeoffCard('Single Sample (Pure SGD)', C.yellow, 'Instant step calculation, noisy path, high fluctuations.'),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 20),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 350),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 12,
                    child: PrimaryBtn(label: 'TAKE THE CHALLENGE', onPressed: onNext),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(desc, style: inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTradeoffCard(String title, Color col, String desc) {
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
          Text(title, style: spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: col)),
          const SizedBox(height: 3),
          Text(desc, style: inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
