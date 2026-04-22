import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreBarWidget extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;

  const ScoreBarWidget({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: const Color(0xFF3A2016),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFBB3322),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: const Color(0xFFFF8C60),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
