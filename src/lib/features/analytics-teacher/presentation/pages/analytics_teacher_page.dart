import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state_management/analytics_teacher_controller.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/student_summary_tile.dart';

class AnalyticsTeacherPage extends StatelessWidget {
  const AnalyticsTeacherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AnalyticsTeacherController>();

    return Scaffold(
      backgroundColor: const Color(0xFF15100E),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFBB3322)),
          );
        }
        return Column(
          children: [
            _Header(courseName: c.courseName),
            Expanded(
              child: c.hasNoData.value
                  ? _NoData()
                  : _Body(c: c),
            ),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final String courseName;

  const _Header({required this.courseName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF231816),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  courseName,
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
    );
  }
}

class _NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No responses yet.',
        style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final AnalyticsTeacherController c;

  const _Body({required this.c});

  @override
  Widget build(BuildContext context) {
    final a = c.analytics.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (a.perActivity.isNotEmpty) ...[
            _SectionCard(
              title: 'Average per activity',
              child: BarChartWidget(
                entries: a.perActivity
                    .map((e) => BarChartEntry(
                          label: e.evaluationName,
                          value: e.avgScore,
                        ))
                    .toList(),
                barColor: const Color(0xFFE040FB),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (a.perStudent.isNotEmpty) ...[
            Text(
              'Average per student',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
                  children: a.perStudent
                      .map((s) => StudentSummaryTile(
                            student: s,
                            isExpanded: c.expandedEmail.value == s.email,
                            onTap: () => c.toggleStudent(s.email),
                          ))
                      .toList(),
                )),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF231816),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
