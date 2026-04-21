import 'dart:convert';

import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';
import 'package:src/features/home-professor/domain/entities/course.dart';

class LocalHomeProfessorCacheSource {
  final ILocalPreferences prefs;

  static const String _assignedCoursesCachePrefix = 'assigned_courses_cache';
  static const String _assignedCoursesCacheTsPrefix =
      'assigned_courses_cache_ts';
  static const int _cacheTTLMinutes = 10;

  LocalHomeProfessorCacheSource(this.prefs);

  Future<bool> isAssignedCoursesCacheValid(String professorId) async {
    try {
      final cacheTsKey = '${_assignedCoursesCacheTsPrefix}_$professorId';
      final timestampStr = await prefs.getString(cacheTsKey);
      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final ageMinutes = DateTime.now().difference(timestamp).inMinutes;
      return ageMinutes < _cacheTTLMinutes;
    } catch (e) {
      logError('Error checking assigned courses cache validity: $e');
      return false;
    }
  }

  Future<List<Course>?> getCachedAssignedCourses(String professorId) async {
    try {
      final cacheKey = '${_assignedCoursesCachePrefix}_$professorId';
      final encoded = await prefs.getString(cacheKey);
      if (encoded == null || encoded.isEmpty) return null;

      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map(
            (item) => Course.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      logError('Error reading assigned courses cache: $e');
      return null;
    }
  }

  Future<void> cacheAssignedCourses(
    String professorId,
    List<Course> courses,
  ) async {
    try {
      final cacheKey = '${_assignedCoursesCachePrefix}_$professorId';
      final cacheTsKey = '${_assignedCoursesCacheTsPrefix}_$professorId';

      await prefs.setString(
        cacheKey,
        jsonEncode(courses.map((course) => course.toJson()).toList()),
      );
      await prefs.setString(cacheTsKey, DateTime.now().toIso8601String());
    } catch (e) {
      logError('Error saving assigned courses cache: $e');
      rethrow;
    }
  }
}
