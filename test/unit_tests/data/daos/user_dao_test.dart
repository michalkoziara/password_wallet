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

void main() {
  final MockDatabase mockDatabase = MockDatabase();

  setUp(() {});
  tearDown(() {
    reset(mockDatabase);
  });

  group(
    'User Data Access Object',
    () {
      test(
        'Given valid username When get user by username is called Then user is returned',
        () async {
          /// Given
          const Map<String, dynamic> testUserMap = <String, dynamic>{
            'id': 1,
            'username': 'Test Username',
            'passwordHash': 'Test Password Hash',
            'salt': 'Test Salt',
            'isPasswordKeptAsHash': 'true',
          };

          when(
            mockDatabase.query(
              any,
              columns: anyNamed('columns'),
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
            ),
          ).thenAnswer(
            (Invocation realInvocation) => Future<List<Map<String, dynamic>>>.value(
              <Map<String, dynamic>>[testUserMap],
            ),
          );

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final UserDao userDao = UserDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final User resultUser = await userDao.getUserByUsername(username: testUserMap['username'] as String);

          /// Then
          expect(resultUser, isNotNull);
          expect(resultUser, isA<User>());
          expect(resultUser.id, testUserMap['id']);
          expect(resultUser.username, testUserMap['username']);
          expect(resultUser.passwordHash, testUserMap['passwordHash']);
          expect(resultUser.salt, testUserMap['salt']);
          expect(resultUser.isPasswordKeptAsHash, true);
        },
      );

      test(
        'Given valid user data When create user is called Then success is returned',
        () async {
          /// Given
          final User testUser = User(
            id: 1,
            username: 'Test Username',
            passwordHash: 'Test Password Hash',
            salt: 'Test Salt',
            isPasswordKeptAsHash: true,
          );

          when(mockDatabase.insert(any, any)).thenAnswer(
            (Invocation realInvocation) => Future<int>.value(1),
          );

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final UserDao userDao = UserDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final int result = await userDao.createUser(testUser);

          /// Then
          expect(result, 1);
        },
      );

      test(
        'Given valid user data When update user is called Then success is returned',
        () async {
          /// Given
          final User testUser = User(
            id: 1,
            username: 'Test Username',
            passwordHash: 'Test Password Hash',
            salt: 'Test Salt',
            isPasswordKeptAsHash: true,
          );

          when(
            mockDatabase.update(
              any,
              any,
              where: anyNamed('where'),
              whereArgs: anyNamed('whereArgs'),
            ),
          ).thenAnswer(
            (Invocation realInvocation) => Future<int>.value(1),
          );

          final FakeDatabaseProvider fakeDatabaseProvider = FakeDatabaseProvider(Future<Database>.value(mockDatabase));
          final UserDao userDao = UserDao(databaseProvider: fakeDatabaseProvider);

          /// When
          final int result = await userDao.updateUser(testUser);

          /// Then
          expect(result, 1);
        },
      );
    },
  );
}
