import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/auth/presentation/widgets/text_box.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/auth_fixtures.dart';

void main() {
  testWidgets('shows label and writes input', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      wrapForTest(
        Form(
          child: TextBox(
            hintText: emailHint,
            controller: controller,
            validatorFunc: () =>
                (String? value) => null,
          ),
        ),
      ),
    );

    expect(find.text(emailHint), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'test@email.com');
    expect(controller.text, 'test@email.com');
  });

  testWidgets('respects obscureText configuration', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      wrapForTest(
        TextBox(
          hintText: passwordHint,
          controller: controller,
          obscureText: true,
          validatorFunc: () =>
              (String? value) => null,
        ),
      ),
    );

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
  });
}
