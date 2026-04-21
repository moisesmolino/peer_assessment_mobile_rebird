import 'dart:convert';

import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';

import '../models/teacher_analytics_model.dart';

class LocalAnalyticsTeacherCacheSource {
  final ILocalPreferences prefs;

  static const String _cacheKeyPrefix = 'teacher_analytics_cache';
  static const String _cacheTimestampKeyPrefix = 'teacher_analytics_cache_ts';
  static const int _cacheTTLMinutes = 10;

  LocalAnalyticsTeacherCacheSource(this.prefs);

  Future<bool> isCacheValid(
    String courseId,
    Map<String, String> evalIdToName,
  ) async {
    try {
      final cacheTsKey = _cacheKey(
        _cacheTimestampKeyPrefix,
        courseId,
        evalIdToName,
      );
      final timestampStr = await prefs.getString(cacheTsKey);
      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final difference = DateTime.now().difference(timestamp).inMinutes;
      final isValid = difference < _cacheTTLMinutes;

      logInfo(
        'Analytics teacher cache age: ${difference}m / TTL: ${_cacheTTLMinutes}m -> ${isValid ? "VALID" : "EXPIRED"}',
      );

      return isValid;
    } catch (e) {
      logError('Error checking teacher analytics cache validity: $e');
      return false;
    }
  }

  Future<void> cacheCourseAnalyticsData(
    String courseId,
    Map<String, String> evalIdToName,
    TeacherAnalyticsModel model,
  ) async {
    try {
      final cacheKey = _cacheKey(_cacheKeyPrefix, courseId, evalIdToName);
      final cacheTsKey = _cacheKey(
        _cacheTimestampKeyPrefix,
        courseId,
        evalIdToName,
      );

      final payload = {
        'rows': model.rows,
        'emailToDisplayName': model.emailToDisplayName,
        'emailToGroupName': model.emailToGroupName,
      };

      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setString(cacheTsKey, DateTime.now().toIso8601String());
      logInfo('Teacher analytics cache saved');
    } catch (e) {
      logError('Error saving teacher analytics cache: $e');
      rethrow;
    }
  }

  Future<TeacherAnalyticsModel?> getCachedCourseAnalyticsData(
    String courseId,
    Map<String, String> evalIdToName,
  ) async {
    try {
      final cacheKey = _cacheKey(_cacheKeyPrefix, courseId, evalIdToName);
      final encoded = await prefs.getString(cacheKey);
      if (encoded == null || encoded.isEmpty) return null;

      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rows = ((decoded['rows'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
      final emailToDisplayName = Map<String, String>.from(
        decoded['emailToDisplayName'] as Map? ?? {},
      );
      final emailToGroupName = Map<String, String>.from(
        decoded['emailToGroupName'] as Map? ?? {},
      );

      if (rows.isEmpty) return null;

      return TeacherAnalyticsModel(
        rows: rows,
        emailToDisplayName: emailToDisplayName,
        emailToGroupName: emailToGroupName,
        evalIdToName: evalIdToName,
      );
    } catch (e) {
      logError('Error reading teacher analytics cache: $e');
      return null;
    }
  }

  Future<void> clearCache(
    String courseId,
    Map<String, String> evalIdToName,
  ) async {
    try {
      final cacheKey = _cacheKey(_cacheKeyPrefix, courseId, evalIdToName);
      final cacheTsKey = _cacheKey(
        _cacheTimestampKeyPrefix,
        courseId,
        evalIdToName,
      );

      await prefs.remove(cacheKey);
      await prefs.remove(cacheTsKey);
    } catch (e) {
      logError('Error clearing teacher analytics cache: $e');
    }
  }

  String _cacheKey(
    String prefix,
    String courseId,
    Map<String, String> evalIdToName,
  ) {
    final ids = evalIdToName.keys.toList()..sort();
    return '${prefix}_${courseId}_${ids.join('|')}';
  }
}
