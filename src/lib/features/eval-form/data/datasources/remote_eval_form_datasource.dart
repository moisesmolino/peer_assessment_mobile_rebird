import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import '../models/eval_peer_model.dart';
import '../models/eval_submission_model.dart';
import 'eval_form_datasource.dart';

class RemoteEvalFormDatasource implements EvalFormDatasource {
  final http.Client httpClient;

  final String contract = dotenv.get(
    'EXPO_PUBLIC_ROBLE_PROJECT_ID',
    fallback: 'NO_ENV',
  );
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';

  RemoteEvalFormDatasource(this.httpClient);

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Finds the student's group within the given group category,
  /// then returns all other members of that group (excluding the student).
  @override
  Future<List<EvalPeerModel>> getGroupPeers(
    String groupCategory,
    String studentEmail,
  ) async {
    // 1. Find the student's row to get their Groupname
    final studentUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'grupitos',
      'GroupCategory': groupCategory,
      'correo': studentEmail,
    });

    final studentResponse = await httpClient.get(studentUri, headers: _headers);

    if (studentResponse.statusCode != 200) {
      logError('getGroupPeers student lookup error ${studentResponse.statusCode}');
      return Future.error('Error fetching student group: ${studentResponse.statusCode}');
    }

    final List<dynamic> studentRows = jsonDecode(studentResponse.body);
    if (studentRows.isEmpty) return [];

    final groupName = studentRows.first['Groupname'] as String;

    // 2. Get all members of that group, excluding the student
    final peersUri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'grupitos',
      'GroupCategory': groupCategory,
      'Groupname': groupName,
    });

    final peersResponse = await httpClient.get(peersUri, headers: _headers);

    if (peersResponse.statusCode != 200) {
      logError('getGroupPeers peers lookup error ${peersResponse.statusCode}');
      return Future.error('Error fetching peers: ${peersResponse.statusCode}');
    }

    final List<dynamic> peerRows = jsonDecode(peersResponse.body);

    return peerRows
        .cast<Map<String, dynamic>>()
        .where((row) => row['correo'] != studentEmail)
        .map(EvalPeerModel.fromJson)
        .toList();
  }

  @override
  Future<Set<String>> getSubmittedEvaluationIds(String studentEmail) async {
    final uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'responses',
      'evaluator_email': studentEmail,
    });

    final response = await httpClient.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      logError('getSubmittedEvaluationIds error ${response.statusCode}');
      return {};
    }

    final List<dynamic> rows = jsonDecode(response.body);
    return rows
        .cast<Map<String, dynamic>>()
        .map((r) => r['evaluation_id'] as String)
        .toSet();
  }

  @override
  Future<void> submitEvaluation(EvalSubmissionModel model) async {
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final body = jsonEncode({
      'tableName': 'responses',
      'records': [model.toJson()],
    });

    final response = await httpClient.post(uri, headers: _headers, body: body);

    if (response.statusCode != 201) {
      logError('submitEvaluation error ${response.statusCode}: ${response.body}');
      return Future.error('Error submitting evaluation: ${response.statusCode}');
    }
  }
}
