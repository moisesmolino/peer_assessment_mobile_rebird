import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import 'package:src/features/eval-form/domain/entities/eval_peer.dart';
import 'package:src/features/eval-form/domain/entities/eval_submission.dart';
import 'package:src/features/eval-form/domain/usecases/get_group_peers.dart';
import 'package:src/features/eval-form/domain/usecases/submit_peer_evaluation.dart';
import 'package:src/features/tap-on-course/domain/entities/course_evaluation.dart';

class EvalCriterion {
  final String label;
  final String key;
  const EvalCriterion(this.label, this.key);
}

class ScoreOption {
  final double value;
  final String label;
  const ScoreOption(this.value, this.label);
}

class EvalFormController extends GetxController {
  final GetGroupPeers getGroupPeers;
  final SubmitPeerEvaluation submitPeerEvaluation;

  EvalFormController({
    required this.getGroupPeers,
    required this.submitPeerEvaluation,
  });

  static const criteria = [
    EvalCriterion('Punctuality', 'punctuality'),
    EvalCriterion('Contributions', 'contributions'),
    EvalCriterion('Commitment', 'commitment'),
    EvalCriterion('Attitude', 'attitude'),
  ];

  static const scoreOptions = [
    ScoreOption(2.0, 'Bad'),
    ScoreOption(3.0, 'Adequate'),
    ScoreOption(4.0, 'Good'),
    ScoreOption(5.0, 'Excellent'),
  ];

  late final CourseEvaluation evaluation;
  late final String courseName;
  late final String studentEmail;

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxString elapsedTime = '0:00'.obs;
  final RxInt doneCount = 0.obs;

  List<EvalPeer> peers = [];

  // scores[peerIndex][criterionKey] = selected score
  final List<Map<String, double?>> _allScores = [];
  final List<String> _allComments = [];

  // Reactive state for current peer (drives UI)
  final RxMap<String, double?> currentScores = <String, double?>{}.obs;
  final commentController = TextEditingController();

  Timer? _timer;
  int _secondsElapsed = 0;

  EvalPeer get currentPeer => peers[currentIndex.value];
  bool get isLastPeer => currentIndex.value == peers.length - 1;
  bool get isFormValid =>
      criteria.every((c) => currentScores[c.key] != null);

  String get nextPeerName =>
      currentIndex.value + 1 < peers.length
          ? peers[currentIndex.value + 1].fullName
          : '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    evaluation = args['evaluation'] as CourseEvaluation;
    courseName = args['courseName'] as String;
    studentEmail =
        Get.find<UserController>().loggedUser?.email ?? '';
    _startTimer();
    _loadPeers();
  }

  Future<void> _loadPeers() async {
    isLoading.value = true;
    peers = await getGroupPeers(evaluation.groupCategory, studentEmail);
    for (final _ in peers) {
      _allScores.add({for (final c in criteria) c.key: null});
      _allComments.add('');
    }
    _syncCurrentPeer();
    isLoading.value = false;
  }

  void _syncCurrentPeer() {
    if (_allScores.isEmpty) return;
    currentScores.assignAll(_allScores[currentIndex.value]);
    commentController.text = _allComments[currentIndex.value];
  }

  void _saveCurrentPeer() {
    _allScores[currentIndex.value] = Map.from(currentScores);
    _allComments[currentIndex.value] = commentController.text;
  }

  void selectScore(String criterionKey, double score) {
    currentScores[criterionKey] = score;
  }

  Future<void> onNextOrSubmit() async {
    if (!isFormValid || isSubmitting.value) return;
    _saveCurrentPeer();

    if (!isLastPeer) {
      currentIndex.value++;
      _syncCurrentPeer();
    } else {
      await _submitAll();
    }
  }

  Future<void> _submitAll() async {
    isSubmitting.value = true;
    for (int i = 0; i < peers.length; i++) {
      final scores = _allScores[i];
      final complete = scores.values.every((v) => v != null);
      if (!complete) continue;

      await submitPeerEvaluation(EvalSubmission(
        evaluationId: evaluation.id,
        evaluatorEmail: studentEmail,
        evaluatedEmail: peers[i].email,
        scores: scores.map((k, v) => MapEntry(k, v!)),
        comment: _allComments[i].trim().isEmpty ? null : _allComments[i].trim(),
      ));
    }
    isSubmitting.value = false;
    Get.back(result: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsElapsed++;
      final m = _secondsElapsed ~/ 60;
      final s = _secondsElapsed % 60;
      elapsedTime.value = '$m:${s.toString().padLeft(2, '0')}';
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    commentController.dispose();
    super.onClose();
  }
}
