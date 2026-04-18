import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/analytics-teacher/presentation/widgets/student_summary_tile.dart';
import 'package:src/features/analytics-student/presentation/widgets/radar_chart_widget.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/analytics_teacher_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('renders collapsed tile with student identity and score', (
    tester,
  ) async {
    final student = buildStudentSummary();

    await tester.pumpWidget(
      wrapForTest(
        StudentSummaryTile(student: student, isExpanded: false, onTap: () {}),
      ),
    );

    expect(find.text(student.initials), findsOneWidget);
    expect(find.text(student.displayName), findsOneWidget);
    expect(find.text(student.avgScore.toStringAsFixed(1)), findsOneWidget);
    expect(find.byType(RadarChartWidget), findsNothing);
  });

  testWidgets('renders expanded details and comments', (tester) async {
    final student = buildStudentSummary();

    await tester.pumpWidget(
      wrapForTest(
        SingleChildScrollView(
          child: StudentSummaryTile(
            student: student,
            isExpanded: true,
            onTap: () {},
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(RadarChartWidget), findsOneWidget);
    expect(find.text('Punctuality'), findsOneWidget);
    expect(find.text('Contributions'), findsOneWidget);
    expect(find.text('Commitment'), findsOneWidget);
    expect(find.text('Attitude'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('peer1@example.com'), findsOneWidget);
    expect(find.text('Great teammate'), findsOneWidget);
  });

  testWidgets('calls onTap from header', (tester) async {
    var tapped = false;
    final student = buildStudentSummary();

    await tester.pumpWidget(
      wrapForTest(
        StudentSummaryTile(
          student: student,
          isExpanded: false,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();

    expect(tapped, isTrue);
  });
}
