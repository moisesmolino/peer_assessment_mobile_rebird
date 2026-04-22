import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src/features/analytics-student/presentation/widgets/radar_chart_widget.dart';
import 'package:src/features/analytics-student/presentation/widgets/score_bar_widget.dart';
import '../../domain/entities/teacher_analytics.dart';

class StudentSummaryTile extends StatelessWidget {
  final StudentSummary student;
  final bool isExpanded;
  final VoidCallback onTap;

  const StudentSummaryTile({
    super.key,
    required this.student,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF231816),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _Avatar(initials: student.initials),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.displayName,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (student.avgScore / 5).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: const Color(0xFF3A2016),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFBB3322),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        student.avgScore.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF6B6B),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '/5',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? _ExpandedDetail(student: student)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;

  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF4A4A4A),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ExpandedDetail extends StatelessWidget {
  final StudentSummary student;

  const _ExpandedDetail({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          Center(
            child: RadarChartWidget(
              punctuality: student.punctuality,
              contributions: student.contributions,
              commitment: student.commitment,
              attitude: student.attitude,
            ),
          ),
          const SizedBox(height: 16),
          ScoreBarWidget(label: 'Punctuality', value: student.punctuality),
          ScoreBarWidget(label: 'Contributions', value: student.contributions),
          ScoreBarWidget(label: 'Commitment', value: student.commitment),
          ScoreBarWidget(label: 'Attitude', value: student.attitude),
          if (student.comments.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Comments',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...student.comments.map(
              (c) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF15100E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.evaluatorEmail,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFF8C60),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.text,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
