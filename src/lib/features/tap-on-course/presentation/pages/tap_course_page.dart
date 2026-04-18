import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state_management/tap_course_controller.dart';
import '../widgets/course_evaluation_card.dart';
import '../widgets/group_category_section.dart';

class TapCoursePage extends StatelessWidget {
  const TapCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TapCourseController>();

    return Scaffold(
      backgroundColor: const Color(0xFF15100E),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFBB3322)),
          );
        }
        return Column(
          children: [
            _CourseHeader(controller: controller),
            _CourseInfoCard(controller: controller),
            _TabBar(controller: controller),
            Expanded(
              child: _TabContent(controller: controller),
            ),
            if (controller.isProfessor) _BottomAction(controller: controller),
          ],
        );
      }),
    );
  }
}


class _CourseHeader extends StatelessWidget {
  final TapCourseController controller;

  const _CourseHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF231816),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.course.code} · ${controller.course.period}',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    controller.course.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.pie_chart_outline, color: Colors.white54, size: 22),
          ],
        ),
      ),
    );
  }
}


class _CourseInfoCard extends StatelessWidget {
  final TapCourseController controller;

  const _CourseInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231816),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Principles and practices of modern software development.',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          _EnrollmentCode(code: controller.enrollmentCode),
          const SizedBox(height: 10),
          Obx(() => Row(
            children: [
              if (controller.isProfessor) ...[
                const Icon(Icons.people_outline, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  '${controller.course.studentsCount} Students',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(width: 16),
              ],
              const Icon(Icons.folder_outlined, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                '${controller.groupCategoriesCount} group categories',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class _EnrollmentCode extends StatelessWidget {
  final String code;

  const _EnrollmentCode({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF15100E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              Get.snackbar(
                'Copied',
                'Enrollment code copied to clipboard.',
                backgroundColor: const Color(0xFF3A2016),
                colorText: const Color(0xFFFF8C60),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              );
            },
            child: const Icon(Icons.copy_outlined, size: 16, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}


class _TabBar extends StatelessWidget {
  final TapCourseController controller;

  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF231816),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Evaluations',
              selected: controller.selectedTab.value == 0,
              onTap: () => controller.selectTab(0),
            ),
            _TabButton(
              label: 'Groups',
              selected: controller.selectedTab.value == 1,
              onTap: () => controller.selectTab(1),
            ),
          ],
        ),
      )),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3A2016) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _TabContent extends StatelessWidget {
  final TapCourseController controller;

  const _TabContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedTab.value == 0) {
        return _EvaluationsTab(controller: controller);
      }
      return _GroupsTab(controller: controller);
    });
  }
}

class _EvaluationsTab extends StatelessWidget {
  final TapCourseController controller;

  const _EvaluationsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.evaluations.isEmpty) {
        return Center(
          child: Text(
            'No evaluations yet',
            style: GoogleFonts.inter(color: Colors.white54),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.evaluations.length,
        itemBuilder: (_, i) {
          final eval = controller.evaluations[i];
          final isStudent = !controller.isProfessor;
          final submitted = controller.isSubmitted(eval.id);
          return CourseEvaluationCard(
            evaluation: eval,
            onEvaluate: (isStudent && !submitted && eval.status == 'active')
                ? () => controller.onEvaluateTapped(eval)
                : null,
            onViewResults: isStudent
                ? () => controller.onViewResultsTapped(eval)
                : null,
          );
        },
      );
    });
  }
}

class _GroupsTab extends StatelessWidget {
  final TapCourseController controller;

  const _GroupsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.groupCategories.isEmpty) {
        return Center(
          child: Text(
            'No groups yet',
            style: GoogleFonts.inter(color: Colors.white54),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.groupCategories.length,
        itemBuilder: (_, i) =>
            GroupCategorySection(category: controller.groupCategories[i]),
      );
    });
  }
}



class _BottomAction extends StatelessWidget {
  final TapCourseController controller;

  const _BottomAction({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEvaluationsTab = controller.selectedTab.value == 0;
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isImporting.value
                  ? null
                  : () {
                      if (isEvaluationsTab) {
                        controller.onCreateEvaluationTapped();
                      } else {
                        controller.onAddGroupsTapped();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A2016),
                foregroundColor: const Color(0xFFFF8C60),
                disabledBackgroundColor: const Color(0xFF2A1810),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isImporting.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8C60),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isEvaluationsTab ? '+ Create evaluation' : '+Add groups',
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
