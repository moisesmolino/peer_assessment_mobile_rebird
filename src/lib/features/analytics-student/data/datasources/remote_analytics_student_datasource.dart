import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';
import '../models/student_analytics_model.dart';
import 'i_analytics_student_datasource.dart';

class RemoteAnalyticsStudentDatasource implements IAnalyticsStudentDatasource {
  final http.Client httpClient;

  static const int _analyticsTtlMs = 10 * 60 * 1000;
  static const String _analyticsCachePrefix = 'student_analytics_cache';
  static const String _analyticsCacheTsPrefix = 'student_analytics_cache_ts';

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: 'NO_ENV',
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  RemoteAnalyticsStudentDatasource(this.httpClient);

  @override
  Future<StudentAnalyticsModel?> fetchResults({
    required String evaluationId,
    required String studentEmail,
  }) async {
    final ILocalPreferences prefs = Get.find();

    final cachedResult = await _getCachedResults(
      prefs,
      evaluationId,
      studentEmail,
    );
    if (cachedResult != null) {
      return cachedResult;
    }

    final uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'responses',
      'evaluation_id': evaluationId,
      'evaluated_email': studentEmail,
    });

    final response = await httpClient.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      logError('fetchResults error ${response.statusCode}');
      return Future.error('Error fetching analytics: ${response.statusCode}');
    }

    final rows = (jsonDecode(response.body) as List)
        .cast<Map<String, dynamic>>();
    if (rows.isEmpty) return null;

    final result = StudentAnalyticsModel.fromRows(rows);
    await _setCachedResults(prefs, evaluationId, studentEmail, rows);
    return result;
  }

  Future<StudentAnalyticsModel?> _getCachedResults(
    ILocalPreferences prefs,
    String evaluationId,
    String studentEmail,
  ) async {
    final cacheKey = '${_analyticsCachePrefix}_${evaluationId}_$studentEmail';
    final cacheTsKey =
        '${_analyticsCacheTsPrefix}_${evaluationId}_$studentEmail';
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
      final List<dynamic> decoded = jsonDecode(cachedPayload);
      final rows = decoded.cast<Map<String, dynamic>>();
      return StudentAnalyticsModel.fromRows(rows);
    } catch (e) {
      logError('fetchResults cache decode error: $e');
      return null;
    }
  }

  Future<void> _setCachedResults(
    ILocalPreferences prefs,
    String evaluationId,
    String studentEmail,
    List<Map<String, dynamic>> payload,
  ) async {
    final cacheKey = '${_analyticsCachePrefix}_${evaluationId}_$studentEmail';
    final cacheTsKey =
        '${_analyticsCacheTsPrefix}_${evaluationId}_$studentEmail';

    try {
      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      logError('fetchResults cache store error: $e');
    }
  }
}
