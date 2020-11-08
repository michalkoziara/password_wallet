import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/data/models/models.dart';
import 'package:password_wallet/src/repositories/repositories.dart';
import 'package:password_wallet/src/services/services.dart';
import 'package:password_wallet/src/utils/failure.dart';
import 'package:password_wallet/src/utils/random_values_generator.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockPasswordRepository extends Mock implements PasswordRepository {}

class MockRandomValuesGenerator extends Mock implements RandomValuesGenerator {}

void main() {
  final MockUserRepository mockUserRepository = MockUserRepository();
  final MockPasswordRepository mockPasswordRepository = MockPasswordRepository();
  final MockRandomValuesGenerator mockRandomValuesGenerator = MockRandomValuesGenerator();

  setUp(() {});
  tearDown(() {
    reset(mockUserRepository);
    reset(mockPasswordRepository);
    reset(mockRandomValuesGenerator);
  });

  group(
    'Register User',
    () {
      test(
        "Given valid user's data with chosen SHA512 algorithm When register user is called Then user is created",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserPassword = 'test';
          const bool testIsEncryptingAlgorithmSha = true;

          final User testUser = User(
            username: testUsername,
            passwordHash:
                '2fcdba02fad94d96774b935791103d4e31b17c71bf0afb02c433f009b0bd22ec28e3a39f375b6d5e29f135262209b397350adb38f86dec525829a290c80d7fd3',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: testIsEncryptingAlgorithmSha,
          );

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(mockUserRepository.getUserByUsername(any)).thenAnswer((Invocation realInvocation) => null);

          when(mockUserRepository.createUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final UserService userService = UserService(mockUserRepository, null, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await userService.registerUser(
            username: testUsername,
            password: testUserPassword,
            isEncryptingAlgorithmSha: testIsEncryptingAlgorithmSha,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedUser = verify(mockUserRepository.createUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testUser.passwordHash);
          expect(capturedUser.salt, testUser.salt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

          result.fold(
            (Failure exception) => expect(exception, isNull),
            (void _) => _,
          );
        },
      );

      test(
        "Given valid user's data with chosen HMAC-SHA512 algorithm When register user is called Then user is created",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserPassword = 'test';
          const bool testIsEncryptingAlgorithmSha = false;

          final User testUser = User(
            username: testUsername,
            passwordHash:
                '6a148235e17c392cad995e30cc9bb08e808ba0be2a33cb419852686156d615cce6390edcc84db71a337787efd620f3d36b1bf502b4ce98d8f0f6c279a004065c',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: testIsEncryptingAlgorithmSha,
          );

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(mockUserRepository.getUserByUsername(any)).thenAnswer((Invocation realInvocation) => null);

          when(mockUserRepository.createUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final UserService userService = UserService(mockUserRepository, null, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await userService.registerUser(
            username: testUsername,
            password: testUserPassword,
            isEncryptingAlgorithmSha: testIsEncryptingAlgorithmSha,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedUser = verify(mockUserRepository.createUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testUser.passwordHash);
          expect(capturedUser.salt, testUser.salt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

          result.fold(
            (Failure exception) => expect(exception, isNull),
            (void _) => _,
          );
        },
      );

      test(
        "Given existing user's data When register user is called Then failure about already existing user is returned',",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserPassword = 'test';
          const bool testIsEncryptingAlgorithmSha = true;

          final User testUser = User(
            username: testUsername,
            passwordHash:
                '2fcdba02fad94d96774b935791103d4e31b17c71bf0afb02c433f009b0bd22ec28e3a39f375b6d5e29f135262209b397350adb38f86dec525829a290c80d7fd3',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: testIsEncryptingAlgorithmSha,
          );

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserService userService = UserService(mockUserRepository, null, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await userService.registerUser(
            username: testUsername,
            password: testUserPassword,
            isEncryptingAlgorithmSha: testIsEncryptingAlgorithmSha,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          result.fold(
            (Failure exception) => expect(exception, isA<AlreadyExistingUserFailure>()),
            (void _) => _,
          );
        },
      );

      test(
        "Given valid user's data When register user failed Then failure is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserPassword = 'test';
          const bool testIsEncryptingAlgorithmSha = true;

          final User testUser = User(
            username: testUsername,
            passwordHash:
                '2fcdba02fad94d96774b935791103d4e31b17c71bf0afb02c433f009b0bd22ec28e3a39f375b6d5e29f135262209b397350adb38f86dec525829a290c80d7fd3',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: testIsEncryptingAlgorithmSha,
          );

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(mockUserRepository.getUserByUsername(any)).thenAnswer((Invocation realInvocation) => null);

          when(mockUserRepository.createUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(-1));

          final UserService userService = UserService(mockUserRepository, null, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await userService.registerUser(
            username: testUsername,
            password: testUserPassword,
            isEncryptingAlgorithmSha: testIsEncryptingAlgorithmSha,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedUser = verify(mockUserRepository.createUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testUser.passwordHash);
          expect(capturedUser.salt, testUser.salt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

          result.fold(
            (Failure exception) => expect(exception, isA<UserCreationFailure>()),
            (void _) => _,
          );
        },
      );
    },
  );

  group(
    'Check Credentials',
    () {
      test(
        "Given valid user's credentials with chosen SHA512 algorithm When check credentials is called Then success is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserPassword = 'test';

          final User testUser = User(
            username: testUsername,
            passwordHash:
                '2fcdba02fad94d96774b935791103d4e31b17c71bf0afb02c433f009b0bd22ec28e3a39f375b6d5e29f135262209b397350adb38f86dec525829a290c80d7fd3',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: true,
          );

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserService userService = UserService(mockUserRepository, null, null);

          /// When
          final Either<Failure, void> result = await userService.checkCredentials(
            username: testUsername,
            password: testUserPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          result.fold(
            (Failure exception) => expect(exception, isNull),
            (void _) => _,
          );
        },
      );

      test(
        "Given valid user's credentials with chosen HMAC-SHA512 algorithm When check credentials is called Then success is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserPassword = 'test';

          final User testUser = User(
            username: testUsername,
            passwordHash:
                '6a148235e17c392cad995e30cc9bb08e808ba0be2a33cb419852686156d615cce6390edcc84db71a337787efd620f3d36b1bf502b4ce98d8f0f6c279a004065c',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: false,
          );

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserService userService = UserService(mockUserRepository, null, null);

          /// When
          final Either<Failure, void> result = await userService.checkCredentials(
            username: testUsername,
            password: testUserPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          result.fold(
            (Failure exception) => expect(exception, isNull),
            (void _) => _,
          );
        },
      );

      test(
        "Given non-existent user's credentials When check credentials is called Then failure about non-existent user is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserPassword = 'test';

          when(mockUserRepository.getUserByUsername(any)).thenAnswer((Invocation realInvocation) => null);

          final UserService userService = UserService(mockUserRepository, null, null);

          /// When
          final Either<Failure, void> result = await userService.checkCredentials(
            username: testUsername,
            password: testUserPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          result.fold(
            (Failure exception) => expect(exception, isA<NonExistentUserFailure>()),
            (void _) => _,
          );
        },
      );

      test(
        "Given invalid user's credentials When check credentials is called Then failure is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserPassword = 'invalid password';

          final User testUser = User(
            username: testUsername,
            passwordHash:
                '2fcdba02fad94d96774b935791103d4e31b17c71bf0afb02c433f009b0bd22ec28e3a39f375b6d5e29f135262209b397350adb38f86dec525829a290c80d7fd3',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: true,
          );

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserService userService = UserService(mockUserRepository, null, null);

          /// When
          final Either<Failure, void> result = await userService.checkCredentials(
            username: testUsername,
            password: testUserPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          result.fold(
            (Failure exception) => expect(exception, isA<UserSigningFailure>()),
            (void _) => _,
          );
        },
      );
    },
  );

  group(
    'Change Password',
    () {
      test(
        "Given valid user's data with chosen SHA512 algorithm When change password is called Then success is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserOldPassword = 'test';
          const String testUserNewPassword = 'new test';
          const bool testIsEncryptingAlgorithmSha = true;

          final User testUser = User(
            id: 1,
            username: testUsername,
            passwordHash:
                '2fcdba02fad94d96774b935791103d4e31b17c71bf0afb02c433f009b0bd22ec28e3a39f375b6d5e29f135262209b397350adb38f86dec525829a290c80d7fd3',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: testIsEncryptingAlgorithmSha,
          );

          const String testNewPasswordHash =
              'd60d96881a7c817661a987063168230274cd978d78b0cf5e00ee467d91e9edffefb2dabecac329c48c5292b050ac5b4a97a64602c69155856f7e67e6b1f63446';
          const String testNewSalt = 'oWZN14/wsaHsG0jXz+VQMQ==';

          final List<Password> testPasswords = <Password>[
            Password(
              userId: 1,
              password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
              vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
              webAddress: 'google.com',
              description: 'My google password.',
              login: 'Google Login',
            ),
            Password(
              userId: 1,
              password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
              vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
              webAddress: 'amazon.com',
              description: 'My amazon password.',
              login: 'Amazon Login',
            )
          ];

          const String testNewPassword = 'QglKi6tqF9odnZS9/2p7MPdFnjb6w0oZ0J47N/lJFcQ=';
          const String testNewVector = 'oWZN14/wsaHsG0jXz+VQMQ==';

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(
            mockUserRepository.getUserByUsername(any),
          ).thenAnswer(
            (Invocation realInvocation) => Future<User>.value(User.copy(testUser)),
          );

          when(mockUserRepository.updateUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          when(
            mockPasswordRepository.getPasswordsByUserId(any),
          ).thenAnswer(
            (Invocation realInvocation) => Future<List<Password>>.value(
              testPasswords.map((Password testPassword) => Password.copy(testPassword)).toList(),
            ),
          );

          when(mockPasswordRepository.updatePasswords(any))
              .thenAnswer((Invocation realInvocation) => Future<List<dynamic>>.value(<int>[1, 1]));

          final UserService userService =
              UserService(mockUserRepository, mockPasswordRepository, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await userService.changePassword(
            username: testUsername,
            oldUserPassword: testUserOldPassword,
            newUserPassword: testUserNewPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedUser = verify(mockUserRepository.updateUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser, isA<User>());
          expect(capturedUser.id, testUser.id);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testNewPasswordHash);
          expect(capturedUser.salt, testNewSalt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

          expect(verify(mockPasswordRepository.getPasswordsByUserId(captureAny)).captured.single, testUser.id);

          final dynamic capturedPasswordsObject =
              verify(mockPasswordRepository.updatePasswords(captureAny)).captured.single;

          expect(capturedPasswordsObject, isNotNull);
          expect(capturedPasswordsObject, isA<List<Password>>());

          final List<Password> capturedPasswords = capturedPasswordsObject as List<Password>;

          expect(capturedPasswords.length, testPasswords.length);

          for (int i = 0; i < capturedPasswords.length; i++) {
            expect(capturedPasswords[i], isNotNull);
            expect(capturedPasswords[i], isA<Password>());

            expect(capturedPasswords[i].userId, testPasswords[i].userId);
            expect(capturedPasswords[i].password, testNewPassword);
            expect(capturedPasswords[i].vector, testNewVector);
            expect(capturedPasswords[i].webAddress, testPasswords[i].webAddress);
            expect(capturedPasswords[i].description, testPasswords[i].description);
            expect(capturedPasswords[i].login, testPasswords[i].login);
          }

          result.fold(
            (Failure exception) => expect(exception, isNull),
            (void _) => _,
          );
        },
      );

      test(
        "Given valid user's data with chosen HMAC-SHA512 algorithm When change password is called Then success is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserOldPassword = 'test';
          const String testUserNewPassword = 'new test';
          const bool testIsEncryptingAlgorithmSha = false;

          final User testUser = User(
            id: 1,
            username: testUsername,
            passwordHash:
                '6a148235e17c392cad995e30cc9bb08e808ba0be2a33cb419852686156d615cce6390edcc84db71a337787efd620f3d36b1bf502b4ce98d8f0f6c279a004065c',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: testIsEncryptingAlgorithmSha,
          );

          const String testNewPasswordHash =
              '9a1e21ce0061e05ff72ee57217f061fde78a88a7913a7cf31f4b94000c8fc403c1babc59a50a5bb6799ccb13606bbaf11b045e4f6924c55a22385c2407269e97';
          const String testNewSalt = 'oWZN14/wsaHsG0jXz+VQMQ==';

          final List<Password> testPasswords = <Password>[
            Password(
              userId: 1,
              password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
              vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
              webAddress: 'google.com',
              description: 'My google password.',
              login: 'Google Login',
            ),
            Password(
              userId: 1,
              password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
              vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
              webAddress: 'amazon.com',
              description: 'My amazon password.',
              login: 'Amazon Login',
            )
          ];

          const String testNewPassword = 'QglKi6tqF9odnZS9/2p7MPdFnjb6w0oZ0J47N/lJFcQ=';
          const String testNewVector = 'oWZN14/wsaHsG0jXz+VQMQ==';

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(
            mockUserRepository.getUserByUsername(any),
          ).thenAnswer(
            (Invocation realInvocation) => Future<User>.value(User.copy(testUser)),
          );

          when(mockUserRepository.updateUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          when(
            mockPasswordRepository.getPasswordsByUserId(any),
          ).thenAnswer(
            (Invocation realInvocation) => Future<List<Password>>.value(
              testPasswords.map((Password testPassword) => Password.copy(testPassword)).toList(),
            ),
          );

          when(mockPasswordRepository.updatePasswords(any))
              .thenAnswer((Invocation realInvocation) => Future<List<dynamic>>.value(<int>[1, 1]));

          final UserService userService =
              UserService(mockUserRepository, mockPasswordRepository, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await userService.changePassword(
            username: testUsername,
            oldUserPassword: testUserOldPassword,
            newUserPassword: testUserNewPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedUser = verify(mockUserRepository.updateUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser, isA<User>());
          expect(capturedUser.id, testUser.id);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testNewPasswordHash);
          expect(capturedUser.salt, testNewSalt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

          expect(verify(mockPasswordRepository.getPasswordsByUserId(captureAny)).captured.single, testUser.id);

          final dynamic capturedPasswordsObject =
              verify(mockPasswordRepository.updatePasswords(captureAny)).captured.single;

          expect(capturedPasswordsObject, isNotNull);
          expect(capturedPasswordsObject, isA<List<Password>>());

          final List<Password> capturedPasswords = capturedPasswordsObject as List<Password>;

          expect(capturedPasswords.length, testPasswords.length);

          for (int i = 0; i < capturedPasswords.length; i++) {
            expect(capturedPasswords[i], isNotNull);
            expect(capturedPasswords[i], isA<Password>());

            expect(capturedPasswords[i].userId, testPasswords[i].userId);
            expect(capturedPasswords[i].password, testNewPassword);
            expect(capturedPasswords[i].vector, testNewVector);
            expect(capturedPasswords[i].webAddress, testPasswords[i].webAddress);
            expect(capturedPasswords[i].description, testPasswords[i].description);
            expect(capturedPasswords[i].login, testPasswords[i].login);
          }

          result.fold(
            (Failure exception) => expect(exception, isNull),
            (void _) => _,
          );
        },
      );

      test(
        "Given non-existent user's data When change password is called Then failure about non-existent user is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserOldPassword = 'test';
          const String testUserNewPassword = 'new test';

          when(mockUserRepository.getUserByUsername(any)).thenAnswer((Invocation realInvocation) => null);

          final UserService userService = UserService(mockUserRepository, null, null);

          /// When
          final Either<Failure, void> result = await userService.changePassword(
            username: testUsername,
            oldUserPassword: testUserOldPassword,
            newUserPassword: testUserNewPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          result.fold(
            (Failure exception) => expect(exception, isA<NonExistentUserFailure>()),
            (void _) => _,
          );
        },
      );

      test(
        "Given valid user's data When change user's password failed Then failure is returned",
        () async {
          /// Given
          const String testUsername = 'test';
          const String testUserOldPassword = 'test';
          const String testUserNewPassword = 'new test';
          const bool testIsEncryptingAlgorithmSha = true;

          final User testUser = User(
            id: 1,
            username: testUsername,
            passwordHash:
                '2fcdba02fad94d96774b935791103d4e31b17c71bf0afb02c433f009b0bd22ec28e3a39f375b6d5e29f135262209b397350adb38f86dec525829a290c80d7fd3',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: testIsEncryptingAlgorithmSha,
          );

          const String testNewPasswordHash =
              'd60d96881a7c817661a987063168230274cd978d78b0cf5e00ee467d91e9edffefb2dabecac329c48c5292b050ac5b4a97a64602c69155856f7e67e6b1f63446';
          const String testNewSalt = 'oWZN14/wsaHsG0jXz+VQMQ==';

          final Uint8List testVectorBytes =
              Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(
            mockUserRepository.getUserByUsername(any),
          ).thenAnswer(
            (Invocation realInvocation) => Future<User>.value(User.copy(testUser)),
          );

          when(mockUserRepository.updateUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(-1));

          final UserService userService =
              UserService(mockUserRepository, mockPasswordRepository, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await userService.changePassword(
            username: testUsername,
            oldUserPassword: testUserOldPassword,
            newUserPassword: testUserNewPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedUser = verify(mockUserRepository.updateUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser, isA<User>());
          expect(capturedUser.id, testUser.id);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testNewPasswordHash);
          expect(capturedUser.salt, testNewSalt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

          result.fold(
            (Failure exception) => expect(exception, isA<UserUpdateFailure>()),
            (void _) => _,
          );
        },
      );

      test(
        "Given valid user's data When change passwords failed Then failure is returned",
            () async {
          /// Given
          const String testUsername = 'test';
          const String testUserOldPassword = 'test';
          const String testUserNewPassword = 'new test';
          const bool testIsEncryptingAlgorithmSha = true;

          final User testUser = User(
            id: 1,
            username: testUsername,
            passwordHash:
            '2fcdba02fad94d96774b935791103d4e31b17c71bf0afb02c433f009b0bd22ec28e3a39f375b6d5e29f135262209b397350adb38f86dec525829a290c80d7fd3',
            salt: 'oWZN14/wsaHsG0jXz+VQMQ==',
            isPasswordKeptAsHash: testIsEncryptingAlgorithmSha,
          );

          const String testNewPasswordHash =
              'd60d96881a7c817661a987063168230274cd978d78b0cf5e00ee467d91e9edffefb2dabecac329c48c5292b050ac5b4a97a64602c69155856f7e67e6b1f63446';
          const String testNewSalt = 'oWZN14/wsaHsG0jXz+VQMQ==';

          final List<Password> testPasswords = <Password>[
            Password(
              userId: 1,
              password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
              vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
              webAddress: 'google.com',
              description: 'My google password.',
              login: 'Google Login',
            ),
            Password(
              userId: 1,
              password: 'wwlMIySwwWlEwGcEWDseqwQzh0gmc4gSvp4F7eoh8zk=',
              vector: 'oWZN14/wsaHsG0jXz+VQMQ==',
              webAddress: 'amazon.com',
              description: 'My amazon password.',
              login: 'Amazon Login',
            )
          ];

          const String testNewPassword = 'QglKi6tqF9odnZS9/2p7MPdFnjb6w0oZ0J47N/lJFcQ=';
          const String testNewVector = 'oWZN14/wsaHsG0jXz+VQMQ==';

          final Uint8List testVectorBytes =
          Uint8List.fromList(<int>[161, 102, 77, 215, 143, 240, 177, 161, 236, 27, 72, 215, 207, 229, 80, 49]);

          when(mockRandomValuesGenerator.generateRandomBytes(any))
              .thenAnswer((Invocation realInvocation) => testVectorBytes);

          when(
            mockUserRepository.getUserByUsername(any),
          ).thenAnswer(
                (Invocation realInvocation) => Future<User>.value(User.copy(testUser)),
          );

          when(mockUserRepository.updateUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          when(
            mockPasswordRepository.getPasswordsByUserId(any),
          ).thenAnswer(
                (Invocation realInvocation) => Future<List<Password>>.value(
              testPasswords.map((Password testPassword) => Password.copy(testPassword)).toList(),
            ),
          );

          when(mockPasswordRepository.updatePasswords(any))
              .thenAnswer((Invocation realInvocation) => Future<List<dynamic>>.value(<int>[1, -1]));

          final UserService userService =
          UserService(mockUserRepository, mockPasswordRepository, mockRandomValuesGenerator);

          /// When
          final Either<Failure, void> result = await userService.changePassword(
            username: testUsername,
            oldUserPassword: testUserOldPassword,
            newUserPassword: testUserNewPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured.single, testUsername);

          final dynamic capturedUser = verify(mockUserRepository.updateUser(captureAny)).captured.single;

          expect(capturedUser, isNotNull);
          expect(capturedUser, isA<User>());
          expect(capturedUser.id, testUser.id);
          expect(capturedUser.username, testUser.username);
          expect(capturedUser.passwordHash, testNewPasswordHash);
          expect(capturedUser.salt, testNewSalt);
          expect(capturedUser.isPasswordKeptAsHash, testUser.isPasswordKeptAsHash);

          expect(verify(mockPasswordRepository.getPasswordsByUserId(captureAny)).captured.single, testUser.id);

          final dynamic capturedPasswordsObject =
              verify(mockPasswordRepository.updatePasswords(captureAny)).captured.single;

          expect(capturedPasswordsObject, isNotNull);
          expect(capturedPasswordsObject, isA<List<Password>>());

          final List<Password> capturedPasswords = capturedPasswordsObject as List<Password>;

          expect(capturedPasswords.length, testPasswords.length);

          for (int i = 0; i < capturedPasswords.length; i++) {
            expect(capturedPasswords[i], isNotNull);
            expect(capturedPasswords[i], isA<Password>());

            expect(capturedPasswords[i].userId, testPasswords[i].userId);
            expect(capturedPasswords[i].password, testNewPassword);
            expect(capturedPasswords[i].vector, testNewVector);
            expect(capturedPasswords[i].webAddress, testPasswords[i].webAddress);
            expect(capturedPasswords[i].description, testPasswords[i].description);
            expect(capturedPasswords[i].login, testPasswords[i].login);
          }

          result.fold(
                (Failure exception) => expect(exception, isA<UserUpdateFailure>()),
                (void _) => _,
          );
        },
      );
    },
  );
}
