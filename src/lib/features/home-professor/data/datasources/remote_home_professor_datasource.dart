import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';
import 'package:src/features/home-professor/data/datasources/home_professor_datasource.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:src/features/home-professor/domain/entities/course.dart';

class RemoteHomeProfessorDataSource implements HomeProfessorDataSource {
  final http.Client httpClient;

  static const int _assignedCoursesTtlMs = 10 * 60 * 1000;
  static const String _assignedCoursesCachePrefix = 'assigned_courses_cache';
  static const String _assignedCoursesCacheTsPrefix =
      'assigned_courses_cache_ts';

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: "NO_ENV",
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';
  String get contractUrl => '$baseUrl/$contract';
  final String table = 'cursos';

  RemoteHomeProfessorDataSource(this.httpClient);

  /* @override
  Future<List<CourseModel>> getAssignedCourses(String professorId) async {
    return [
      CourseModel(
        id: "1",
        code: "COMP-2201",
        name: "Software design",
        period: "2026-10",
        studentsCount: 30,
        activeEvaluations: 2,
      ),

      CourseModel(
        id: "2",
        code: "ISTI-3401",
        name: "Data structures",
        period: "2026-10",
        studentsCount: 36,
        activeEvaluations: 3,
      ),
    ];
  } */

  @override
  Future<List<Course>> getAssignedCourses(String professorId) async {
    final ILocalPreferences prefs = Get.find();

    final cachedCourses = await _getCachedAssignedCourses(prefs, professorId);
    if (cachedCourses != null) {
      return cachedCourses;
    }

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'profid': professorId,
    });
    final token = await prefs.getString('token');
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      final List<Course> courses = List<Course>.from(
        decodedJson.map((x) => Course.fromJson(x)),
      );
      await _setCachedAssignedCourses(prefs, professorId, decodedJson);
      return Future.value(courses);
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  Future<List<Course>?> _getCachedAssignedCourses(
    ILocalPreferences prefs,
    String professorId,
  ) async {
    final cacheKey = '${_assignedCoursesCachePrefix}_$professorId';
    final cacheTsKey = '${_assignedCoursesCacheTsPrefix}_$professorId';
    final cachedPayload = await prefs.getString(cacheKey);
    final cacheTimestamp = await prefs.getInt(cacheTsKey);

    if (cachedPayload == null || cacheTimestamp == null) {
      return null;
    }

    final isExpired =
        DateTime.now().millisecondsSinceEpoch - cacheTimestamp >
        _assignedCoursesTtlMs;
    if (isExpired) {
      return null;
    }

    try {
      final List<dynamic> decoded = jsonDecode(cachedPayload);
      return List<Course>.from(decoded.map((x) => Course.fromJson(x)));
    } catch (e) {
      logError('getAssignedCourses cache decode error: $e');
      return null;
    }
  }

  Future<void> _setCachedAssignedCourses(
    ILocalPreferences prefs,
    String professorId,
    List<dynamic> payload,
  ) async {
    final cacheKey = '${_assignedCoursesCachePrefix}_$professorId';
    final cacheTsKey = '${_assignedCoursesCacheTsPrefix}_$professorId';

    try {
      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      logError('getAssignedCourses cache store error: $e');
    }
  }
}
