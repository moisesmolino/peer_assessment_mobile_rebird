import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/home-student/presentation/widgets/course_card.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/home_student_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('renders course information and active badge', (tester) async {
    final course = buildHomeStudentCourse();

    await tester.pumpWidget(
      wrapForTest(CourseCard(course: course, onTap: () {})),
    );

    expect(find.text(course.code), findsOneWidget);
    expect(find.text(course.name), findsOneWidget);
    expect(find.text(course.period), findsOneWidget);
    expect(find.text('${course.activeEvaluations} active'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('calls onTap when card is tapped', (tester) async {
    var tapped = false;
    final course = buildHomeStudentCourse();

    await tester.pumpWidget(
      wrapForTest(CourseCard(course: course, onTap: () => tapped = true)),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
