// integration_test/app_test.dart

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
import 'package:src/features/auth/data/datasources/remote/i_authentication_source.dart';
import 'package:src/features/auth/data/repository/auth_repository.dart';
import 'package:src/features/auth/domain/models/authentication_user.dart';
import 'package:src/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:src/features/auth/presentation/pages/login_page.dart';
import 'package:src/features/auth/presentation/viewmodels/user_controller.dart';
import 'package:src/features/eval-form/data/datasources/eval_form_datasource.dart';
import 'package:src/features/eval-form/data/datasources/remote_eval_form_datasource.dart';
import 'package:src/features/eval-form/data/repositories/eval_form_repository_impl.dart';
import 'package:src/features/eval-form/domain/repositories/i_eval_form_repository.dart';
import 'package:src/features/eval-form/domain/usecases/get_submitted_evaluation_ids.dart';
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
  Future<http.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => super.noSuchMethod(
    Invocation.method(
      #post,
      [url],
      {#headers: headers, #body: body, #encoding: encoding},
    ),
    returnValue: Future.value(http.Response('{}', 201)),
    returnValueForMissingStub: Future.value(http.Response('{}', 201)),
  );
}

class FakeLocalPreferences implements ILocalPreferences {
  final Map<String, String> _storage = {};
  @override
  Future<String?> getString(String key) async => _storage[key];
  @override
  Future<void> setString(String key, String value) async =>
      _storage[key] = value;
  @override
  Future<void> remove(String key) async => _storage.remove(key);
  @override
  Future<void> clear() async => _storage.clear();
  @override
  Future<bool?> getBool(String key) async => null;
  @override
  Future<void> setBool(String key, bool value) async {}
  @override
  Future<double?> getDouble(String key) async => null;
  @override
  Future<void> setDouble(String key, double value) async {}
  @override
  Future<int?> getInt(String key) async => null;
  @override
  Future<void> setInt(String key, int value) async {}
  @override
  Future<List<String>?> getStringList(String key) async => null;
  @override
  Future<void> setStringList(String key, List<String> value) async {}
}

class FakeAuthenticationSource implements IAuthenticationSource {
  bool _logged = false;
  bool _isStudent = false;

  void setStudent(bool value) => _isStudent = value;

  @override
  Future<void> login(String email, String password) async => _logged = true;
  @override
  Future<void> signUp(
    String email,
    String password,
    String name,
    bool direct,
  ) async {}
  @override
  Future<bool> logOut() async {
    _logged = false;
    return true;
  }

  @override
  Future<bool> validate(String email, String code) async => true;
  @override
  Future<bool> refreshToken() async => true;
  @override
  Future<bool> forgotPassword(String email) async => true;
  @override
  Future<bool> resetPassword(
    String email,
    String password,
    String code,
  ) async => true;
  @override
  Future<bool> verifyToken() async => _logged;
  @override
  Future<AuthenticationUser> getLoggedUser() async => AuthenticationUser(
    id: 'user-1',
    email: 'test@test.com',
    name: _isStudent ? 'Alice Student' : 'Josh Professor',
    student: _isStudent,
  );
  @override
  Future<List<AuthenticationUser>> getUsers() async => [];
}

// Variables no late — se inicializan en setUp
MockHttpClient mockHttpClient = MockHttpClient();
FakeAuthenticationSource fakeAuthSource = FakeAuthenticationSource();

