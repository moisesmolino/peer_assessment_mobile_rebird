import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:src/central.dart';
import 'package:src/core/i_local_preferences.dart';
import 'package:src/features/analytics-student/data/datasources/i_analytics_student_datasource.dart';
import 'package:src/features/analytics-student/data/datasources/local_analytics_student_cache_source.dart';
import 'package:src/features/analytics-student/data/datasources/remote_analytics_student_datasource.dart';
import 'package:src/features/analytics-student/data/repositories/analytics_student_repository_impl.dart';
import 'package:src/features/analytics-student/domain/repositories/i_analytics_student_repository.dart';
import 'package:src/features/analytics-student/domain/usecases/get_student_analytics.dart';
import 'package:src/features/analytics-student/presentation/pages/analytics_student_page.dart';
import 'package:src/features/analytics-student/presentation/state_management/analytics_student_controller.dart';
import 'package:src/features/analytics-teacher/data/datasources/i_analytics_teacher_datasource.dart';
import 'package:src/features/analytics-teacher/data/datasources/local_analytics_teacher_cache_source.dart';
import 'package:src/features/analytics-teacher/data/datasources/remote_analytics_teacher_datasource.dart';
import 'package:src/features/analytics-teacher/data/repositories/analytics_teacher_repository_impl.dart';
import 'package:src/features/analytics-teacher/domain/repositories/i_analytics_teacher_repository.dart';
import 'package:src/features/analytics-teacher/domain/usecases/get_teacher_analytics.dart';
import 'package:src/features/analytics-teacher/presentation/pages/analytics_teacher_page.dart';
import 'package:src/features/analytics-teacher/presentation/state_management/analytics_teacher_controller.dart';
import 'package:src/features/auth/data/datasources/remote/i_authentication_source.dart';
import 'package:src/features/auth/data/repository/auth_repository.dart';
import 'package:src/features/auth/domain/models/authentication_user.dart';
import 'package:src/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:src/features/auth/presentation/pages/login_page.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import 'package:src/features/create-eval/presentation/pages/create_evaluation_page.dart';
import 'package:src/features/create-eval/presentation/state_management/create_evaluation_binding.dart';
import 'package:src/features/eval-form/data/datasources/eval_form_datasource.dart';
import 'package:src/features/eval-form/data/datasources/remote_eval_form_datasource.dart';
import 'package:src/features/eval-form/data/repositories/eval_form_repository_impl.dart';
import 'package:src/features/eval-form/domain/repositories/i_eval_form_repository.dart';
import 'package:src/features/eval-form/domain/usecases/get_submitted_evaluation_ids.dart';
import 'package:src/features/eval-form/presentation/pages/eval_form_page.dart';
import 'package:src/features/home-professor/data/datasources/home_professor_datasource.dart';
import 'package:src/features/home-professor/data/datasources/local_home_professor_cache_source.dart';
import 'package:src/features/home-professor/data/datasources/remote_home_professor_datasource.dart';
import 'package:src/features/home-professor/data/repositories/home_professor_repository_impl.dart';
import 'package:src/features/home-professor/domain/repositories/home_professor_repository.dart';
import 'package:src/features/home-professor/domain/usecases/get_assigned_courses.dart';
import 'package:src/features/home-professor/presentation/pages/home_professor_page.dart';
import 'package:src/features/home-professor/presentation/state_management/home_professor_controller.dart';
import 'package:src/features/home-student/data/datasources/home_student_datasource.dart';
import 'package:src/features/home-student/data/datasources/local_home_student_cache_source.dart';
import 'package:src/features/home-student/data/datasources/remote_home_student_datasource.dart';
import 'package:src/features/home-student/data/repositories/home_student_repository_impl.dart';
import 'package:src/features/home-student/domain/repositories/home_student_repository.dart';
import 'package:src/features/home-student/domain/usecases/get_active_evaluations.dart';
import 'package:src/features/home-student/domain/usecases/get_enrolled_courses.dart';
import 'package:src/features/home-student/presentation/pages/home_student_page.dart';
import 'package:src/features/home-student/presentation/state_management/home_student_controller.dart';
import 'package:src/features/Splash-Screen/presentation/pages/home_page.dart';
import 'package:src/features/tap-on-course/data/datasources/local_tap_course_cache_source.dart';
import 'package:src/features/tap-on-course/data/datasources/tap_course_datasource.dart';
import 'package:src/features/tap-on-course/data/datasources/remote_tap_course_datasource.dart';
import 'package:src/features/tap-on-course/data/parsers/csv_group_parser.dart';
import 'package:src/features/tap-on-course/data/repositories/tap_course_repository_impl.dart';
import 'package:src/features/tap-on-course/domain/repositories/tap_course_repository.dart';
import 'package:src/features/tap-on-course/domain/usecases/get_course_evaluations.dart';
import 'package:src/features/tap-on-course/domain/usecases/get_course_groups.dart';
import 'package:src/features/tap-on-course/domain/usecases/import_groups_from_csv.dart';
import 'package:src/features/tap-on-course/presentation/pages/tap_course_page.dart';
import 'package:src/features/tap-on-course/presentation/state_management/tap_course_controller.dart';
import 'package:src/features/eval-form/data/datasources/remote_eval_form_datasource.dart';
import 'package:src/features/eval-form/domain/usecases/get_group_peers.dart';
import 'package:src/features/eval-form/domain/usecases/submit_peer_evaluation.dart';
import 'package:src/features/eval-form/presentation/state_management/eval_form_controller.dart';

