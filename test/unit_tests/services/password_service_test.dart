import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/data/models/models.dart';
import 'package:password_wallet/src/repositories/repositories.dart';
import 'package:password_wallet/src/services/services.dart';
import 'package:password_wallet/src/utils/failure.dart';
import 'package:password_wallet/src/utils/random_values_generator.dart';

import '../../test.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockPasswordRepository extends Mock implements PasswordRepository {}

class MockDataChangeService extends Mock implements DataChangeService {}

class MockRandomValuesGenerator extends Mock implements RandomValuesGenerator {}

void main() {
  final MockUserRepository mockUserRepository = MockUserRepository();
  final MockPasswordRepository mockPasswordRepository = MockPasswordRepository();
  final MockDataChangeService mockDataChangeService = MockDataChangeService();
  final MockRandomValuesGenerator mockRandomValuesGenerator = MockRandomValuesGenerator();

  setUp(() {});
  tearDown(() {
    reset(mockUserRepository);
    reset(mockPasswordRepository);
    reset(mockDataChangeService);
    reset(mockRandomValuesGenerator);
  });

  group(
    'Get Passwords',
    () {
      group(
        'Given valid user with passwords When get passwords is called Then passwords are returned',
        () {
          final List<Map<String, dynamic>> parametersSeries = <Map<String, dynamic>>[
            <String, dynamic>{
              'testUser': User(id: 1, username: 'User with the same passwords'),
              'testPasswords': <Password>[
                for (int i = 0; i < 5; i++)
                  Password(
                      userId: 1,
                      password: 'Password',
                      vector: 'Vector',
                      webAddress: 'WebAddress',
                      description: 'Description',
                      login: 'Login')
              ]
            },
            <String, dynamic>{
              'testUser': User(id: 1231, username: 'User with various passwords'),
              'testPasswords': <Password>[
                Password(
                    userId: 1231,
                    password: 'First password',
                    vector: 'Vector',
                    webAddress: 'WebAddress',
                    description: 'Description',
                    login: 'Login'),
                Password(
                    userId: 1231,
                    password: 'Second password',
                    vector: 'Vector',
                    webAddress: 'WebAddress',
                    description: 'Description',
                    login: 'Login')
              ]
            },
          ];

          void parametrize({User testUser, List<Password> testPasswords}) {
            test(
              testUser.toString() + testPasswords.toString(),
              () async {
                /// Given
                when(mockUserRepository.getUserByUsername(any))
                    .thenAnswer((Invocation realInvocation) => Future<User>.value(testUser));

                when(mockPasswordRepository.getPasswordsByUserId(any)).thenAnswer(
                  (Invocation realInvocation) => Future<List<Password>>.value(
                    testPasswords.map((Password testPassword) => Password.copy(testPassword)).toList(),
                  ),
                );

                final PasswordService passwordService =
                    PasswordService(mockPasswordRepository, mockUserRepository, mockDataChangeService, null);

                /// When
                final Either<Failure, List<Password>> result =
                    await passwordService.getPasswords(username: testUser.username);

                /// Then
                result.fold(
                  (Failure exception) => expect(exception, isNull),
                  (List<Password> resultPasswords) {
                    expect(resultPasswords, isNotNull);
                    expect(resultPasswords.length, testPasswords.length);

                    for (int i = 0; i < resultPasswords.length; i++) {
                      expect(resultPasswords[i].userId, testPasswords[i].userId);
                      expect(resultPasswords[i].password, testPasswords[i].password);
                      expect(resultPasswords[i].vector, testPasswords[i].vector);
                      expect(resultPasswords[i].webAddress, testPasswords[i].webAddress);
                      expect(resultPasswords[i].description, testPasswords[i].description);
                      expect(resultPasswords[i].login, testPasswords[i].login);
                    }
                  },
                );
              },
            );
          }

          Test.runParametrized(parametersSeries, parametrize);
        },
      );

      test(
        'Given no user When get passwords is called Then failure about non-existent user is returned',
        () async {
          /// Given
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(null));

          final PasswordService passwordService =
              PasswordService(null, mockUserRepository, mockDataChangeService, null);

          /// When
          final Either<Failure, List<Password>> result = await passwordService.getPasswords(username: null);

          /// Then
          result.fold(
            (Failure exception) => expect(exception, isA<NonExistentUserFailure>()),
            (List<Password> resultPasswords) => expect(resultPasswords, isNull),
          );
        },
      );
    },
  );

  group(
    'Get Password',
    () {
      test(
        "Given valid password ID and user's password When get password is called Then decrypted password is returned",
        () async {
          /// Given
          const int testId = 1;
          const String testUserPassword = 'test';
          const String testPasswordDecrypted = 'testPasswordValue';

          final Password testPassword = Password(
            id: testId,
            password: 'jTZquXptcOZVzWy9DfvYaPVr6AKS1K2FJWomYny/0rI=',
            vector: '8UegaAIYAzBdDzA613P/hQ==',
            webAddress: 'google.com',
            description: 'My test password.',
            login: 'Test Login',
          );

          when(mockPasswordRepository.getPasswordById(any))
              .thenAnswer((Invocation realInvocation) => Future<Password>.value(testPassword));

          final PasswordService passwordService =
              PasswordService(mockPasswordRepository, mockUserRepository, mockDataChangeService, null);

          /// When
          final Either<Failure, String> result =
              await passwordService.getPassword(id: testId, userPassword: testUserPassword);

          /// Then
          result.fold(
            (Failure exception) => expect(exception, isNull),
            (String resultPassword) => expect(resultPassword, testPasswordDecrypted),
          );
        },
      );

      test(
        'Given invalid password ID When get password is called Then failure about non-existent user is returned',
        () async {
          /// Given
          const String testUserPassword = 'testUserPassword';

          when(mockPasswordRepository.getPasswordById(any)).thenAnswer((Invocation realInvocation) => null);

          final PasswordService passwordService =
              PasswordService(mockPasswordRepository, mockUserRepository, mockDataChangeService, null);

          /// When
          final Either<Failure, String> result =
              await passwordService.getPassword(id: null, userPassword: testUserPassword);

          /// Then
          result.fold(
            (Failure exception) => expect(exception, isA<NonExistentUserFailure>()),
            (String resultPassword) => expect(resultPassword, isNull),
          );
        },
      );
    },
  );

  group(
    'Create Password',
    () {
      test(
        "Given valid password parameters and user's ID When create password is called Then create password",
        () async {
          /// Given
          final Password testPassword = Password(
            userId: 1,
            password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
            vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
            webAddress: 'google.com',
            description: 'My test password.',
            login: 'Test Login',
          );

          const String testUserPassword = 'test';
          const String testPasswordValue = 'testPasswordValue';

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          final PasswordService passwordService =
              PasswordService(null, null, mockDataChangeService, mockRandomValuesGenerator);

          /// When
          final Password result = passwordService.createPassword(
            login: testPassword.login,
            webAddress: testPassword.webAddress,
            password: testPasswordValue,
            description: testPassword.description,
            userId: testPassword.userId,
            userPassword: testUserPassword,
          );

          /// Then
          expect(result, isNotNull);
          expect(result.userId, testPassword.userId);
          expect(result.login, testPassword.login);
          expect(result.webAddress, testPassword.webAddress);
          expect(result.description, testPassword.description);
          expect(result.vector, testPassword.vector);
          expect(result.password, testPassword.password);
        },
      );
    },
  );

  group(
    'Add Password',
    () {
      test(
        "Given valid password parameters and user's data When add password is called Then add password",
        () async {
          /// Given
          final Password testPassword = Password(
            userId: 1,
            password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
            vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
            webAddress: 'google.com',
            description: 'My test password.',
            login: 'Test Login',
          );
          const String testPasswordValue = 'testPasswordValue';

          final User testUser = User(id: 1);
          const String testUsername = 'test';
          const String testUserPassword = 'test';

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          when(mockPasswordRepository.createPassword(any))
              .thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final PasswordService passwordService = PasswordService(
              mockPasswordRepository, mockUserRepository, mockDataChangeService, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await passwordService.addPassword(
            login: testPassword.login,
            webAddress: testPassword.webAddress,
            password: testPasswordValue,
            description: testPassword.description,
            username: testUsername,
            userPassword: testUserPassword,
          );

          /// Then
          result.fold(
            (Failure exception) => expect(exception, isNull),
            (void _) => _,
          );

          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedPassword = verify(mockPasswordRepository.createPassword(captureAny)).captured.single;
          expect(capturedPassword, isNotNull);
          expect(capturedPassword.userId, testPassword.userId);
          expect(capturedPassword.login, testPassword.login);
          expect(capturedPassword.webAddress, testPassword.webAddress);
          expect(capturedPassword.description, testPassword.description);
          expect(capturedPassword.vector, testPassword.vector);
          expect(capturedPassword.password, testPassword.password);
        },
      );

      test(
        "Given invalid user's data When add password is called Then failure about non-existent user is returned",
        () async {
          /// Given
          when(mockUserRepository.getUserByUsername(any)).thenAnswer((Invocation realInvocation) => null);

          final PasswordService passwordService =
              PasswordService(null, mockUserRepository, mockDataChangeService, null);

          /// When
          final Either<Failure, void> result = await passwordService.addPassword(
            login: null,
            webAddress: null,
            password: null,
            description: null,
            username: null,
            userPassword: null,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, null);

          result.fold(
            (Failure exception) => expect(exception, isA<NonExistentUserFailure>()),
            (void _) => _,
          );
        },
      );

      test(
        "Given invalid password parameters and valid user's data When add password is called Then failure is returned",
        () async {
          /// Given
          final Password testPassword = Password(
            userId: 1,
            password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
            vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
            webAddress: 'google.com',
            description: 'My test password.',
            login: 'Test Login',
          );
          const String testPasswordValue = 'testPasswordValue';

          final User testUser = User(id: 1);
          const String testUsername = 'test';
          const String testUserPassword = 'test';

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          when(mockPasswordRepository.createPassword(any))
              .thenAnswer((Invocation realInvocation) => Future<int>.value(-1));

          final PasswordService passwordService = PasswordService(
              mockPasswordRepository, mockUserRepository, mockDataChangeService, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await passwordService.addPassword(
            login: testPassword.login,
            webAddress: testPassword.webAddress,
            password: testPasswordValue,
            description: testPassword.description,
            username: testUsername,
            userPassword: testUserPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedPassword = verify(mockPasswordRepository.createPassword(captureAny)).captured.single;
          expect(capturedPassword, isNotNull);
          expect(capturedPassword.userId, testPassword.userId);
          expect(capturedPassword.login, testPassword.login);
          expect(capturedPassword.webAddress, testPassword.webAddress);
          expect(capturedPassword.description, testPassword.description);
          expect(capturedPassword.vector, testPassword.vector);
          expect(capturedPassword.password, testPassword.password);

          result.fold(
            (Failure exception) => expect(exception, isA<PasswordCreationFailure>()),
            (void _) => _,
          );
        },
      );
    },
  );
}
