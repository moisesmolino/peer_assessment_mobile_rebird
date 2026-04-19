import 'package:flutter_test/flutter_test.dart';
import 'package:src/features/tap-on-course/presentation/widgets/group_category_section.dart';

import '../../../../helpers/test_app.dart';
import '../../mock_data/tap_course_fixtures.dart';

void main() {
  setUpAll(configureGoogleFontsForTests);

  testWidgets('renders category, source, groups and members', (tester) async {
    final category = buildGroupCategory();

    await tester.pumpWidget(
      wrapForTest(GroupCategorySection(category: category)),
    );

    expect(find.text(category.name), findsOneWidget);
    expect(find.text(category.source), findsOneWidget);
    expect(find.text(category.groups.first.name), findsOneWidget);
    expect(find.text('2 members'), findsOneWidget);

    final member = category.groups.first.members.first;
    expect(find.text(member.fullName), findsOneWidget);
    expect(find.text(member.email), findsOneWidget);
    expect(find.text(member.initials), findsOneWidget);
  });
}
