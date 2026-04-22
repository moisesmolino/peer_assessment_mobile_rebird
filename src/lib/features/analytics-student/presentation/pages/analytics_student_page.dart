import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state_management/analytics_student_controller.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/score_bar_widget.dart';

class AnalyticsStudentPage extends StatelessWidget {
  const AnalyticsStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AnalyticsStudentController>();

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
            _Header(evaluationName: c.evaluationName, courseName: c.courseName),
            Expanded(
              child: c.hasNoData.value
                  ? _NoDataBody()
                  : _ResultsBody(c: c),
            ),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final String evaluationName;
  final String courseName;

  const _Header({required this.evaluationName, required this.courseName});

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
                  evaluationName,
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

class _NoDataBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No results available yet.',
        style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  final AnalyticsStudentController c;

  const _ResultsBody({required this.c});

  @override
  Widget build(BuildContext context) {
    final a = c.analytics.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AvgScoreCard(analytics: a),
          const SizedBox(height: 20),
          _CriteriaBreakdownCard(analytics: a),
          const SizedBox(height: 20),
          _CommentsCard(analytics: a),
        ],
      ),
    );
  }
}

class _CommentsCard extends StatelessWidget {
  final dynamic analytics;

  const _CommentsCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF231816),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (analytics.comments.isEmpty)
            Text(
              'No comments yet.',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
            )
          else
            ...List<Widget>.generate(
              analytics.comments.length,
              (i) {
                final comment = analytics.comments[i];
                final isPublic = analytics.isPublic;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i < analytics.comments.length - 1 ? 12 : 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15100E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPublic) ...[
                          Text(
                            comment.evaluatorEmail,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFF8C60),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          comment.text,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AvgScoreCard extends StatelessWidget {
  final dynamic analytics;

  const _AvgScoreCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF231816),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Your avg score in this task',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: analytics.avgScore.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFF6B6B),
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' /5.0',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3A1E18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              analytics.scoreLabel,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CriteriaBreakdownCard extends StatelessWidget {
  final dynamic analytics;

  const _CriteriaBreakdownCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF231816),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Critiria breakdown',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: RadarChartWidget(
              punctuality: analytics.punctuality,
              contributions: analytics.contributions,
              commitment: analytics.commitment,
              attitude: analytics.attitude,
            ),
          ),
          const SizedBox(height: 24),
          ScoreBarWidget(label: 'Punctuality', value: analytics.punctuality),
          ScoreBarWidget(
              label: 'Contributions', value: analytics.contributions),
          ScoreBarWidget(label: 'Commitment', value: analytics.commitment),
          ScoreBarWidget(label: 'Attitude', value: analytics.attitude),
        ],
      ),
    );
  }
}
