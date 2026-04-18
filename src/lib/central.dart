import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import 'package:src/features/Splash-Screen/presentation/pages/home_page.dart';
import 'package:src/features/home-professor/presentation/pages/home_professor_page.dart';
import 'package:src/features/home-professor/presentation/state_management/home_professor_binding.dart';
import 'package:src/features/home-student/presentation/pages/home_student_page.dart';
import 'package:src/features/home-student/presentation/state_management/home_student_binding.dart';

class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return Obx(() {
      if (!userController.isLogged) return const HomePage();
      if (userController.isStudent.value) {
        HomeStudentBinding().dependencies();
        return const HomeStudentPage();
      }
      HomeProfessorBinding().dependencies();
      return const HomeProfessorPage();
    });
  }
}
