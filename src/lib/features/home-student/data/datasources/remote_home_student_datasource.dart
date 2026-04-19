import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:src/core/i_local_preferences.dart';
import 'package:src/features/home-student/data/datasources/home_student_datasource.dart';
import 'package:src/features/home-student/data/models/course_model.dart';
import 'package:src/features/home-student/data/models/evaluation_model.dart';

class RemoteHomeStudentDataSource implements HomeStudentDataSource {
  final http.Client httpClient;

  static const int _enrolledCoursesTtlMs = 10 * 60 * 1000;
  static const String _enrolledCoursesCachePrefix = 'enrolled_courses_cache';
  static const String _enrolledCoursesCacheTsPrefix =
      'enrolled_courses_cache_ts';
  static const int _activeEvaluationsTtlMs = 10 * 60 * 1000;
  static const String _activeEvaluationsCachePrefix =
      'active_evaluations_cache';
  static const String _activeEvaluationsCacheTsPrefix =
      'active_evaluations_cache_ts';

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: "NO_ENV",
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  RemoteHomeStudentDataSource(this.httpClient);

  /// Resolves enrolled courses for a student via this chain:
  /// 1. grupitos (correo=email)    a  unique GroupCategory names
  /// 2. group_categories (name=...) a course_id values
  /// 3. cursos (_id=course_id)     a  Course entities
  @override
  Future<List<CourseModel>> getEnrolledCourses(String studentEmail) async {
    final ILocalPreferences prefs = Get.find();

    final cachedCourses = await _getCachedEnrolledCourses(prefs, studentEmail);
    if (cachedCourses != null) {
      return cachedCourses;
    }

    final token = await prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    // find all grupitos rows where correo matches the student
    final grupitosUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'grupitos',
      'correo': studentEmail,
    });

    final grupitosResponse = await httpClient.get(
      grupitosUri,
      headers: headers,
    );

    if (grupitosResponse.statusCode != 200) {
      logError(
        'getEnrolledCourses grupitos error ${grupitosResponse.statusCode}',
      );
      return Future.error('Error ${grupitosResponse.statusCode}');
    }

    final List<dynamic> grupitos = jsonDecode(grupitosResponse.body);

    // collect unique GroupCategory names
    final Set<String> categoryNames = grupitos
        .map((g) => g['GroupCategory'] as String)
        .toSet();

    if (categoryNames.isEmpty) return [];

    // for each GroupCategory name, query group_categories to get course_id
    final Set<String> courseIds = {};

    for (final name in categoryNames) {
      final catUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'group_categories',
        'name': name,
      });

      final catResponse = await httpClient.get(catUri, headers: headers);

      if (catResponse.statusCode != 200) {
        logError(
          'getEnrolledCourses group_categories error ${catResponse.statusCode}',
        );
        continue;
      }

      final List<dynamic> categories = jsonDecode(catResponse.body);
      for (final cat in categories) {
        final courseId = cat['course_id'] as String?;
        if (courseId != null) courseIds.add(courseId);
      }
    }

    if (courseIds.isEmpty) return [];

    //fetch each course from cursos by _id
    final List<CourseModel> courses = [];
    final List<Map<String, dynamic>> coursesRaw = [];

    for (final courseId in courseIds) {
      final courseUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'cursos',
        '_id': courseId,
      });

      final courseResponse = await httpClient.get(courseUri, headers: headers);

      if (courseResponse.statusCode != 200) {
        logError(
          'getEnrolledCourses cursos error ${courseResponse.statusCode}',
        );
        continue;
      }

      final List<dynamic> rows = jsonDecode(courseResponse.body);
      for (final row in rows) {
        final json = Map<String, dynamic>.from(row as Map);
        courses.add(CourseModel.fromJson(json));
        coursesRaw.add(json);
      }
    }

    if (coursesRaw.isNotEmpty) {
      await _setCachedEnrolledCourses(prefs, studentEmail, coursesRaw);
    }

    return courses;
  }

  Future<List<CourseModel>?> _getCachedEnrolledCourses(
    ILocalPreferences prefs,
    String studentEmail,
  ) async {
    final cacheKey = '${_enrolledCoursesCachePrefix}_$studentEmail';
    final cacheTsKey = '${_enrolledCoursesCacheTsPrefix}_$studentEmail';
    final cachedPayload = await prefs.getString(cacheKey);
    final cacheTimestamp = await prefs.getInt(cacheTsKey);

    if (cachedPayload == null || cacheTimestamp == null) {
      return null;
    }

    final isExpired =
        DateTime.now().millisecondsSinceEpoch - cacheTimestamp >
        _enrolledCoursesTtlMs;
    if (isExpired) {
      return null;
    }

    try {
      final List<dynamic> decoded = jsonDecode(cachedPayload);
      return decoded
          .map(
            (item) =>
                CourseModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      logError('getEnrolledCourses cache decode error: $e');
      return null;
    }
  }

  Future<void> _setCachedEnrolledCourses(
    ILocalPreferences prefs,
    String studentEmail,
    List<Map<String, dynamic>> payload,
  ) async {
    final cacheKey = '${_enrolledCoursesCachePrefix}_$studentEmail';
    final cacheTsKey = '${_enrolledCoursesCacheTsPrefix}_$studentEmail';

    try {
      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      logError('getEnrolledCourses cache store error: $e');
    }
  }

  @override
  Future<List<EvaluationModel>> getActiveEvaluations(
    String studentEmail,
    Set<String> submittedIds,
  ) async {
    final ILocalPreferences prefs = Get.find();

    final cachedEvaluations = await _getCachedActiveEvaluations(
      prefs,
      studentEmail,
    );
    if (cachedEvaluations != null) {
      return cachedEvaluations
          .where((e) => !submittedIds.contains(e.id.toString()))
          .toList();
    }

    final token = await prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    // Get GroupCategory names for this student
    final grupitosUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'grupitos',
      'correo': studentEmail,
    });
    final grupitosResponse = await httpClient.get(
      grupitosUri,
      headers: headers,
    );
    if (grupitosResponse.statusCode != 200) {
      logError(
        'getActiveEvaluations grupitos error ${grupitosResponse.statusCode}',
      );
      return [];
    }
    final List<dynamic> grupitos = jsonDecode(grupitosResponse.body);
    final Set<String> categoryNames = grupitos
        .map((g) => g['GroupCategory'] as String)
        .toSet();
    if (categoryNames.isEmpty) return [];

    // Resolve course_ids from group_categories
    final Set<String> courseIds = {};
    for (final name in categoryNames) {
      final catUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'group_categories',
        'name': name,
      });
      final catResponse = await httpClient.get(catUri, headers: headers);
      if (catResponse.statusCode != 200) continue;
      final List<dynamic> cats = jsonDecode(catResponse.body);
      for (final cat in cats) {
        final courseId = cat['course_id'] as String?;
        if (courseId != null) courseIds.add(courseId);
      }
    }
    if (courseIds.isEmpty) return [];

    // For each course, fetch active evaluations and course info
    final List<EvaluationModel> result = [];
    final List<Map<String, dynamic>> evaluationsRaw = [];
    for (final courseId in courseIds) {
      final evalsUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'evaluations',
        'course_id': courseId,
        'status': 'active',
      });
      final evalsResponse = await httpClient.get(evalsUri, headers: headers);
      if (evalsResponse.statusCode != 200) continue;
      final List<dynamic> evals = jsonDecode(evalsResponse.body);
      if (evals.isEmpty) continue;

      final rows = evals.cast<Map<String, dynamic>>();
      await _closeExpiredEvaluations(rows, headers);
      // after closing, exclude the ones that just expired
      final stillActive = rows.where((e) => e['status'] == 'active').toList();
      if (stillActive.isEmpty) continue;

      final courseUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'cursos',
        '_id': courseId,
      });
      final courseResponse = await httpClient.get(courseUri, headers: headers);
      final Map<String, dynamic> courseJson = courseResponse.statusCode == 200
          ? ((jsonDecode(courseResponse.body) as List).firstOrNull
                    as Map<String, dynamic>? ??
                {})
          : {};

      for (final eval in stillActive) {
        result.add(EvaluationModel.fromDbJson(eval, courseJson));
        evaluationsRaw.add({
          'eval': Map<String, dynamic>.from(eval),
          'course': Map<String, dynamic>.from(courseJson),
        });
      }
    }

    if (evaluationsRaw.isNotEmpty) {
      await _setCachedActiveEvaluations(prefs, studentEmail, evaluationsRaw);
    }

    return result
        .where((e) => !submittedIds.contains(e.id.toString()))
        .toList();
  }

  Future<List<EvaluationModel>?> _getCachedActiveEvaluations(
    ILocalPreferences prefs,
    String studentEmail,
  ) async {
    final cacheKey = '${_activeEvaluationsCachePrefix}_$studentEmail';
    final cacheTsKey = '${_activeEvaluationsCacheTsPrefix}_$studentEmail';
    final cachedPayload = await prefs.getString(cacheKey);
    final cacheTimestamp = await prefs.getInt(cacheTsKey);

    if (cachedPayload == null || cacheTimestamp == null) {
      return null;
    }

    final isExpired =
        DateTime.now().millisecondsSinceEpoch - cacheTimestamp >
        _activeEvaluationsTtlMs;
    if (isExpired) {
      return null;
    }

    try {
      final List<dynamic> decoded = jsonDecode(cachedPayload);
      final List<EvaluationModel> cached = [];

      for (final item in decoded) {
        final json = Map<String, dynamic>.from(item as Map);
        final evalJson = Map<String, dynamic>.from(json['eval'] as Map);
        final courseJson = Map<String, dynamic>.from(json['course'] as Map);
        cached.add(EvaluationModel.fromDbJson(evalJson, courseJson));
      }

      return cached;
    } catch (e) {
      logError('getActiveEvaluations cache decode error: $e');
      return null;
    }
  }

  Future<void> _setCachedActiveEvaluations(
    ILocalPreferences prefs,
    String studentEmail,
    List<Map<String, dynamic>> payload,
  ) async {
    final cacheKey = '${_activeEvaluationsCachePrefix}_$studentEmail';
    final cacheTsKey = '${_activeEvaluationsCacheTsPrefix}_$studentEmail';

    try {
      await prefs.setString(cacheKey, jsonEncode(payload));
      await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      logError('getActiveEvaluations cache store error: $e');
    }
  }

  Future<void> _closeExpiredEvaluations(
    List<Map<String, dynamic>> rows,
    Map<String, String> headers,
  ) async {
    final now = DateTime.now();
    for (final row in rows) {
      if (row['status'] != 'active') continue;
      final deadline = DateTime.tryParse(row['deadline'] as String? ?? '');
      if (deadline == null || deadline.isAfter(now)) continue;

      final id = row['_id']?.toString();
      if (id == null) {
        logError('_closeExpiredEvaluations: missing _id in row: $row');
        continue;
      }

      final uri = Uri.https(baseUrl, '/database/$contract/update');
      final response = await httpClient.put(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
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
        logError(
          '_closeExpiredEvaluations PUT error ${response.statusCode}: ${response.body}',
        );
      }
    }
  }
}
