import 'package:flutter/material.dart';
import '../theme.dart';

class FollowUpData {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const FollowUpData({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class FollowUpCard extends StatefulWidget {
  final FollowUpData data;
  final VoidCallback onDismiss;

  const FollowUpCard({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  State<FollowUpCard> createState() => _FollowUpCardState();
}

class _FollowUpCardState extends State<FollowUpCard> {
  int _selected = -1;

  bool get _answered => _selected >= 0;
  bool get _correct => _selected == widget.data.correctIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !_answered
              ? C.yellow.withValues(alpha: 0.3)
              : _correct
                  ? C.green.withValues(alpha: 0.3)
                  : C.pink.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHY DID THIS WORK?',
              style: spaceGrotesk(
                  fontSize: 10, color: C.yellow, letterSpacing: 0.12)),
          const SizedBox(height: 8),
          Text(widget.data.question,
              style: inter(fontSize: 14, color: C.txt)),
          const SizedBox(height: 12),
          ...widget.data.options.asMap().entries.map((e) {
            final i = e.key;
            final text = e.value;
            final isCorrect = i == widget.data.correctIndex;
            final isSelected = i == _selected;

            Color bgColor;
            Color borderColor;
            Color textColor;

            if (!_answered) {
              bgColor = C.surface2;
              borderColor = C.border;
              textColor = C.txt;
            } else if (isCorrect) {
              bgColor = C.green.withValues(alpha: 0.12);
              borderColor = C.green.withValues(alpha: 0.4);
              textColor = C.green;
            } else if (isSelected) {
              bgColor = C.pink.withValues(alpha: 0.08);
              borderColor = C.pink.withValues(alpha: 0.3);
              textColor = C.pink;
            } else {
              bgColor = C.surface2;
              borderColor = C.border;
              textColor = C.muted;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: _answered ? null : () => setState(() => _selected = i),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Text(String.fromCharCode(65 + i),
                          style: mono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(text,
                              style: inter(fontSize: 13, color: textColor))),
                      if (_answered && isCorrect)
                        const Icon(Icons.check_circle,
                            size: 16, color: C.green),
                      if (_answered && isSelected && !isCorrect)
                        const Icon(Icons.close, size: 16, color: C.pink),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _correct
                    ? C.green.withValues(alpha: 0.08)
                    : C.yellow.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.data.explanation,
                style: inter(
                    fontSize: 12,
                    color: _correct ? C.greenLight : C.yellow),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: widget.onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _correct ? C.green : C.accent,
                  foregroundColor: _correct ? C.bg : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text('Got it',
                    style: spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _correct ? C.bg : Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
