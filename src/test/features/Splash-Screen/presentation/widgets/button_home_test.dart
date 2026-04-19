import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/Splash-Screen/presentation/widgets/button_home.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/splash_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('renders button text', (tester) async {
    await tester.pumpWidget(
      wrapForTest(ButtonHome(onPressed: () {}, text: splashPrimaryActionText)),
    );

    expect(find.text(splashPrimaryActionText), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('triggers callback on tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      wrapForTest(
        ButtonHome(
          onPressed: () => tapped = true,
          text: splashSecondaryActionText,
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
