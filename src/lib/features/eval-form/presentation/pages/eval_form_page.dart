import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state_management/eval_form_controller.dart';

class EvalFormPage extends StatelessWidget {
  const EvalFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EvalFormController>();

    return Scaffold(
      backgroundColor: const Color(0xFF15100E),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFBB3322)),
          );
        }
        if (c.peers.isEmpty) {
          return Center(
            child: Text(
              'No peers to evaluate.',
              style: GoogleFonts.inter(color: Colors.white54),
            ),
          );
        }
        return Column(
          children: [
            _Header(c: c),
            _ProgressSection(c: c),
            Expanded(child: _FormBody(c: c)),
            _BottomButton(c: c),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final EvalFormController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF231816),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.evaluation.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    c.courseName,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBB3322),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c.elapsedTime.value,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final EvalFormController c;
  const _ProgressSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = c.currentIndex.value + 1;
      final total = c.peers.length;
      final done = c.doneCount.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Peer $current of $total',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$done/$total done',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? done / total : 0,
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFBB3322)),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }
}

class _FormBody extends StatelessWidget {
  final EvalFormController c;
  const _FormBody({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final peer = c.currentPeer;
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeerCard(peer: peer),
            const SizedBox(height: 20),
            ...EvalFormController.criteria.map(
              (criterion) => _CriterionSection(c: c, criterion: criterion),
            ),
            const SizedBox(height: 8),
            _CommentSection(c: c),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}

class _PeerCard extends StatelessWidget {
  final peer;
  const _PeerCard({required this.peer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231816),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF4A2B1F),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                peer.initials,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                peer.fullName,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                peer.email,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriterionSection extends StatelessWidget {
  final EvalFormController c;
  final EvalCriterion criterion;
  const _CriterionSection({required this.c, required this.criterion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criterion.label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Row(
                children: EvalFormController.scoreOptions.map((option) {
                  final selected =
                      c.currentScores[criterion.key] == option.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => c.selectScore(criterion.key, option.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF3A2016)
                              : const Color(0xFF231816),
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(
                                  color: const Color(0xFFFF8C60),
                                  width: 1.5,
                                )
                              : Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              option.value.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                color: selected
                                    ? const Color(0xFFFF8C60)
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.label,
                              style: GoogleFonts.inter(
                                color: selected
                                    ? const Color(0xFFFF8C60)
                                    : Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }
}

class _CommentSection extends StatelessWidget {
  final EvalFormController c;
  const _CommentSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Comments',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Optional',
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: c.commentController,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a comment about this peer...',
            hintStyle: GoogleFonts.inter(color: const Color(0xFF5A5A5A)),
            filled: true,
            fillColor: const Color(0xFF231816),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final EvalFormController c;
  const _BottomButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLast = c.isLastPeer;
      final label = isLast
          ? 'Submit →'
          : 'Next: ${c.nextPeerName} →';

      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (c.isFormValid && !c.isSubmitting.value)
                      ? c.onNextOrSubmit
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A2016),
                foregroundColor: const Color(0xFFFF8C60),
                disabledBackgroundColor: const Color(0xFF231816),
                disabledForegroundColor: Colors.white24,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: c.isSubmitting.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8C60),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }
}
