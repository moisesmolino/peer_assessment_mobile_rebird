import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/home-professor/presentation/widgets/course_card.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/home_professor_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('renders main course details', (tester) async {
    final course = buildProfessorCourse();

    await tester.pumpWidget(
      wrapForTest(CourseCard(course: course, onTap: () {})),
    );

    expect(find.text(course.code), findsOneWidget);
    expect(find.text(course.name), findsOneWidget);
    expect(find.text('${course.studentsCount} students'), findsOneWidget);
    expect(
      find.text('${course.activeEvaluations} evaluations'),
      findsOneWidget,
    );
    expect(
      find.text('DS-${course.period}-${course.code.toLowerCase()}'),
      findsOneWidget,
    );
  });

  testWidgets('invokes callback when tapped', (tester) async {
    var tapped = false;
    final course = buildProfessorCourse();

    await tester.pumpWidget(
      wrapForTest(CourseCard(course: course, onTap: () => tapped = true)),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
