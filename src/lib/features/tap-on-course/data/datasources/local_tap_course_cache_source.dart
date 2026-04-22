import 'dart:convert';

import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';

import '../models/course_evaluation_model.dart';
import '../models/group_category_model.dart';

class LocalTapCourseCacheSource {
  final ILocalPreferences prefs;

  static const String _courseEvaluationsCachePrefix =
      'tap_course_evaluations_cache';
  static const String _courseEvaluationsCacheTsPrefix =
      'tap_course_evaluations_cache_ts';
  static const String _courseGroupsCachePrefix = 'tap_course_groups_cache';
  static const String _courseGroupsCacheTsPrefix = 'tap_course_groups_cache_ts';
  static const int _cacheTTLMinutes = 10;

  LocalTapCourseCacheSource(this.prefs);

  Future<bool> isCourseEvaluationsCacheValid(String courseId) async {
    return _isValid('${_courseEvaluationsCacheTsPrefix}_$courseId');
  }

  Future<bool> isCourseGroupsCacheValid(String courseId) async {
    return _isValid('${_courseGroupsCacheTsPrefix}_$courseId');
  }

  Future<List<CourseEvaluationModel>?> getCachedCourseEvaluations(
    String courseId,
  ) async {
    try {
      final cacheKey = '${_courseEvaluationsCachePrefix}_$courseId';
      final encoded = await prefs.getString(cacheKey);
      if (encoded == null || encoded.isEmpty) return null;

      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map(
            (item) => CourseEvaluationModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (e) {
      logError('Error reading course evaluations cache: $e');
      return null;
    }
  }

  Future<void> cacheCourseEvaluations(
    String courseId,
    List<CourseEvaluationModel> evaluations,
  ) async {
    try {
      final cacheKey = '${_courseEvaluationsCachePrefix}_$courseId';
      final cacheTsKey = '${_courseEvaluationsCacheTsPrefix}_$courseId';

      final payload = evaluations
          .map(
            (evaluation) => {
              '_id': evaluation.id,
              'name': evaluation.name,
              'status': evaluation.status,
              'visibility': evaluation.visibility,
              'group_category': evaluation.groupCategory,
              'deadline': evaluation.deadline.toIso8601String(),
            },
          )
          .toList();

      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setString(cacheTsKey, DateTime.now().toIso8601String());
    } catch (e) {
      logError('Error saving course evaluations cache: $e');
      rethrow;
    }
  }

  Future<void> invalidateCourseEvaluationsCache(String courseId) async {
    try {
      await prefs.remove('${_courseEvaluationsCachePrefix}_$courseId');
      await prefs.remove('${_courseEvaluationsCacheTsPrefix}_$courseId');
    } catch (e) {
      logError('Error invalidating course evaluations cache: $e');
      rethrow;
    }
  }

  Future<List<GroupCategoryModel>?> getCachedCourseGroups(
    String courseId,
  ) async {
    try {
      final cacheKey = '${_courseGroupsCachePrefix}_$courseId';
      final encoded = await prefs.getString(cacheKey);
      if (encoded == null || encoded.isEmpty) return null;

      final decoded = jsonDecode(encoded) as List<dynamic>;
      return _deserializeGroupCategories(decoded);
    } catch (e) {
      logError('Error reading course groups cache: $e');
      return null;
    }
  }

  Future<void> cacheCourseGroups(
    String courseId,
    List<GroupCategoryModel> groups,
  ) async {
    try {
      final cacheKey = '${_courseGroupsCachePrefix}_$courseId';
      final cacheTsKey = '${_courseGroupsCacheTsPrefix}_$courseId';

      await prefs.setString(
        cacheKey,
        jsonEncode(_serializeGroupCategories(groups)),
      );
      await prefs.setString(cacheTsKey, DateTime.now().toIso8601String());
    } catch (e) {
      logError('Error saving course groups cache: $e');
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
      logError('Error checking tap-on-course cache validity: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> _serializeGroupCategories(
    List<GroupCategoryModel> categories,
  ) {
    return categories
        .map(
          (category) => {
            'name': category.name,
            'source': category.source,
            'groups': category.groups
                .map(
                  (group) => {
                    'name': group.name,
                    'code': group.code,
                    'members': group.members
                        .map(
                          (member) => {
                            'firstName': member.firstName,
                            'lastName': member.lastName,
                            'email': member.email,
                          },
                        )
                        .toList(),
                  },
                )
                .toList(),
          },
        )
        .toList();
  }

  List<GroupCategoryModel> _deserializeGroupCategories(List<dynamic> decoded) {
    return decoded.map((categoryItem) {
      final categoryJson = Map<String, dynamic>.from(categoryItem as Map);
      final groupsJson = (categoryJson['groups'] as List<dynamic>? ?? []);

      final groups = groupsJson.map((groupItem) {
        final groupJson = Map<String, dynamic>.from(groupItem as Map);
        final membersJson = (groupJson['members'] as List<dynamic>? ?? []);

        final members = membersJson.map((memberItem) {
          final memberJson = Map<String, dynamic>.from(memberItem as Map);
          return GroupMemberModel(
            firstName: memberJson['firstName'] as String? ?? '',
            lastName: memberJson['lastName'] as String? ?? '',
            email: memberJson['email'] as String? ?? '',
          );
        }).toList();

        return CourseGroupModel(
          name: groupJson['name'] as String? ?? '',
          code: groupJson['code'] as String? ?? '',
          members: members,
        );
      }).toList();

      return GroupCategoryModel(
        name: categoryJson['name'] as String? ?? '',
        source: categoryJson['source'] as String? ?? '',
        groups: groups,
      );
    }).toList();
  }
}
