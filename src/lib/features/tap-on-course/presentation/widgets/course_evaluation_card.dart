import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src/features/tap-on-course/domain/entities/course_evaluation.dart';

class CourseEvaluationCard extends StatelessWidget {
  final CourseEvaluation evaluation;
  final VoidCallback? onEvaluate;
  final VoidCallback? onViewResults;

  const CourseEvaluationCard({
    super.key,
    required this.evaluation,
    this.onEvaluate,
    this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = evaluation.status == 'active';
    final showCta = onEvaluate != null || onViewResults != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF231816),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            evaluation.name,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusBadge(status: evaluation.status),
              const SizedBox(width: 8),
              _VisibilityBadge(visibility: evaluation.visibility),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                _formatDeadline(evaluation.deadline),
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          if (showCta) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onEvaluate ?? onViewResults,
              child: Text(
                onEvaluate != null ? 'Evaluate now →' : 'View results →',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF8C60),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDeadline(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $period';
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E3A1E) : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Closed',
        style: GoogleFonts.inter(
          color: isActive ? const Color(0xFF4CAF50) : Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  final String visibility;

  const _VisibilityBadge({required this.visibility});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF5C2A1A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        visibility == 'public' ? 'Public' : 'Private',
        style: GoogleFonts.inter(
          color: const Color(0xFFFF8C60),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