Future<Widget> createApp() async {
  Get.testMode = false;
  Get.reset();

  final fakePrefs = FakeLocalPreferences();
  await fakePrefs.setString('userId', 'prof-1');
  await fakePrefs.setString('token', 'fake-token');
  await fakePrefs.setString('userEmail', 'test@test.com');
  Get.put<ILocalPreferences>(fakePrefs);
  Get.put<IAuthenticationSource>(fakeAuthSource);
  Get.put<http.Client>(mockHttpClient, tag: 'apiClient', permanent: true);
  Get.put<IAuthRepository>(AuthRepository(Get.find()));
  Get.put(UserController(Get.find()));

  // Profesor
  Get.lazyPut<HomeProfessorDataSource>(
    () =>
        RemoteHomeProfessorDataSource(Get.find<http.Client>(tag: 'apiClient')),
  );
  Get.lazyPut(
    () => LocalHomeProfessorCacheSource(Get.find<ILocalPreferences>()),
  );
  Get.lazyPut<HomeProfessorRepository>(
    () => HomeProfessorRepositoryImpl(Get.find(), Get.find()),
  );
  Get.lazyPut(() => GetAssignedCourses(Get.find()));
  Get.lazyPut(() => HomeProfessorController(getAssignedCourses: Get.find()));

  // EvalForm — necesario para GetSubmittedEvaluationIds
  Get.lazyPut<EvalFormDatasource>(
    () => RemoteEvalFormDatasource(Get.find<http.Client>(tag: 'apiClient')),
  );
  Get.lazyPut<IEvalFormRepository>(() => EvalFormRepositoryImpl(Get.find()));
  Get.lazyPut(() => GetSubmittedEvaluationIds(Get.find()));

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
  Get.lazyPut(
    () => HomeStudentController(
      getActiveEvaluations: Get.find(),
      getEnrolledCourses: Get.find(),
      getSubmittedEvaluationIds: Get.find(),
    ),
  );

  // TapCourse
  Get.lazyPut(() => CsvGroupParser());
  Get.lazyPut<TapCourseDatasource>(
    () => RemoteTapCourseDatasource(
      Get.find<http.Client>(tag: 'apiClient'),
      Get.find(),
    ),
  );
  Get.lazyPut<TapCourseRepository>(
    () => TapCourseRepositoryImpl(
      datasource: Get.find(),
      csvParser: Get.find(),
      cacheSource: Get.find(),
    ),
  );
  Get.lazyPut(() => GetCourseEvaluations(Get.find()));
  Get.lazyPut(() => GetCourseGroups(Get.find()));
  Get.lazyPut(() => ImportGroupsFromCsv(Get.find()));

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
      print('FLUTTER ERROR: ${details.exception}');
      print('STACK: ${details.stack}');
    };
  });
  tearDown(() => Get.reset());

  testWidgets(
    'Flujo profesor: login → ver cursos → entrar a curso → volver → logout',
    (WidgetTester tester) async {
      fakeAuthSource.setStudent(false);

      when(
        mockHttpClient.get(argThat(isAUri), headers: anyNamed('headers')),
      ).thenAnswer((invocation) async {
        final url = (invocation.positionalArguments[0] as Uri).toString();

        if (url.contains('tableName=evaluations')) {
          return http.Response('[]', 200); // sin evaluaciones
        }
        if (url.contains('tableName=group_categories')) {
          return http.Response('[]', 200); // sin grupos
        }
        if (url.contains('tableName=grupitos')) {
          return http.Response('[]', 200);
        }

        // cursos — respuesta por defecto
        return http.Response(
          jsonEncode([
            {
              '_id': 'course-1',
              'code': 'CS101',
              'name': 'Software Design',
              'period': '2024-10',
              'studentsCount': 30,
              'activeEvaluations': 2,
              'totalEvaluations': 3,
            },
          ]),
          200,
        );
      });

      final widget = await createApp();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Evaluo'), findsOneWidget);

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('TextFormFieldLoginEmail')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('TextFormFieldLoginEmail')),
        'prof@test.com',
      );
      await tester.enterText(
        find.byKey(const Key('TextFormFieldLoginPassword')),
        'ThePassword!1.',
      );
      await tester.tap(find.byKey(const Key('ButtonLoginSubmit')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeProfessorPage), findsOneWidget);
      expect(find.text('Software Design'), findsOneWidget);
      expect(find.text('Teacher · Computer Science'), findsOneWidget);

      await tester.tap(find.text('Software Design'));
      await tester.pumpAndSettle();

      expect(find.byType(TapCoursePage), findsOneWidget);
      expect(find.text('Evaluations'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('No evaluations yet'), findsOneWidget);

      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('No groups yet'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.byType(HomeProfessorPage), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    },
  );

  testWidgets(
    'Flujo estudiante: login → ver evaluaciones → ver cursos → logout',
    (WidgetTester tester) async {
      fakeAuthSource.setStudent(true);

      when(
        mockHttpClient.get(argThat(isAUri), headers: anyNamed('headers')),
      ).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        final url = uri.toString();

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
            ]),
            200,
          );
        }

        if (url.contains('tableName=group_categories')) {
          return http.Response(
            jsonEncode([
              {
                '_id': 'cat-1',
                'course_id': 'course-1',
                'name': 'Grupo A',
                'source': 'CSV',
              },
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

        if (url.contains('tableName=responses')) {
          return http.Response('[]', 200);
        }

        if (url.contains('tableName=evaluations')) {
          return http.Response('[]', 200);
        }

        return http.Response('[]', 200);
      });

      final widget = await createApp();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('TextFormFieldLoginEmail')),
        'test@test.com',
      );
      await tester.enterText(
        find.byKey(const Key('TextFormFieldLoginPassword')),
        'ThePassword!1.',
      );
      await tester.tap(find.byKey(const Key('ButtonLoginSubmit')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeStudentPage), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Active Evaluations'), findsOneWidget);
      expect(find.text('My Courses'), findsOneWidget);
      expect(find.text('Software Design'), findsOneWidget);
      expect(find.text('1 enrolled'), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Evaluo'), findsOneWidget);
    },
  );
}