const bool kDemoMode = true;

class _IsAUri extends Matcher {
  const _IsAUri();
  @override
  bool matches(dynamic item, Map matchState) => item is Uri;
  @override
  Description describe(Description description) => description.add('is a Uri');
}
const Matcher isAUri = _IsAUri();

class MockHttpClient extends Mock implements http.Client {
  @override
  Future<http.Response> get(Uri? url, {Map<String, String>? headers}) =>
      super.noSuchMethod(
        Invocation.method(#get, [url], {#headers: headers}),
        returnValue: Future.value(http.Response('[]', 200)),
        returnValueForMissingStub: Future.value(http.Response('[]', 200)),
      );

  @override
  Future<http.Response> post(Uri? url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      super.noSuchMethod(
        Invocation.method(#post, [url],
            {#headers: headers, #body: body, #encoding: encoding}),
        returnValue: Future.value(http.Response('{}', 201)),
        returnValueForMissingStub: Future.value(http.Response('{}', 201)),
      );
}

class FakeLocalPreferences implements ILocalPreferences {
  final Map<String, String> _storage = {};
  @override Future<String?> getString(String key) async => _storage[key];
  @override Future<void> setString(String key, String value) async => _storage[key] = value;
  @override Future<void> remove(String key) async => _storage.remove(key);
  @override Future<void> clear() async => _storage.clear();
  @override Future<bool?> getBool(String key) async => null;
  @override Future<void> setBool(String key, bool value) async {}
  @override Future<double?> getDouble(String key) async => null;
  @override Future<void> setDouble(String key, double value) async {}
  @override Future<int?> getInt(String key) async => null;
  @override Future<void> setInt(String key, int value) async {}
  @override Future<List<String>?> getStringList(String key) async => null;
  @override Future<void> setStringList(String key, List<String> value) async {}
}

class FakeAuthenticationSource implements IAuthenticationSource {
  bool _logged = false;
  bool _isStudent = false;

  void setStudent(bool value) => _isStudent = value;

  @override Future<void> login(String email, String password) async => _logged = true;
  @override Future<void> signUp(String email, String password, String name, bool direct) async {}
  @override Future<bool> logOut() async { _logged = false; return true; }
  @override Future<bool> validate(String email, String code) async => true;
  @override Future<bool> refreshToken() async => true;
  @override Future<bool> forgotPassword(String email) async => true;
  @override Future<bool> resetPassword(String email, String password, String code) async => true;
  @override Future<bool> verifyToken() async => _logged;
  @override
  Future<AuthenticationUser> getLoggedUser() async => AuthenticationUser(
        id: 'user-1',
        email: 'test@test.com',
        name: _isStudent ? 'Alice Student' : 'Josh Professor',
        student: _isStudent,
      );
  @override Future<List<AuthenticationUser>> getUsers() async => [];
}

MockHttpClient mockHttpClient = MockHttpClient();
FakeAuthenticationSource fakeAuthSource = FakeAuthenticationSource();

Future<void> pause(WidgetTester tester, [int ms = 1200]) async {
  if (kDemoMode) await tester.pump(Duration(milliseconds: ms));
}

Future<void> tapAndPause(WidgetTester tester, Finder finder, [int ms = 1200]) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await pause(tester, ms);
}

Future<void> enterTextAndPause(WidgetTester tester, Finder finder, String text, [int ms = 700]) async {
  await tester.enterText(finder, text);
  await tester.pump();
  await pause(tester, ms);
}

Future<Widget> createApp() async {
  Get.testMode = false;
  Get.reset();

  final fakePrefs = FakeLocalPreferences();
  await fakePrefs.setString('userId', 'user-1');
  await fakePrefs.setString('token', 'fake-token');
  await fakePrefs.setString('userEmail', 'test@test.com');
  Get.put<ILocalPreferences>(fakePrefs);
  Get.put<IAuthenticationSource>(fakeAuthSource);
  Get.put<http.Client>(mockHttpClient, tag: 'apiClient', permanent: true);
  Get.put<IAuthRepository>(AuthRepository(Get.find()));
  Get.put(UserController(Get.find()));

  // Profesor
  Get.lazyPut<HomeProfessorDataSource>(
    () => RemoteHomeProfessorDataSource(Get.find<http.Client>(tag: 'apiClient')),
  );
  Get.lazyPut(() => LocalHomeProfessorCacheSource(Get.find<ILocalPreferences>()));
  Get.lazyPut<HomeProfessorRepository>(
    () => HomeProfessorRepositoryImpl(Get.find(), Get.find()),
  );
  Get.lazyPut(() => GetAssignedCourses(Get.find()));
  Get.lazyPut(() => HomeProfessorController(getAssignedCourses: Get.find()));

  // EvalForm — cadena completa
  Get.lazyPut<EvalFormDatasource>(
    () => RemoteEvalFormDatasource(Get.find<http.Client>(tag: 'apiClient')),
  );
  Get.lazyPut<IEvalFormRepository>(
    () => EvalFormRepositoryImpl(Get.find()),
  );
  Get.lazyPut(() => GetGroupPeers(Get.find()));
  Get.lazyPut(() => GetSubmittedEvaluationIds(Get.find()));
  Get.lazyPut(() => SubmitPeerEvaluation(Get.find()));
  Get.lazyPut(() => EvalFormController(
    getGroupPeers: Get.find(),
    submitPeerEvaluation: Get.find(),
  ));

  // Estudiante
  Get.lazyPut<HomeStudentDataSource>(
    () => RemoteHomeStudentDataSource(Get.find<http.Client>(tag: 'apiClient')),
  );
  Get.lazyPut(() => LocalHomeStudentCacheSource(Get.find<ILocalPreferences>()));
  Get.lazyPut<HomeStudentRepository>(
    () => HomeStudentRepositoryImpl(Get.find(), Get.find()),
  );
  Get.lazyPut(() => GetActiveEvaluations(Get.find()));
  Get.lazyPut(() => GetEnrolledCourses(Get.find()));
  Get.lazyPut(() => HomeStudentController(
        getActiveEvaluations: Get.find(),
        getEnrolledCourses: Get.find(),
        getSubmittedEvaluationIds: Get.find(),
      ));

  // TapCourse
  Get.lazyPut(() => CsvGroupParser());
  Get.lazyPut(() => LocalTapCourseCacheSource(Get.find<ILocalPreferences>()));
  Get.lazyPut<TapCourseDatasource>(
    () => RemoteTapCourseDatasource(
      Get.find<http.Client>(tag: 'apiClient'),
      Get.find(),
    ),
  );
  Get.lazyPut<TapCourseRepository>(
    () => TapCourseRepositoryImpl(
      datasource: Get.find(),
      cacheSource: Get.find(),
      csvParser: Get.find(),
    ),
  );
  Get.lazyPut(() => GetCourseEvaluations(Get.find()));
  Get.lazyPut(() => GetCourseGroups(Get.find()));
  Get.lazyPut(() => ImportGroupsFromCsv(Get.find()));
  Get.lazyPut(() => TapCourseController(
        getCourseEvaluations: Get.find(),
        getCourseGroups: Get.find(),
        importGroupsFromCsv: Get.find(),
        getSubmittedEvaluationIds: Get.find(),
      ));

  // Analytics Teacher
  Get.lazyPut(() => LocalAnalyticsTeacherCacheSource(Get.find<ILocalPreferences>()));
  Get.lazyPut<IAnalyticsTeacherDatasource>(
    () => RemoteAnalyticsTeacherDatasource(Get.find<http.Client>(tag: 'apiClient')),
  );
  Get.lazyPut<IAnalyticsTeacherRepository>(
    () => AnalyticsTeacherRepositoryImpl(Get.find(), Get.find()),
  );
  Get.lazyPut(() => GetTeacherAnalytics(Get.find()));
  Get.lazyPut(() => AnalyticsTeacherController(getTeacherAnalytics: Get.find()));

  // Analytics Student
  Get.lazyPut(() => LocalAnalyticsStudentCacheSource(Get.find<ILocalPreferences>()));
  Get.lazyPut<IAnalyticsStudentDatasource>(
    () => RemoteAnalyticsStudentDatasource(Get.find<http.Client>(tag: 'apiClient')),
  );
  Get.lazyPut<IAnalyticsStudentRepository>(
    () => AnalyticsStudentRepositoryImpl(Get.find(), Get.find()),
  );
  Get.lazyPut(() => GetStudentAnalytics(Get.find()));
  Get.lazyPut(() => AnalyticsStudentController(getStudentAnalytics: Get.find()));

  return const GetMaterialApp(home: Central());
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    fakeAuthSource = FakeAuthenticationSource();

    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('Asset not found') ||
          details.exception.toString().contains('overflowed')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  tearDown(() => Get.reset());

  // =========================
  // FLUJO PROFESOR
  // =========================
  testWidgets(
    'Flujo profesor: login → ver cursos → entrar a curso → crear evaluación → ver estadísticas → logout',
    (WidgetTester tester) async {
      fakeAuthSource.setStudent(false);

      when(mockHttpClient.get(argThat(isAUri), headers: anyNamed('headers')))
          .thenAnswer((invocation) async {
        final url = (invocation.positionalArguments[0] as Uri).toString();

        if (url.contains('tableName=evaluations') && url.contains('status=active')) {
          return http.Response('[]', 200);
        }
        if (url.contains('tableName=evaluations')) {
          return http.Response(
            jsonEncode([
              {
                '_id': 'eval-2',
                'name': 'Sprint 0 Peer Review',
                'status': 'closed',
                'visibility': 'public',
                'group_category': 'Grupo A',
                'deadline': '2024-01-01T14:00:00.000Z',
                'course_id': 'course-1',
              }
            ]),
            200,
          );
        }
        if (url.contains('tableName=group_categories')) {
          return http.Response(
            jsonEncode([
              {'_id': 'cat-1', 'course_id': 'course-1', 'name': 'Grupo A', 'source': 'CSV'},
            ]),
            200,
          );
        }
        if (url.contains('tableName=grupitos')) return http.Response('[]', 200);
        if (url.contains('tableName=responses')) return http.Response('[]', 200);

        return http.Response(
          jsonEncode([
            {
              '_id': 'course-1',
              'code': 'CS101',
              'name': 'Software Design',
              'period': '2024-10',
              'studentsCount': 30,
              'activeEvaluations': 0,
              'totalEvaluations': 1,
            },
          ]),
          200,
        );
      });

      when(mockHttpClient.post(
        argThat(isAUri),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: anyNamed('encoding'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({'_id': 'eval-new', 'name': 'Sprint 2 Peer Review'}),
            201,
          ));

      final widget = await createApp();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      await pause(tester, 1500);

      // 1. HomePage
      expect(find.byType(HomePage), findsOneWidget);

      // 2. Log in
      await tapAndPause(tester, find.text('Log in'), 1000);
      expect(find.byType(LoginPage), findsOneWidget);
      await pause(tester, 1000);

      // 3. Credenciales
      await enterTextAndPause(
          tester, find.byKey(const Key('TextFormFieldLoginEmail')), 'prof@test.com');
      await enterTextAndPause(
          tester, find.byKey(const Key('TextFormFieldLoginPassword')), 'ThePassword!1.');

      // 4. Login → HomeProfessorPage
      await tapAndPause(tester, find.byKey(const Key('ButtonLoginSubmit')), 1500);
      expect(find.byType(HomeProfessorPage), findsOneWidget);
      expect(find.text('Software Design'), findsOneWidget);
      await pause(tester, 2000);

      // 5. Entrar al curso
      await tapAndPause(tester, find.text('Software Design'), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(TapCoursePage), findsOneWidget);
      expect(find.text('Sprint 0 Peer Review'), findsOneWidget);
      await pause(tester, 2000);

      // 6. Tocar "+ Create evaluation" → CreateEvaluationPage
      await tapAndPause(tester, find.text('+ Create evaluation'), 1500);
      expect(find.byType(CreateEvaluationPage), findsOneWidget);
      expect(find.text('New Evaluation'), findsOneWidget);
      await pause(tester, 1500);

      // 7. Llenar nombre
      await enterTextAndPause(
          tester, find.byType(TextField).first, 'Sprint 2 Peer Review');
      await pause(tester, 1000);

      // 8. Seleccionar grupo del dropdown
      await tapAndPause(tester, find.byType(DropdownButton<String>), 1000);
      await tapAndPause(tester, find.text('Grupo A').last, 1000);
      await pause(tester, 1000);

      // 9. Crear → volver a TapCoursePage
      await tapAndPause(tester, find.text('+ Create evaluation'), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(TapCoursePage), findsOneWidget);
      await pause(tester, 2000);

      // 10. Ver estadísticas globales del curso
      await tapAndPause(tester, find.byIcon(Icons.pie_chart_outline), 1500);
      expect(find.byType(AnalyticsTeacherPage), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('No responses yet.'), findsOneWidget);
      await pause(tester, 2000);

      // 11. Volver a TapCoursePage
      await tapAndPause(tester, find.byIcon(Icons.chevron_left), 1000);
      await tester.pumpAndSettle();
      expect(find.byType(TapCoursePage), findsOneWidget);
      await pause(tester, 1000);

      // 12. Ver estadísticas de evaluación específica
      await tapAndPause(tester, find.text('View results →'), 1500);
      expect(find.byType(AnalyticsTeacherPage), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      await pause(tester, 2000);

      // 13. Volver → TapCoursePage → HomeProfessorPage
      await tapAndPause(tester, find.byIcon(Icons.chevron_left), 1000);
      await tapAndPause(tester, find.byIcon(Icons.chevron_left), 1000);
      expect(find.byType(HomeProfessorPage), findsOneWidget);
      await pause(tester, 1000);

      // 14. Logout
      await tapAndPause(tester, find.byType(PopupMenuButton<String>), 800);
      await tapAndPause(tester, find.text('Sign out'), 1500);
      expect(find.byType(HomePage), findsOneWidget);
      await pause(tester, 2000);
    },
  );

  // =========================
  // FLUJO ESTUDIANTE
  // =========================
  testWidgets(
    'Flujo estudiante: login → evaluar compañero → ver resultados → ver cursos → logout',
    (WidgetTester tester) async {
      fakeAuthSource.setStudent(true);

      when(mockHttpClient.get(argThat(isAUri), headers: anyNamed('headers')))
          .thenAnswer((invocation) async {
        final url = (invocation.positionalArguments[0] as Uri).toString();

        if (url.contains('tableName=grupitos')) {
          return http.Response(
            jsonEncode([
              {
                'GroupCategory': 'Grupo A',
                'Groupname': 'Equipo 1',
                'GroupCode': 'G1',
                'FirstName': 'Alice',
                'LastName': 'Student',
                'correo': 'test@test.com',
              },
              {
                'GroupCategory': 'Grupo A',
                'Groupname': 'Equipo 1',
                'GroupCode': 'G1',
                'FirstName': 'Bob',
                'LastName': 'Peer',
                'correo': 'bob@test.com',
              },
            ]),
            200,
          );
        }
        if (url.contains('tableName=group_categories')) {
          return http.Response(
            jsonEncode([
              {'_id': 'cat-1', 'course_id': 'course-1', 'name': 'Grupo A', 'source': 'CSV'},
            ]),
            200,
          );
        }
        if (url.contains('tableName=cursos')) {
          return http.Response(
            jsonEncode([
              {
                '_id': 'course-1',
                'code': 'CS101',
                'name': 'Software Design',
                'period': '2024-10',
                'studentsCount': 30,
                'activeEvaluations': 1,
                'totalEvaluations': 2,
              },
            ]),
            200,
          );
        }
        if (url.contains('tableName=responses')) return http.Response('[]', 200);
        if (url.contains('tableName=evaluations') && url.contains('status=active')) {
          return http.Response(
            jsonEncode([
              {
                '_id': 'eval-1',
                'name': 'Sprint 1 Peer Review',
                'status': 'active',
                'visibility': 'public',
                'group_category': 'Grupo A',
                'deadline': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
                'course_id': 'course-1',
              }
            ]),
            200,
          );
        }
        if (url.contains('tableName=evaluations')) {
          return http.Response(
            jsonEncode([
              {
                '_id': 'eval-2',
                'name': 'Sprint 0 Peer Review',
                'status': 'closed',
                'visibility': 'public',
                'group_category': 'Grupo A',
                'deadline': '2024-01-01T14:00:00.000Z',
                'course_id': 'course-1',
              }
            ]),
            200,
          );
        }

        return http.Response('[]', 200);
      });

      when(mockHttpClient.post(
        argThat(isAUri),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: anyNamed('encoding'),
      )).thenAnswer((_) async => http.Response('{}', 201));

      final widget = await createApp();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      await pause(tester, 1500);

      // 1. HomePage
      expect(find.byType(HomePage), findsOneWidget);

      // 2. Log in
      await tapAndPause(tester, find.text('Log in'), 1000);
      expect(find.byType(LoginPage), findsOneWidget);
      await pause(tester, 1000);

      // 3. Credenciales
      await enterTextAndPause(
          tester, find.byKey(const Key('TextFormFieldLoginEmail')), 'test@test.com');
      await enterTextAndPause(
          tester, find.byKey(const Key('TextFormFieldLoginPassword')), 'ThePassword!1.');

      // 4. Login → HomeStudentPage
      await tapAndPause(tester, find.byKey(const Key('ButtonLoginSubmit')), 1500);
      expect(find.byType(HomeStudentPage), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);
      await pause(tester, 1500);

      // 5. Ver evaluaciones activas
      expect(find.text('Active Evaluations'), findsOneWidget);
      expect(find.text('Sprint 1 Peer Review'), findsOneWidget);
      await pause(tester, 2000);


      // 6. Tocar evaluación activa → EvalFormPage
      await tapAndPause(tester, find.text('Evaluate now →'), 1500); // ← fix aquí
      await tester.pumpAndSettle();
      expect(find.byType(EvalFormPage), findsOneWidget);
      
      // 7. Verificar peer a evaluar (Bob Peer — el estudiante no se evalúa a sí mismo)
      expect(find.text('Bob Peer'), findsOneWidget);
      expect(find.text('Peer 1 of 1'), findsOneWidget);
      await pause(tester, 1500);

      // 8. Seleccionar "Good" para cada uno de los 4 criterios
      final goodButtons = find.text('Good');
      for (int i = 0; i < 4; i++) {
        await tester.tap(goodButtons.at(i));
        await tester.pump();
        await pause(tester, 500);
      }

      // 9. Submit → volver a HomeStudentPage
      await tapAndPause(tester, find.text('Submit →'), 1500);
      await tester.pumpAndSettle();
      expect(find.byType(HomeStudentPage), findsOneWidget);
      await pause(tester, 2000);

      // 10. Ver cursos matriculados
      expect(find.text('My Courses'), findsOneWidget);
      expect(find.text('Software Design'), findsWidgets);
      expect(find.text('1 enrolled'), findsOneWidget);
      await pause(tester, 2000);

      // 11. Entrar al curso
      await tapAndPause(tester, find.text('Software Design').last, 1500);
      await tester.pumpAndSettle();
      expect(find.byType(TapCoursePage), findsOneWidget);
      expect(find.text('Sprint 0 Peer Review'), findsOneWidget);
      await pause(tester, 2000);

      // 12. Ver resultados de la evaluación cerrada
      await tapAndPause(tester, find.text('View results →'), 1500);
      expect(find.byType(AnalyticsStudentPage), findsOneWidget);
      expect(find.text('No results available yet.'), findsOneWidget);
      await pause(tester, 2000);

      // 13. Volver → TapCoursePage → HomeStudentPage
      await tapAndPause(tester, find.byIcon(Icons.chevron_left), 1000);
      await tapAndPause(tester, find.byIcon(Icons.chevron_left), 1000);
      expect(find.byType(HomeStudentPage), findsOneWidget);
      await pause(tester, 1000);

      // 14. Logout
      await tapAndPause(tester, find.byType(PopupMenuButton<String>), 800);
      await tapAndPause(tester, find.text('Sign out'), 1500);
      expect(find.byType(HomePage), findsOneWidget);
      await pause(tester, 2000);
    },
  );
}
