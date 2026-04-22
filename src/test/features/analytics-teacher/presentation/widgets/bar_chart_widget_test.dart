import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/analytics-teacher/presentation/widgets/bar_chart_widget.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/analytics_teacher_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('renders y-axis and x-axis labels', (tester) async {
    final entries = buildBarEntries();

    await tester.pumpWidget(wrapForTest(BarChartWidget(entries: entries)));

    expect(find.text('1.25'), findsOneWidget);
    expect(find.text('3.75'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    for (final entry in entries) {
      expect(find.text(entry.label), findsOneWidget);
    }
  });

  testWidgets('renders custom paint chart area', (tester) async {
    final entries = buildBarEntries();

    await tester.pumpWidget(
      wrapForTest(BarChartWidget(entries: entries, barColor: Colors.red)),
    );

    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });
}
