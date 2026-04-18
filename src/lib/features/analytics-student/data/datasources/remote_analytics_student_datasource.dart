import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import '../models/student_analytics_model.dart';
import 'i_analytics_student_datasource.dart';

class RemoteAnalyticsStudentDatasource implements IAnalyticsStudentDatasource {
  final http.Client httpClient;

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: 'NO_ENV',
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  RemoteAnalyticsStudentDatasource(this.httpClient);

  @override
  Future<StudentAnalyticsModel?> fetchResults({
    required String evaluationId,
    required String studentEmail,
  }) async {
    final uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'responses',
      'evaluation_id': evaluationId,
      'evaluated_email': studentEmail,
    });

    final response = await httpClient.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      logError('fetchResults error ${response.statusCode}');
      return Future.error('Error fetching analytics: ${response.statusCode}');
    }

    final rows = (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return null;

    return StudentAnalyticsModel.fromRows(rows);
  }
}
