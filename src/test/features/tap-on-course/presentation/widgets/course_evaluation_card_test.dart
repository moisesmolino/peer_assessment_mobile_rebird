import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/tap-on-course/presentation/widgets/course_evaluation_card.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/tap_course_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('renders evaluation fields and evaluate cta', (tester) async {
    final evaluation = buildCourseEvaluation(
      status: 'active',
      visibility: 'public',
    );

    await tester.pumpWidget(
      wrapForTest(
        CourseEvaluationCard(evaluation: evaluation, onEvaluate: () {}),
      ),
    );

    expect(find.text(evaluation.name), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Public'), findsOneWidget);
    expect(find.text('Evaluate now →'), findsOneWidget);
  });

  testWidgets('renders closed state and view result cta', (tester) async {
    final evaluation = buildCourseEvaluation(
      status: 'closed',
      visibility: 'private',
    );

    await tester.pumpWidget(
      wrapForTest(
        CourseEvaluationCard(evaluation: evaluation, onViewResults: () {}),
      ),
    );

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('View results →'), findsOneWidget);
  });

  testWidgets('fires callback when cta is tapped', (tester) async {
    var tapped = false;
    final evaluation = buildCourseEvaluation();

    await tester.pumpWidget(
      wrapForTest(
        CourseEvaluationCard(
          evaluation: evaluation,
          onEvaluate: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Evaluate now →'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
