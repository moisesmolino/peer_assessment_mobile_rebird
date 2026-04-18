import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/home-student/domain/entities/evaluation.dart';
import 'package:src/features/home-student/presentation/widgets/evaluation_card.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/home_student_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('shows evaluate cta when status is open', (tester) async {
    final evaluation = buildEvaluation(status: EvaluationStatus.open);

    await tester.pumpWidget(
      wrapForTest(EvaluationCard(evaluation: evaluation, onTap: () {})),
    );

    expect(find.text(evaluation.courseCode), findsOneWidget);
    expect(find.text(evaluation.title), findsOneWidget);
    expect(find.text(evaluation.courseName), findsOneWidget);
    expect(find.text('Evaluate now →'), findsOneWidget);
  });

  testWidgets('shows view results cta when status is closed', (tester) async {
    final evaluation = buildEvaluation(status: EvaluationStatus.closed);

    await tester.pumpWidget(
      wrapForTest(EvaluationCard(evaluation: evaluation, onTap: () {})),
    );

    expect(find.text('View results →'), findsOneWidget);
  });

  testWidgets('invokes callback when button tapped', (tester) async {
    var tapped = false;
    final evaluation = buildEvaluation();

    await tester.pumpWidget(
      wrapForTest(
        EvaluationCard(evaluation: evaluation, onTap: () => tapped = true),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
