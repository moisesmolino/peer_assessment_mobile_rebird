import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import '../state_management/home_professor_controller.dart';
import '../widgets/course_card.dart';

class HomeProfessorPage extends StatelessWidget {
  const HomeProfessorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeProfessorController>();
    final UserController userController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFF15100E),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF15100E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfessorHeader(
              controller: controller,
              userController: userController,
            ),

            const SizedBox(height: 8),

            const _ProfessorBadge(),

            const SizedBox(height: 28),

            _ProfessorStats(controller: controller),

            const SizedBox(height: 28),

            _ProfessorCourses(controller: controller),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfessorHeader extends StatelessWidget {
  final HomeProfessorController controller;
  final UserController userController;

  const _ProfessorHeader({
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
                  controller.professorName.value,
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
                  controller.professorInitials,
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

class _ProfessorBadge extends StatelessWidget {
  const _ProfessorBadge();

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
          const Icon(Icons.school_outlined, color: Colors.white70, size: 14),

          const SizedBox(width: 4),

          Text(
            'Teacher · Computer Science',
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

class _ProfessorStats extends StatelessWidget {
  final HomeProfessorController controller;

  const _ProfessorStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: "Courses", value: controller.coursesCount),

        const SizedBox(width: 10),

        _StatCard(label: "Students", value: controller.studentsCount),

        const SizedBox(width: 10),

        _StatCard(label: "Active", value: controller.activeEvaluations),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final RxInt value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF231816),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Obx(
              () => Text(
                value.value.toString(),
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF8C60),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessorCourses extends StatelessWidget {
  final HomeProfessorController controller;

  const _ProfessorCourses({required this.controller});

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
                '${controller.courses.length} total',
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
