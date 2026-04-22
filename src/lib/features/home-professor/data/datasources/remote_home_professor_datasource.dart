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

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: "NO_ENV",
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';
  String get contractUrl => '$baseUrl/$contract';
  final String table = 'cursos';

  RemoteHomeProfessorDataSource(this.httpClient);

  @override
  Future<List<Course>> getAssignedCourses(String professorId) async {
    final ILocalPreferences prefs = Get.find();

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

      final List<Course> courses = await Future.wait(
        decodedJson.map((x) => _enrichCourse(x, token!)),
      );
      return courses;
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  Future<Course> _enrichCourse(
    Map<String, dynamic> courseJson,
    String token,
  ) async {
    final courseId = courseJson['_id'] as String;

    final studentsCount = await _getStudentsCount(courseId, token);
    final activeEvaluations = await _getActiveEvaluationsCount(courseId, token);
    final totalEvaluations = await _getTotalEvaluationsCount(courseId, token);

    return Course(
      id: courseId,
      code: courseJson['code'] ?? '---',
      name: courseJson['name'] ?? '---',
      period: courseJson['period'] ?? '---',
      studentsCount: studentsCount,
      activeEvaluations: activeEvaluations,
      totalEvaluations: totalEvaluations,
    );
  }

  Future<int> _getStudentsCount(String courseId, String token) async {
    try {
      final gcUri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'group_categories',
        'course_id': courseId,
      });

      final gcResponse = await httpClient.get(
        gcUri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (gcResponse.statusCode != 200) {
        logError(
          'group_categories error for course $courseId: ${gcResponse.statusCode}',
        );
        return 0;
      }

      final List<dynamic> groupCategories = jsonDecode(gcResponse.body);
      if (groupCategories.isEmpty) return 0;

      final Set<String> uniqueEmails = {};

      await Future.wait(
        groupCategories.map((gc) async {
          final gcName = gc['name'] as String?;
          if (gcName == null) return;

          final gUri = Uri.https(baseUrl, '/database/$contract/read', {
            'tableName': 'grupitos',
            'GroupCategory': gcName,
          });

          final gResponse = await httpClient.get(
            gUri,
            headers: {'Authorization': 'Bearer $token'},
          );

          if (gResponse.statusCode == 200) {
            final List<dynamic> members = jsonDecode(gResponse.body);
            for (final member in members) {
              final email = member['correo'] as String?;
              if (email != null) uniqueEmails.add(email);
            }
          } else {
            logError(
              'grupitos error for GroupCategory $gcName: ${gResponse.statusCode}',
            );
          }
        }),
      );

      return uniqueEmails.length;
    } catch (e) {
      logError('_getStudentsCount error for course $courseId: $e');
      return 0;
    }
  }

  Future<int> _getActiveEvaluationsCount(String courseId, String token) async {
    try {
      final uri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'evaluations',
        'course_id': courseId,
        'status': 'active',
      });

      final response = await httpClient.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> evaluations = jsonDecode(response.body);
        return evaluations.length;
      } else {
        logError(
          'evaluations error for course $courseId: ${response.statusCode}',
        );
        return 0;
      }
    } catch (e) {
      logError('_getActiveEvaluationsCount error for course $courseId: $e');
      return 0;
    }
  }

  Future<int> _getTotalEvaluationsCount(String courseId, String token) async {
    try {
      final uri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'evaluations',
        'course_id': courseId,
      });

      final response = await httpClient.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> evaluations = jsonDecode(response.body);
        return evaluations.length;
      } else {
        logError(
          'evaluations total error for course $courseId: ${response.statusCode}',
        );
        return 0;
      }
    } catch (e) {
      logError('_getTotalEvaluationsCount error for course $courseId: $e');
      return 0;
    }
  }
}
