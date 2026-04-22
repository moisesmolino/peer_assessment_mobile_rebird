import 'dart:convert';

import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';
import 'package:src/features/home-student/domain/entities/evaluation.dart';

import '../models/course_model.dart';
import '../models/evaluation_model.dart';

class LocalHomeStudentCacheSource {
  final ILocalPreferences prefs;

  static const String _enrolledCoursesCachePrefix = 'enrolled_courses_cache';
  static const String _enrolledCoursesCacheTsPrefix =
      'enrolled_courses_cache_ts';
  static const String _activeEvaluationsCachePrefix =
      'active_evaluations_cache';
  static const String _activeEvaluationsCacheTsPrefix =
      'active_evaluations_cache_ts';
  static const int _cacheTTLMinutes = 10;

  LocalHomeStudentCacheSource(this.prefs);

  Future<bool> isEnrolledCoursesCacheValid(String studentEmail) async {
    return _isValid('${_enrolledCoursesCacheTsPrefix}_$studentEmail');
  }

  Future<bool> isActiveEvaluationsCacheValid(String studentEmail) async {
    return _isValid('${_activeEvaluationsCacheTsPrefix}_$studentEmail');
  }

  Future<List<CourseModel>?> getCachedEnrolledCourses(
    String studentEmail,
  ) async {
    try {
      final cacheKey = '${_enrolledCoursesCachePrefix}_$studentEmail';
      final encoded = await prefs.getString(cacheKey);
      if (encoded == null || encoded.isEmpty) return null;

      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map(
            (item) =>
                CourseModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      logError('Error reading enrolled courses cache: $e');
      return null;
    }
  }

  Future<void> cacheEnrolledCourses(
    String studentEmail,
    List<CourseModel> courses,
  ) async {
    try {
      final cacheKey = '${_enrolledCoursesCachePrefix}_$studentEmail';
      final cacheTsKey = '${_enrolledCoursesCacheTsPrefix}_$studentEmail';

      final payload = courses
          .map(
            (course) => {
              '_id': course.id,
              'code': course.code,
              'name': course.name,
              'period': course.period,
              'activeEvaluations': course.activeEvaluations,
            },
          )
          .toList();

      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setString(cacheTsKey, DateTime.now().toIso8601String());
    } catch (e) {
      logError('Error saving enrolled courses cache: $e');
      rethrow;
    }
  }

  Future<List<EvaluationModel>?> getCachedActiveEvaluations(
    String studentEmail,
  ) async {
    try {
      final cacheKey = '${_activeEvaluationsCachePrefix}_$studentEmail';
      final encoded = await prefs.getString(cacheKey);
      if (encoded == null || encoded.isEmpty) return null;

      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded.map((item) {
        final json = Map<String, dynamic>.from(item as Map);
        return EvaluationModel(
          id: json['id'] as String,
          courseCode: json['courseCode'] as String,
          title: json['title'] as String,
          courseName: json['courseName'] as String,
          status: (json['status'] as String) == 'open'
              ? EvaluationStatus.open
              : EvaluationStatus.closed,
          timeRemaining: json['timeRemaining'] as String,
          groupCategory: json['groupCategory'] as String,
          deadline: DateTime.parse(json['deadline'] as String),
        );
      }).toList();
    } catch (e) {
      logError('Error reading active evaluations cache: $e');
      return null;
    }
  }

  Future<void> cacheActiveEvaluations(
    String studentEmail,
    List<EvaluationModel> evaluations,
  ) async {
    try {
      final cacheKey = '${_activeEvaluationsCachePrefix}_$studentEmail';
      final cacheTsKey = '${_activeEvaluationsCacheTsPrefix}_$studentEmail';

      final payload = evaluations
          .map(
            (evaluation) => {
              'id': evaluation.id,
              'courseCode': evaluation.courseCode,
              'title': evaluation.title,
              'courseName': evaluation.courseName,
              'status': evaluation.status == EvaluationStatus.open
                  ? 'open'
                  : 'closed',
              'timeRemaining': evaluation.timeRemaining,
              'groupCategory': evaluation.groupCategory,
              'deadline': evaluation.deadline.toIso8601String(),
            },
          )
          .toList();

      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setString(cacheTsKey, DateTime.now().toIso8601String());
    } catch (e) {
      logError('Error saving active evaluations cache: $e');
      rethrow;
    }
  }

  Future<bool> _isValid(String timestampKey) async {
    try {
      final timestampStr = await prefs.getString(timestampKey);
      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final ageMinutes = DateTime.now().difference(timestamp).inMinutes;
      return ageMinutes < _cacheTTLMinutes;
    } catch (e) {
      logError('Error checking cache validity: $e');
      return false;
    }
  }
}
