import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF231816),
          borderRadius: BorderRadius.circular(14),
          border: const Border(
            left: BorderSide(
              color: Color(0xFFBB3322),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        _CourseBadge(text: course.code),

                        const SizedBox(width: 8),

                        _ActiveBadge(count: course.activeEvaluations),

                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      course.name,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      course.period,
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        const Icon(Icons.groups_outlined,
                            size: 16, color: Colors.white54),

                        const SizedBox(width: 4),

                        Text(
                          "${course.studentsCount} students",
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Icon(Icons.assignment_outlined,
                            size: 16, color: Colors.white54),

                        const SizedBox(width: 4),

                        Text(
                          "${course.activeEvaluations} evaluations",
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Icon(Icons.link,
                            size: 16, color: Colors.white54),

                        const SizedBox(width: 4),

                        Text(
                          "DS-${course.period}-${course.code.toLowerCase()}",
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
                size: 22,
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _CourseBadge extends StatelessWidget {
  final String text;

  const _CourseBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2016),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final int count;

  const _ActiveBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2016),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$count active",
        style: GoogleFonts.inter(
          color: const Color(0xFFFF8C60),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}