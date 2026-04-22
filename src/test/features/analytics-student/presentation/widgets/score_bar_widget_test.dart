import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/analytics-student/presentation/widgets/score_bar_widget.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/analytics_student_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('renders label and score value', (tester) async {
    const fixture = StudentScoreFixture('Punctuality', 4.2);

    await tester.pumpWidget(
      wrapForTest(ScoreBarWidget(label: fixture.label, value: fixture.value)),
    );

    expect(find.text(fixture.label), findsOneWidget);
    expect(find.text('4.2'), findsOneWidget);
  });

  testWidgets('applies correct progress ratio', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const ScoreBarWidget(label: 'Commitment', value: 2.5, maxValue: 5),
      ),
    );

    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, 0.5);
  });
}
