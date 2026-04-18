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
    List<Course> courses = [];

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'profid': professorId,
    });
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.getString('token');
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);

      //logInfo(decodedJson);

      courses = List<Course>.from(decodedJson.map((x) => Course.fromJson(x)));
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
    //print(courses);

    return Future.value(courses);
  }
}
