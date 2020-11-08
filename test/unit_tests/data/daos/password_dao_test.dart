import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/data/daos/daos.dart';
import 'package:password_wallet/src/data/data_sources/database_provider.dart';
import 'package:password_wallet/src/data/models/models.dart';
import 'package:sqflite/sqflite.dart';

class FakeDatabaseProvider extends Fake implements DatabaseProvider {
  FakeDatabaseProvider(this._database);

  final Future<Database> _database;

  @override
  Future<Database> get database async {
    return _database;
  }
}

class MockDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

void main() {
  final MockDatabase mockDatabase = MockDatabase();
  final MockBatch mockBatch = MockBatch();

  setUp(() {});
  tearDown(() {
    reset(mockDatabase);
    reset(mockBatch);
  });

  group(
    'Password Data Access Object',
    () {
      test(
        'Given valid user ID When get passwords is called Then passwords are returned',
        () async {
          /// Given
          const List<Map<String, dynamic>> testPasswordMaps = <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'userId': 1,
              'password': 'Test Password',
              'vector': 'Test Vector',
              'webAddress': 'Test Web Address',
              'description': 'Test Description',
              'login': 'Test Login',
            }
          ];

          when(
            mockDatabase.query(
              any,
              columns: anyNamed('columns'),
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
            ),
          ).thenAnswer(
            (Invocation realInvocation) => Future<List<Map<String, dynamic>>>.value(testPasswordMaps),
          );

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final PasswordDao passwordDao = PasswordDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final List<Password> resultPasswords =
              await passwordDao.getPasswordsByUserId(userId: testPasswordMaps[0]['userId'] as int);

          /// Then
          expect(resultPasswords, isNotNull);
          expect(resultPasswords.length, testPasswordMaps.length);

          for (int i = 0; i < resultPasswords.length; i++) {
            expect(resultPasswords[i].userId, testPasswordMaps[i]['userId']);
            expect(resultPasswords[i].password, testPasswordMaps[i]['password']);
            expect(resultPasswords[i].vector, testPasswordMaps[i]['vector']);
            expect(resultPasswords[i].webAddress, testPasswordMaps[i]['webAddress']);
            expect(resultPasswords[i].description, testPasswordMaps[i]['description']);
            expect(resultPasswords[i].login, testPasswordMaps[i]['login']);
          }
        },
      );

      test(
        'Given invalid user ID When get passwords is called Then no passwords are returned',
        () async {
          /// Given
          when(
            mockDatabase.query(
              any,
              columns: anyNamed('columns'),
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
            ),
          ).thenAnswer(
            (Invocation realInvocation) => Future<List<Map<String, dynamic>>>.value(<Map<String, dynamic>>[]),
          );

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final PasswordDao passwordDao = PasswordDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final List<Password> resultPasswords = await passwordDao.getPasswordsByUserId(userId: 1);

          /// Then
          expect(resultPasswords, isNotNull);
          expect(resultPasswords.length, 0);
        },
      );

      test(
        'Given valid password ID When get password is called Then password is returned',
        () async {
          /// Given
          const List<Map<String, dynamic>> testPasswordMaps = <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'userId': 1,
              'password': 'Test Password',
              'vector': 'Test Vector',
              'webAddress': 'Test Web Address',
              'description': 'Test Description',
              'login': 'Test Login',
            }
          ];

          when(
            mockDatabase.query(
              any,
              columns: anyNamed('columns'),
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
            ),
          ).thenAnswer(
            (Invocation realInvocation) => Future<List<Map<String, dynamic>>>.value(testPasswordMaps),
          );

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final PasswordDao passwordDao = PasswordDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final Password resultPassword = await passwordDao.getPasswordById(id: testPasswordMaps[0]['id'] as int);

          /// Then
          expect(resultPassword, isNotNull);

          expect(resultPassword.userId, testPasswordMaps[0]['userId']);
          expect(resultPassword.password, testPasswordMaps[0]['password']);
          expect(resultPassword.vector, testPasswordMaps[0]['vector']);
          expect(resultPassword.webAddress, testPasswordMaps[0]['webAddress']);
          expect(resultPassword.description, testPasswordMaps[0]['description']);
          expect(resultPassword.login, testPasswordMaps[0]['login']);
        },
      );

      test(
        'Given invalid password ID When get password is called Then no password is returned',
        () async {
          /// Given
          when(
            mockDatabase.query(
              any,
              columns: anyNamed('columns'),
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
            ),
          ).thenAnswer(
            (Invocation realInvocation) => Future<List<Map<String, dynamic>>>.value(<Map<String, dynamic>>[]),
          );

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final PasswordDao passwordDao = PasswordDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final Password resultPassword = await passwordDao.getPasswordById(id: 1);

          /// Then
          expect(resultPassword, isNull);
        },
      );

      test(
        'Given valid password data When create password is called Then success is returned',
        () async {
          /// Given
          final Password testPassword = Password(
            id: 1,
            userId: 1,
            password: 'Test Password',
            vector: 'Test Vector',
            webAddress: 'Test Web Address',
            description: 'Test Description',
            login: 'Test Login',
          );

          when(mockDatabase.insert(any, any)).thenAnswer(
            (Invocation realInvocation) => Future<int>.value(1),
          );

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final PasswordDao passwordDao = PasswordDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final int result = await passwordDao.createPassword(testPassword);

          /// Then
          expect(result, 1);
        },
      );

      test(
        'Given valid passwords data When update passwords is called Then success is returned',
        () async {
          /// Given
          final List<Password> testPasswords = <Password>[
            Password(
              id: 1,
              userId: 1,
              password: 'Test Password',
              vector: 'Test Vector',
              webAddress: 'Test Web Address',
              description: 'Test Description',
              login: 'Test Login',
            )
          ];

          when(mockDatabase.batch()).thenReturn(mockBatch);

          when(
            mockBatch.update(
              any,
              any,
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
            ),
          ).thenReturn(null);

          when(mockBatch.commit()).thenAnswer((Invocation realInvocation) => Future<List<int>>.value(<int>[1]));

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final PasswordDao passwordDao = PasswordDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final List<dynamic> results = await passwordDao.updatePasswords(testPasswords);

          /// Then
          expect(results, isNotNull);
          expect(results, isA<List<int>>());

          for (final dynamic result in results) {
            expect(result, 1);
          }
        },
      );
    },
  );
}
