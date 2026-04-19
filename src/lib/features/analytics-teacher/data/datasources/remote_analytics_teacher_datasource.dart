import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';
import '../models/teacher_analytics_model.dart';
import 'i_analytics_teacher_datasource.dart';

class RemoteAnalyticsTeacherDatasource implements IAnalyticsTeacherDatasource {
  final http.Client httpClient;

  static const int _analyticsTtlMs = 10 * 60 * 1000;
  static const String _courseAnalyticsCachePrefix = 'teacher_analytics_cache';
  static const String _courseAnalyticsCacheTsPrefix =
      'teacher_analytics_cache_ts';

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
    final ILocalPreferences prefs = Get.find();

    final cachedResult = await _getCachedCourseAnalytics(
      prefs,
      courseId,
      evalIdToName,
    );
    if (cachedResult != null) {
      return cachedResult;
    }

    final results = await Future.wait([
      _fetchAllResponses(evalIdToName.keys.toList()),
      _fetchEmailMaps(courseId),
    ]);

    final allRows = results[0] as List<Map<String, dynamic>>;
    final maps = results[1] as _EmailMaps;

    final model = TeacherAnalyticsModel(
      rows: allRows,
      emailToDisplayName: maps.emailToDisplayName,
      emailToGroupName: maps.emailToGroupName,
      evalIdToName: evalIdToName,
    );

    await _setCachedCourseAnalytics(
      prefs,
      courseId,
      allRows,
      maps,
      evalIdToName,
    );

    return allRows.isEmpty ? null : model;
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

  String _evalcachekey(
    String prefix,
    String courseId,
    Map<String, String> evalIdToName,
  ) {
    final ids = evalIdToName.keys.toList()..sort();
    final idsPart = ids.join('|');
    return '${prefix}_${courseId}_$idsPart';
  }

  Future<TeacherAnalyticsModel?> _getCachedCourseAnalytics(
    ILocalPreferences prefs,
    String courseId,
    Map<String, String> evalIdToName,
  ) async {
    final cacheKey = _evalcachekey(
      _courseAnalyticsCachePrefix,
      courseId,
      evalIdToName,
    );
    final cacheTsKey = _evalcachekey(
      _courseAnalyticsCacheTsPrefix,
      courseId,
      evalIdToName,
    );
    final cachedPayload = await prefs.getString(cacheKey);
    final cacheTimestamp = await prefs.getInt(cacheTsKey);

    if (cachedPayload == null || cacheTimestamp == null) {
      return null;
    }

    final isExpired =
        DateTime.now().millisecondsSinceEpoch - cacheTimestamp >
        _analyticsTtlMs;
    if (isExpired) {
      return null;
    }

    try {
      final decoded = jsonDecode(cachedPayload) as Map<String, dynamic>;
      final rowsList =
          (decoded['rows'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
          [];
      final emailToDisplayName = Map<String, String>.from(
        decoded['emailToDisplayName'] as Map? ?? {},
      );
      final emailToGroupName = Map<String, String>.from(
        decoded['emailToGroupName'] as Map? ?? {},
      );

      final model = TeacherAnalyticsModel(
        rows: rowsList,
        emailToDisplayName: emailToDisplayName,
        emailToGroupName: emailToGroupName,
        evalIdToName: evalIdToName,
      );

      return rowsList.isEmpty ? null : model;
    } catch (e) {
      logError('fetchCourseAnalytics cache decode error: $e');
      return null;
    }
  }

  Future<void> _setCachedCourseAnalytics(
    ILocalPreferences prefs,
    String courseId,
    List<Map<String, dynamic>> allRows,
    _EmailMaps maps,
    Map<String, String> evalIdToName,
  ) async {
    final cacheKey = _evalcachekey(
      _courseAnalyticsCachePrefix,
      courseId,
      evalIdToName,
    );
    final cacheTsKey = _evalcachekey(
      _courseAnalyticsCacheTsPrefix,
      courseId,
      evalIdToName,
    );

    try {
      final payload = {
        'rows': allRows,
        'emailToDisplayName': maps.emailToDisplayName,
        'emailToGroupName': maps.emailToGroupName,
      };
      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      logError('fetchCourseAnalytics cache store error: $e');
    }
  }
}

class _EmailMaps {
  final Map<String, String> emailToDisplayName;
  final Map<String, String> emailToGroupName;

  _EmailMaps(this.emailToDisplayName, this.emailToGroupName);
}
