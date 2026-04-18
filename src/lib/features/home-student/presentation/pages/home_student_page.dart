import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import '../state_management/home_student_controller.dart';
import '../widgets/evaluation_card.dart';
import '../widgets/course_card.dart';

class HomeStudentPage extends StatelessWidget {
  const HomeStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeStudentController>();
    final UserController userController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFF15100E),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF15100E),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFBB3322)),
          );
        }
        return RefreshIndicator(
          color: const Color(0xFFBB3322),
          backgroundColor: const Color(0xFF15100E),
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StudentHeader(
                controller: controller,
                userController: userController,
              ),
              const SizedBox(height: 8),
              _RoleBadge(),
              const SizedBox(height: 28),
              _ActiveEvaluationsSection(controller: controller),
              const SizedBox(height: 28),
              _MyCoursesSection(controller: controller),
              const SizedBox(height: 24),
            ],
          ),
          ),
        );
      }),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  final HomeStudentController controller;
  final UserController userController;

  const _StudentHeader({
    required this.controller,
    required this.userController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello,',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 16),
              ),
              Obx(
                () => Text(
                  controller.studentName.value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await userController.logOut();
                // onSignOut();
                // onSignOut();  función esqueleto
              }
            },
            offset: const Offset(0, 50), // para que salga debajo
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Sign out"),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF4A2B1F),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  controller.studentInitials,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2016),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            'Student',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveEvaluationsSection extends StatelessWidget {
  final HomeStudentController controller;

  const _ActiveEvaluationsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Evaluations',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFBB3322),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${controller.evaluations.length}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(
          () => Column(
            children: controller.evaluations
                .map(
                  (evaluation) => EvaluationCard(
                    evaluation: evaluation,
                    onTap: () => controller.navigateToEvaluation(evaluation),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _MyCoursesSection extends StatelessWidget {
  final HomeStudentController controller;

  const _MyCoursesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Courses',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => Text(
                '${controller.courses.length} enrolled',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(
          () => Column(
            children: controller.courses
                .map(
                  (course) => CourseCard(
                    course: course,
                    onTap: () => controller.navigateToCourse(course),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
