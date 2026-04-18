import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:src/features/tap-on-course/data/models/course_evaluation_model.dart';
import 'package:src/features/tap-on-course/data/models/group_category_model.dart';
import 'package:src/features/tap-on-course/data/parsers/csv_group_parser.dart';
import 'tap_course_datasource.dart';

class RemoteTapCourseDatasource implements TapCourseDatasource {
  final http.Client httpClient;
  final CsvGroupParser csvParser;

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: "NO_ENV",
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  RemoteTapCourseDatasource(this.httpClient, this.csvParser);

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    // RefreshClient agrega Authorization automáticamente
  };

  @override
  Future<List<CourseEvaluationModel>> getCourseEvaluations(String courseId) async {
    final uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'evaluations',
      'course_id': courseId,
    });

    final response = await httpClient.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      logError('getCourseEvaluations error ${response.statusCode}: ${response.body}');
      return Future.error('Error fetching evaluations: ${response.statusCode}');
    }

    final List<dynamic> json = jsonDecode(response.body);
    final rows = json.cast<Map<String, dynamic>>();
    await _closeExpiredEvaluations(rows);
    return rows.map(CourseEvaluationModel.fromJson).toList();
  }

  Future<void> _closeExpiredEvaluations(List<Map<String, dynamic>> rows) async {
    final now = DateTime.now();
    for (final row in rows) {
      if (row['status'] != 'active') continue;
      final deadline = DateTime.tryParse(row['deadline'] as String? ?? '');
      if (deadline == null || deadline.isAfter(now)) continue;

      final id = row['_id']?.toString();
      if (id == null) continue;

      final uri = Uri.https(baseUrl, '/database/$contract/update');
      final response = await httpClient.put(
        uri,
        headers: _headers,
        body: jsonEncode({
          'tableName': 'evaluations',
          'idColumn': '_id',
          'idValue': id,
          'updates': {'status': 'closed'},
        }),
      );

      if (response.statusCode == 200) {
        row['status'] = 'closed';
      } else {
        logError('_closeExpiredEvaluations error ${response.statusCode}: ${response.body}');
      }
    }
  }

  @override
  Future<List<GroupCategoryModel>> getCourseGroups(String courseId) async {
    // GET group_categories filtrando por course_id
    final categoriesUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'group_categories',
      'course_id': courseId,
    });

    final categoriesResponse = await httpClient.get(categoriesUri, headers: _headers);

    if (categoriesResponse.statusCode != 200) {
      logError('getCourseGroups categories error ${categoriesResponse.statusCode}');
      return Future.error('Error fetching group_categories: ${categoriesResponse.statusCode}');
    }

    final List<dynamic> categoriesJson = jsonDecode(categoriesResponse.body);

    // Por cada categoría a GET grupitos filtrando por GroupCategory
    final List<GroupCategoryModel> result = [];

    for (final categoryJson in categoriesJson) {
      final categoryName = categoryJson['name'] as String;

      final grupitosUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'grupitos',
        'GroupCategory': categoryName,
      });

      final grupitosResponse = await httpClient.get(grupitosUri, headers: _headers);

      if (grupitosResponse.statusCode != 200) {
        logError('getCourseGroups grupitos error ${grupitosResponse.statusCode}');
        continue;
      }

      final List<dynamic> rows = jsonDecode(grupitosResponse.body);

      // Agrupar filas por Groupname
      final Map<String, List<dynamic>> byGroup = {};
      for (final row in rows) {
        final groupName = row['Groupname'] as String;
        byGroup.putIfAbsent(groupName, () => []).add(row);
      }

      final List<CourseGroupModel> groups = byGroup.entries.map((entry) {
        final members = entry.value.map((row) => GroupMemberModel(
          firstName: row['FirstName'] as String,
          lastName:  row['LastName']  as String,
          email:     row['correo']    as String,
        )).toList();

        return CourseGroupModel(
          name:    entry.key,
          code:    entry.value.first['GroupCode'] as String,
          members: members,
        );
      }).toList();

      result.add(GroupCategoryModel(
        name:   categoryName,
        source: categoryJson['source'] as String,
        groups: groups,
      ));
    }

    return result;
  }

  @override
  Future<List<GroupCategoryModel>> importGroupsFromCsv(
    String csvContent,
    String courseId,
  ) async {
    final categories = csvParser.parse(csvContent);

    // Fetch category names already stored for this course
    final existingUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'group_categories',
      'course_id': courseId,
    });
    final existingResponse = await httpClient.get(existingUri, headers: _headers);

    final Set<String> existingNames = {};
    if (existingResponse.statusCode == 200) {
      final List<dynamic> existing = jsonDecode(existingResponse.body);
      existingNames.addAll(existing.map((e) => e['name'] as String));
    }

    // Only keep categories that are not yet in the db
    final newCategories = categories.where((c) => !existingNames.contains(c.name)).toList();

    if (newCategories.isEmpty) return [];

    for (final category in newCategories) {
      await _insertGroupCategory(courseId: courseId, name: category.name);
    }

    await _insertGrupitos(categories: newCategories);

    return newCategories;
  }

  Future<void> _insertGroupCategory({
    required String courseId,
    required String name,
  }) async {
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final body = jsonEncode({
      "tableName": "group_categories",
      "records": [
        {
          "course_id": courseId,
          "name": name,
          "source": "CSV",
          "created_at": DateTime.now().toIso8601String(),
        }
      ],
    });

    final response = await httpClient.post(uri, headers: _headers, body: body);

    if (response.statusCode != 201) {
      logError("_insertGroupCategory error ${response.statusCode}: ${response.body}");
      return Future.error('Error inserting group_category: ${response.statusCode}');
    }
  }

  Future<void> _insertGrupitos({
    required List<GroupCategoryModel> categories,
  }) async {
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final records = <Map<String, dynamic>>[];

    for (final category in categories) {
      for (final group in category.groups) {
        for (final member in group.members) {
          records.add({
            "GroupCategory": category.name,
            "Groupname":     group.name,
            "GroupCode":     group.code,
            "FirstName":     member.firstName,
            "LastName":      member.lastName,
            "correo":        member.email,
          });
        }
      }
    }

    final body = jsonEncode({
      "tableName": "grupitos",
      "records": records,
    });

    final response = await httpClient.post(uri, headers: _headers, body: body);

    if (response.statusCode != 201) {
      logError("_insertGrupitos error ${response.statusCode}: ${response.body}");
      return Future.error('Error inserting grupitos: ${response.statusCode}');
    }
  }
}