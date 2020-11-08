import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/data/daos/daos.dart';
import 'package:password_wallet/src/data/models/models.dart';
import 'package:password_wallet/src/repositories/repositories.dart';

class MockUserDao extends Mock implements UserDao {}

void main() {
  final MockUserDao mockUserDao = MockUserDao();

  setUp(() {});
  tearDown(() {
    reset(mockUserDao);
  });

  group(
    'User Repository',
    () {
      test(
        'Given valid username When get user by username is called Then user is returned',
        () async {
          /// Given
          final User testUser = User(
            id: 1,
            username: 'Test Username',
            passwordHash: 'Test Password Hash',
            salt: 'Test Salt',
            isPasswordKeptAsHash: true,
          );

          when(mockUserDao.getUserByUsername(username: anyNamed('username')))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserRepository userRepository = UserRepository(userDao: mockUserDao);

          /// When
          final User resultUser = await userRepository.getUserByUsername(testUser.username);

          /// Then
          expect(
            verify(mockUserDao.getUserByUsername(username: captureAnyNamed('username'))).captured.single,
            testUser.username,
          );

          expect(resultUser, isNotNull);
          expect(resultUser, isA<User>());
          expect(resultUser.id, testUser.id);
          expect(resultUser.username, testUser.username);
          expect(resultUser.passwordHash, testUser.passwordHash);
          expect(resultUser.salt, testUser.salt);
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

          when(mockUserDao.createUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final UserRepository userRepository = UserRepository(userDao: mockUserDao);

          /// When
          final int result = await userRepository.createUser(testUser);

          /// Then
          final dynamic capturedUser = verify(mockUserDao.createUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser.id, testUser.id);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testUser.passwordHash);
          expect(capturedUser.salt, testUser.salt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

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

          when(mockUserDao.updateUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final UserRepository userRepository = UserRepository(userDao: mockUserDao);

          /// When
          final int result = await userRepository.updateUser(testUser);

          /// Then
          final dynamic capturedUser = verify(mockUserDao.updateUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser.id, testUser.id);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testUser.passwordHash);
          expect(capturedUser.salt, testUser.salt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

          expect(result, 1);
        },
      );
    },
  );
}
