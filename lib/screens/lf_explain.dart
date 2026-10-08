import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/loss_fns.dart' as lf_utils;

class LFExplainScreen extends StatefulWidget {
  final String selectedLoss;
  final double prediction;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LFExplainScreen({
    super.key,
    required this.selectedLoss,
    required this.prediction,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LFExplainScreen> createState() => _LFExplainScreenState();
}

class _LFExplainScreenState extends State<LFExplainScreen> {
  late String _activeType;

  @override
  void initState() {
    super.initState();
    _activeType = widget.selectedLoss;
  }

  @override
  Widget build(BuildContext context) {
    final activeCol = Color(lf_utils.lossColors[_activeType] ?? 0xFF8B5CF6);

    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: 'Loss Functions Explained', onBack: widget.onBack),
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
                        Text('Measuring mistakes.',
                            style: spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          'A loss function assigns a single number to how wrong a prediction is. Optimization algorithms do one thing: push this number toward zero.',
                          style: inter(fontSize: 14, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Formula selection tabs
                  Row(
                    children: ['mse', 'mae', 'huber'].map((type) {
                      final isCur = _activeType == type;
                      final col = Color(lf_utils.lossColors[type] ?? 0xFF8B5CF6);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () => setState(() => _activeType = type),
                            borderRadius: S.borderSm,
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCur ? col.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
                                borderRadius: S.borderSm,
                                border: Border.all(color: isCur ? col.withValues(alpha: 0.5) : Colors.transparent),
                              ),
                              child: Text(
                                lf_utils.lossNames[type] ?? type.toUpperCase(),
                                style: spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isCur ? col : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Active equation display
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    duration: const Duration(milliseconds: 400),
                    slideDistance: 14,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: S.borderMd,
                        border: Border.all(color: activeCol.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FORMULA', style: spaceGrotesk(fontSize: 11, color: C.muted, letterSpacing: 0.06)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: C.surface2,
                              borderRadius: S.borderSm,
                            ),
                            child: _buildEquationFormula(_activeType, activeCol),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getEquationDetail(_activeType),
                            style: inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Term breakdown
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
                        Text('anatomy of the loss', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 10),
                        _buildTermRow('y', 'true target value', C.green),
                        const SizedBox(height: 8),
                        _buildTermRow('ŷ', 'model prediction', C.purple),
                        const SizedBox(height: 8),
                        _buildTermRow('y − ŷ', 'error (residual)', C.blue),
                        const SizedBox(height: 8),
                        _buildTermRow('δ', 'Huber threshold (cutoff for quadratic)', C.yellow),
                      ],
                    ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Insight
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 280),
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
                        Text('why your choice matters', style: spaceGrotesk(fontSize: 12, color: C.muted, letterSpacing: 0.06)),
                        const SizedBox(height: 8),
                        Text(
                          '• MSE will pull models toward outliers because (10)² = 100.\n• MAE is robust against outliers but can be slow near zero.\n• Huber gives you the best of both worlds in real-world pipelines.',
                          style: inter(fontSize: 13, color: const Color(0xFFD1D5DB)),
                        ),
                      ],
                    ),
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

  Widget _buildEquationFormula(String type, Color col) {
    if (type == 'mse') {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: mono(fontSize: 16, color: C.txt),
          children: [
            const TextSpan(text: 'L = '),
            TextSpan(text: '(y − ŷ)²', style: mono(fontSize: 16, color: col, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    if (type == 'mae') {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: mono(fontSize: 16, color: C.txt),
          children: [
            const TextSpan(text: 'L = '),
            TextSpan(text: '|y − ŷ|', style: mono(fontSize: 16, color: col, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: mono(fontSize: 13, color: C.txt),
        children: [
          TextSpan(text: '½(y − ŷ)²', style: mono(fontSize: 13, color: col)),
          const TextSpan(text: '  if |y − ŷ| ≤ δ\n', style: TextStyle(color: Color(0xFF6B7280))),
          TextSpan(text: 'δ(|y − ŷ| − ½δ)', style: mono(fontSize: 13, color: col)),
          const TextSpan(text: '  otherwise', style: TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  String _getEquationDetail(String type) {
    if (type == 'mse') return 'Squaring makes large errors much more costly than small ones.';
    if (type == 'mae') return 'Absolute value — all errors are penalized equally per unit of error.';
    return 'Best of both: smooth quadratic near zero, bounded linear for distant outliers.';
  }

  Widget _buildTermRow(String sym, String desc, Color col) {
    return Row(
      children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: col.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(sym, style: mono(fontSize: 12, fontWeight: FontWeight.w600, color: col)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(desc, style: inter(fontSize: 13, color: const Color(0xFF9CA3AF)))),
      ],
    );
  }
}
