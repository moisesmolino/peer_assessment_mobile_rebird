import 'dart:convert';

import 'package:src/core/i_local_preferences.dart';
import 'package:loggy/loggy.dart';

import '../models/student_analytics_model.dart';

class LocalAnalyticsStudentCacheSource {
  final ILocalPreferences prefs;

  static const String _cacheKeyPrefix = 'student_analytics_cache';
  static const String _cacheTimestampKeyPrefix = 'student_analytics_cache_ts';
  static const int _cacheTTLMinutes = 10;

  LocalAnalyticsStudentCacheSource(this.prefs);

  Future<bool> isCacheValid(String evaluationId, String studentEmail) async {
    try {
      final cacheTsKey =
          '${_cacheTimestampKeyPrefix}_${evaluationId}_$studentEmail';
      final timestampStr = await prefs.getString(cacheTsKey);

      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final difference = DateTime.now().difference(timestamp).inMinutes;
      final isValid = difference < _cacheTTLMinutes;

      logInfo(
        '⏱️ Analytics cache age: ${difference}m / TTL: ${_cacheTTLMinutes}m → ${isValid ? "VALID" : "EXPIRED"}',
      );

      return isValid;
    } catch (e) {
      logError('Error checking analytics cache validity: $e');
      return false;
    }
  }

  Future<void> cacheAnalyticsData(
    String evaluationId,
    String studentEmail,
    StudentAnalyticsModel model,
  ) async {
    try {
      final cacheKey = '${_cacheKeyPrefix}_${evaluationId}_$studentEmail';
      final cacheTsKey =
          '${_cacheTimestampKeyPrefix}_${evaluationId}_$studentEmail';

      final modelJson = {
        'punctuality': model.punctuality,
        'contributions': model.contributions,
        'commitment': model.commitment,
        'attitude': model.attitude,
        'comments': model.comments
            .map(
              (c) => {'evaluator_email': c.evaluatorEmail, 'comment': c.text},
            )
            .toList(),
      };

      final encoded = jsonEncode(modelJson);

      await prefs.setString(cacheKey, encoded);
      await prefs.setString(cacheTsKey, DateTime.now().toIso8601String());

      logInfo('💾 Analytics cache saved');
    } catch (e) {
      logError('Error saving analytics cache: $e');
      rethrow;
    }
  }

  Future<StudentAnalyticsModel?> getCachedAnalyticsData(
    String evaluationId,
    String studentEmail,
  ) async {
    try {
      final cacheKey = '${_cacheKeyPrefix}_${evaluationId}_$studentEmail';
      final encoded = await prefs.getString(cacheKey);

      if (encoded == null || encoded.isEmpty) {
        logInfo('📊 No analytics cache found');
        return null;
      }

      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final comments =
          (decoded['comments'] as List?)
              ?.map(
                (c) =>
                    EvaluatorCommentModel.fromJson(c as Map<String, dynamic>),
              )
              .toList() ??
          [];

      final result = StudentAnalyticsModel(
        punctuality: (decoded['punctuality'] as num).toDouble(),
        contributions: (decoded['contributions'] as num).toDouble(),
        commitment: (decoded['commitment'] as num).toDouble(),
        attitude: (decoded['attitude'] as num).toDouble(),
        comments: comments,
      );

      logInfo('📊 Analytics cache loaded');
      return result;
    } catch (e) {
      logError('Error reading analytics cache: $e');
      return null;
    }
  }

  Future<void> clearCache(String evaluationId, String studentEmail) async {
    try {
      final cacheKey = '${_cacheKeyPrefix}_${evaluationId}_$studentEmail';
      final cacheTsKey =
          '${_cacheTimestampKeyPrefix}_${evaluationId}_$studentEmail';

      await prefs.remove(cacheKey);
      await prefs.remove(cacheTsKey);
      logInfo('🗑️ Analytics cache invalidated');
    } catch (e) {
      logError('Error invalidating analytics cache: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      // This would need to be implemented if you want to clear all analytics caches
      // For now, individual caches can be cleared with clearCache()
      logInfo('🗑️ All analytics caches would be cleared');
    } catch (e) {
      logError('Error invalidating all analytics caches: $e');
    }
  }
}
