import 'package:src/features/home-professor/domain/entities/course.dart';
import '../../domain/repositories/home_professor_repository.dart';
import '../datasources/home_professor_datasource.dart';
import '../datasources/local_home_professor_cache_source.dart';

class HomeProfessorRepositoryImpl implements HomeProfessorRepository {
  final HomeProfessorDataSource datasource;
  final LocalHomeProfessorCacheSource cacheSource;

  HomeProfessorRepositoryImpl(this.datasource, this.cacheSource);

  @override
  Future<List<Course>> getAssignedCourses(String professorId) async {
    final isValid = await cacheSource.isAssignedCoursesCacheValid(professorId);
    if (isValid) {
      final cached = await cacheSource.getCachedAssignedCourses(professorId);
      if (cached != null) return cached;
    }

    final remote = await datasource.getAssignedCourses(professorId);
    if (remote.isNotEmpty) {
      await cacheSource.cacheAssignedCourses(professorId, remote);
    }
    return remote;
  }
}
