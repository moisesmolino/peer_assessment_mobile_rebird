import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:src/features/create-eval/data/models/create_evaluation_model.dart';
import 'package:src/features/create-eval/data/datasources/create_evaluation_datasource.dart';

class RemoteCreateEvaluationDatasource implements CreateEvaluationDatasource {
  final http.Client httpClient;

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: 'NO_ENV',
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  RemoteCreateEvaluationDatasource(this.httpClient);

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  @override
  Future<void> createEvaluation(CreateEvaluationModel model) async {
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final body = jsonEncode({
      'tableName': 'evaluations',
      'records': [model.toJson()],
    });

    final response = await httpClient.post(uri, headers: _headers, body: body);

    if (response.statusCode != 201) {
      logError('createEvaluation error ${response.statusCode}: ${response.body}');
      return Future.error('Error creating evaluation: ${response.statusCode}');
    }
  }
}
