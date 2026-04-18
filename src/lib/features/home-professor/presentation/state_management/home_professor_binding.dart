import 'package:get/get.dart';
/*
import 'package:src/features/home-professor/data/datasources/home_professor_datasource.dart';
import '../../data/datasources/remote_home_professor_datasource.dart';
import '../../data/repositories/home_professor_repository_impl.dart';
import '../../domain/repositories/home_professor_repository.dart';
*/
import '../../domain/usecases/get_assigned_courses.dart';
import 'home_professor_controller.dart';

class HomeProfessorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetAssignedCourses(Get.find()));

    Get.lazyPut(() => HomeProfessorController(getAssignedCourses: Get.find()));
  }
}
