import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/analytics-student/presentation/widgets/radar_chart_widget.dart';

import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('renders chart and all axis labels', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const RadarChartWidget(
          punctuality: 4.2,
          contributions: 3.9,
          commitment: 4.0,
          attitude: 4.5,
        ),
      ),
    );

    expect(find.byType(RadarChartWidget), findsOneWidget);
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    expect(find.text('Punc'), findsOneWidget);
    expect(find.text('Cont'), findsOneWidget);
    expect(find.text('Comm'), findsOneWidget);
    expect(find.text('Atti'), findsOneWidget);
  });
}
