import '../models/group_category_model.dart';

class CsvGroupParser {
  List<GroupCategoryModel> parse(String csvContent) {
    final lines = csvContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) return [];

    final header = _splitLine(lines[0]);
    final idxCat   = header.indexOf('Group Category Name');
    final idxGName = header.indexOf('Group Name');
    final idxGCode = header.indexOf('Group Code');
    final idxFName = header.indexOf('First Name');
    final idxLName = header.indexOf('Last Name');
    final idxEmail = header.indexOf('Email Address');

    if ([idxCat, idxGName, idxGCode, idxFName, idxLName, idxEmail].any((i) => i == -1)) {
      return [];
    }

    final Map<String, Map<String, dynamic>> categories = {};

    for (final line in lines.skip(1)) {
      final parts = _splitLine(line);
      if (parts.length <= idxEmail) continue;

      final catName   = parts[idxCat];
      final groupName = parts[idxGName];
      final groupCode = parts[idxGCode];
      final firstName = parts[idxFName];
      final lastName  = parts[idxLName];
      final email     = parts[idxEmail];

      categories.putIfAbsent(catName, () => {
        'name': catName,
        'source': 'Brightspace',
        'groups': <String, Map<String, dynamic>>{},
      });

      final groups = categories[catName]!['groups'] as Map<String, Map<String, dynamic>>;
      groups.putIfAbsent(groupName, () => {
        'name': groupName,
        'code': groupCode,
        'members': <GroupMemberModel>[],
      });

      (groups[groupName]!['members'] as List<GroupMemberModel>).add(
        GroupMemberModel(firstName: firstName, lastName: lastName, email: email),
      );
    }

    return categories.values.map((cat) {
      final groups = (cat['groups'] as Map<String, Map<String, dynamic>>).values
          .map((g) => CourseGroupModel(
                name: g['name'] as String,
                code: g['code'] as String,
                members: g['members'] as List<GroupMemberModel>,
              ))
          .toList();

      return GroupCategoryModel(
        name: cat['name'] as String,
        source: cat['source'] as String,
        groups: groups,
      );
    }).toList();
  }

  List<String> _splitLine(String line) {
    final fields = <String>[];
    final current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(current.toString().trim());
        current.clear();
      } else {
        current.write(ch);
      }
    }

    fields.add(current.toString().trim());
    return fields;
  }
}
