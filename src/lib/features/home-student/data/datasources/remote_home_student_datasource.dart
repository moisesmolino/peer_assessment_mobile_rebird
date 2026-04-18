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
    final token = await prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    // find all grupitos rows where correo matches the student
    final grupitosUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'grupitos',
      'correo': studentEmail,
    });

    final grupitosResponse = await httpClient.get(grupitosUri, headers: headers);

    if (grupitosResponse.statusCode != 200) {
      logError('getEnrolledCourses grupitos error ${grupitosResponse.statusCode}');
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
        logError('getEnrolledCourses group_categories error ${catResponse.statusCode}');
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

    for (final courseId in courseIds) {
      final courseUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'cursos',
        '_id': courseId,
      });

      final courseResponse = await httpClient.get(courseUri, headers: headers);

      if (courseResponse.statusCode != 200) {
        logError('getEnrolledCourses cursos error ${courseResponse.statusCode}');
        continue;
      }

      final List<dynamic> rows = jsonDecode(courseResponse.body);
      for (final row in rows) {
        courses.add(CourseModel.fromJson(row));
      }
    }

    return courses;
  }

  @override
  Future<List<EvaluationModel>> getActiveEvaluations(String studentEmail, Set<String> submittedIds) async {
    final ILocalPreferences prefs = Get.find();
    final token = await prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token'};

    // Get GroupCategory names for this student
    final grupitosUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'grupitos',
      'correo': studentEmail,
    });
    final grupitosResponse = await httpClient.get(grupitosUri, headers: headers);
    if (grupitosResponse.statusCode != 200) {
      logError('getActiveEvaluations grupitos error ${grupitosResponse.statusCode}');
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
      final stillActive = rows
          .where((e) => e['status'] == 'active')
          .where((e) => !submittedIds.contains(e['_id']?.toString()))
          .toList();
      if (stillActive.isEmpty) continue;

      final courseUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'cursos',
        '_id': courseId,
      });
      final courseResponse = await httpClient.get(courseUri, headers: headers);
      final Map<String, dynamic> courseJson = courseResponse.statusCode == 200
          ? ((jsonDecode(courseResponse.body) as List).firstOrNull as Map<String, dynamic>? ?? {})
          : {};

      for (final eval in stillActive) {
        result.add(EvaluationModel.fromDbJson(eval, courseJson));
      }
    }

    return result;
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
        logError('_closeExpiredEvaluations PUT error ${response.statusCode}: ${response.body}');
      }
    }
  }

}
