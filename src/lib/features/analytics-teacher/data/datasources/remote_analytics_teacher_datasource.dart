import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import '../models/teacher_analytics_model.dart';
import 'i_analytics_teacher_datasource.dart';

class RemoteAnalyticsTeacherDatasource implements IAnalyticsTeacherDatasource {
  final http.Client httpClient;

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: 'NO_ENV',
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  RemoteAnalyticsTeacherDatasource(this.httpClient);

  @override
  Future<TeacherAnalyticsModel?> fetchCourseAnalytics({
    required String courseId,
    required Map<String, String> evalIdToName,
  }) async {
    final results = await Future.wait([
      _fetchAllResponses(evalIdToName.keys.toList()),
      _fetchEmailMaps(courseId),
    ]);

    final allRows = results[0] as List<Map<String, dynamic>>;
    final maps = results[1] as _EmailMaps;

    if (allRows.isEmpty) return null;

    final model = TeacherAnalyticsModel(
      rows: allRows,
      emailToDisplayName: maps.emailToDisplayName,
      emailToGroupName: maps.emailToGroupName,
      evalIdToName: evalIdToName,
    );

    return model;
  }

  Future<List<Map<String, dynamic>>> _fetchAllResponses(
    List<String> evaluationIds,
  ) async {
    final futures = evaluationIds.map((id) async {
      final uri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'responses',
        'evaluation_id': id,
      });
      final response = await httpClient.get(uri, headers: _headers);
      if (response.statusCode != 200) {
        logError('fetchResponses error ${response.statusCode} for eval $id');
        return <Map<String, dynamic>>[];
      }
      final rows = (jsonDecode(response.body) as List)
          .cast<Map<String, dynamic>>();
      // Stamp evaluation_id on each row so the model can group by it
      for (final r in rows) {
        r['evaluation_id'] ??= id;
      }
      return rows;
    });

    final nested = await Future.wait(futures);
    return nested.expand((r) => r).toList();
  }

  Future<_EmailMaps> _fetchEmailMaps(String courseId) async {
    final catUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'group_categories',
      'course_id': courseId,
    });
    final catResponse = await httpClient.get(catUri, headers: _headers);

    if (catResponse.statusCode != 200) {
      logError('fetchEmailMaps categories error ${catResponse.statusCode}');
      return _EmailMaps({}, {});
    }

    final categories = (jsonDecode(catResponse.body) as List)
        .cast<Map<String, dynamic>>();

    final Map<String, String> emailToDisplayName = {};
    final Map<String, String> emailToGroupName = {};

    await Future.wait(
      categories.map((cat) async {
        final groupUri = Uri.https(baseUrl, '/database/$contract/read', {
          'tableName': 'grupitos',
          'GroupCategory': cat['name'] as String,
        });
        final groupResponse = await httpClient.get(groupUri, headers: _headers);
        if (groupResponse.statusCode != 200) return;

        final members = (jsonDecode(groupResponse.body) as List)
            .cast<Map<String, dynamic>>();
        for (final m in members) {
          final email = m['correo'] as String? ?? '';
          if (email.isEmpty) continue;
          emailToDisplayName[email] = '${m['FirstName']} ${m['LastName']}'
              .trim();
          emailToGroupName[email] = m['Groupname'] as String? ?? 'Unknown';
        }
      }),
    );

    return _EmailMaps(emailToDisplayName, emailToGroupName);
  }
}

class _EmailMaps {
  final Map<String, String> emailToDisplayName;
  final Map<String, String> emailToGroupName;

  _EmailMaps(this.emailToDisplayName, this.emailToGroupName);
}
