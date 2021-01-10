import 'dart:typed_data';

import 'package:clock/clock.dart';
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

class MockLogRepository extends Mock implements LogRepository {}

class MockIpAddressRepository extends Mock implements IpAddressRepository {}

class MockRandomValuesGenerator extends Mock implements RandomValuesGenerator {}

class MockPasswordService extends Mock implements PasswordService {}

class MockClock extends Mock implements Clock {}

void main() {
  final MockUserRepository mockUserRepository = MockUserRepository();
  final MockPasswordRepository mockPasswordRepository = MockPasswordRepository();
  final MockLogRepository mockLogRepository = MockLogRepository();
  final MockIpAddressRepository mockIpAddressRepository = MockIpAddressRepository();
  final MockRandomValuesGenerator mockRandomValuesGenerator = MockRandomValuesGenerator();
  final MockPasswordService mockPasswordService = MockPasswordService();
  final MockClock mockClock = MockClock();

  setUp(() {});
  tearDown(() {
    reset(mockUserRepository);
    reset(mockPasswordRepository);
    reset(mockLogRepository);
    reset(mockIpAddressRepository);
    reset(mockRandomValuesGenerator);
    reset(mockClock);
    reset(mockPasswordService);
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

          when(mockIpAddressRepository.getPublicIpAddress())
              .thenAnswer((Invocation realInvocation) => Future<String>.value('1.1.1.1'));

          final List<User> users = <User>[null, User(id: 1)];
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(users.removeAt(0)));

          when(mockUserRepository.createUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          when(mockLogRepository.createLog(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

          /// When
          final Either<Failure, void> result = await userService.registerUser(
            username: testUsername,
            password: testUserPassword,
            isEncryptingAlgorithmSha: testIsEncryptingAlgorithmSha,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured[0], testUsername);

          final dynamic capturedUser = verify(mockUserRepository.createUser(captureAny)).captured[0];

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

          when(mockIpAddressRepository.getPublicIpAddress())
              .thenAnswer((Invocation realInvocation) => Future<String>.value('1.1.1.1'));

          final List<User> users = <User>[null, User(id: 1)];
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(users.removeAt(0)));

          when(mockLogRepository.createLog(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          when(mockUserRepository.createUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

          /// When
          final Either<Failure, void> result = await userService.registerUser(
            username: testUsername,
            password: testUserPassword,
            isEncryptingAlgorithmSha: testIsEncryptingAlgorithmSha,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured[0], testUsername);

          final dynamic capturedUser = verify(mockUserRepository.createUser(captureAny)).captured[0];

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

          when(mockIpAddressRepository.getPublicIpAddress())
              .thenAnswer((Invocation realInvocation) => Future<String>.value('1.1.1.1'));

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

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

          when(mockIpAddressRepository.getPublicIpAddress())
              .thenAnswer((Invocation realInvocation) => Future<String>.value('1.1.1.1'));

          when(mockUserRepository.getUserByUsername(any)).thenAnswer((Invocation realInvocation) => null);

          when(mockUserRepository.createUser(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(-1));

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

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

          when(mockIpAddressRepository.getPublicIpAddress())
              .thenAnswer((Invocation realInvocation) => Future<String>.value('1.1.1.1'));

          when(mockLogRepository.createLog(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          when(mockLogRepository.getLogsByUserId(any))
              .thenAnswer((Invocation realInvocation) => Future<List<Log>>.value(<Log>[]));

          when(mockLogRepository.getLogsByUserIdAndIpAddress(any, any))
              .thenAnswer((Invocation realInvocation) => Future<List<Log>>.value(<Log>[]));

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

          /// When
          final Either<Failure, void> result = await userService.checkCredentials(
            username: testUsername,
            password: testUserPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured[0], testUsername);

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

          when(mockIpAddressRepository.getPublicIpAddress())
              .thenAnswer((Invocation realInvocation) => Future<String>.value('1.1.1.1'));

          when(mockLogRepository.createLog(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          when(mockLogRepository.getLogsByUserId(any))
              .thenAnswer((Invocation realInvocation) => Future<List<Log>>.value(<Log>[]));

          when(mockLogRepository.getLogsByUserIdAndIpAddress(any, any))
              .thenAnswer((Invocation realInvocation) => Future<List<Log>>.value(<Log>[]));

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

          /// When
          final Either<Failure, void> result = await userService.checkCredentials(
            username: testUsername,
            password: testUserPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured[0], testUsername);

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

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

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

          when(mockIpAddressRepository.getPublicIpAddress())
              .thenAnswer((Invocation realInvocation) => Future<String>.value('1.1.1.1'));

          when(mockLogRepository.getLogsByUserId(any))
              .thenAnswer((Invocation realInvocation) => Future<List<Log>>.value(<Log>[]));

          when(mockLogRepository.getLogsByUserIdAndIpAddress(any, any))
              .thenAnswer((Invocation realInvocation) => Future<List<Log>>.value(<Log>[]));

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User.copy(testUser)));

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

          /// When
          final Either<Failure, void> result = await userService.checkCredentials(
            username: testUsername,
            password: testUserPassword,
          );

          /// Then
          expect(verify(mockUserRepository.getUserByUsername(captureAny)).captured[0], testUsername);

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

          final UserService userService = UserService(mockUserRepository, mockPasswordRepository, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

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

          final UserService userService = UserService(mockUserRepository, mockPasswordRepository, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

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

          final UserService userService = UserService(mockUserRepository, null, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

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

          final UserService userService = UserService(mockUserRepository, mockPasswordRepository, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

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

          final UserService userService = UserService(mockUserRepository, mockPasswordRepository, mockLogRepository,
              mockIpAddressRepository, mockRandomValuesGenerator, mockPasswordService);

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

  group(
    'Add Log',
    () {
      test(
        "Given valid log's data When add log is called Then success is returned",
        () async {
          /// Given
          when(mockLogRepository.createLog(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final UserService userService = UserService(null, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final bool result = await userService.addLog(userId: 1, isSuccessful: true, ipAddress: '1.1.1.1');

          /// Then
          expect(result, true);
        },
      );
    },
  );

  group(
    'Get User Logs',
    () {
      test(
        "Given valid username When get user logs is called Then user's logs are returned",
        () async {
          /// Given
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User(id: 1)));
          when(mockLogRepository.getLogsByUserId(any))
              .thenAnswer((Invocation realInvocation) => Future<List<Log>>.value(<Log>[Log(id: 1)]));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final List<Log> result = await userService.getUserLogs(username: 'Test User');

          /// Then
          expect(result.isNotEmpty, true);
          expect(result.length, 1);
          expect(result[0].id, 1);
        },
      );

      test(
        "Given invalid username When get user logs is called Then user's logs are NOT returned",
        () async {
          /// Given
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(null));
          when(mockLogRepository.getLogsByUserId(any))
              .thenAnswer((Invocation realInvocation) => Future<List<Log>>.value(<Log>[]));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final List<Log> result = await userService.getUserLogs(username: 'Invalid Test User');

          /// Then
          expect(result.isEmpty, true);
        },
      );
    },
  );

  group(
    'Get Blocked IP Addresses',
    () {
      test(
        "Given valid username When get blocked IP addresses is called Then user's blocked IP addresses are returned",
        () async {
          /// Given
          final Log testInvalidLog = Log(id: 1, ipAddress: '1.1.1.1', isSuccessful: false, isUnblocked: false);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User(id: 1)));
          when(mockLogRepository.getLogsByUserId(any)).thenAnswer((Invocation realInvocation) =>
              Future<List<Log>>.value(<Log>[testInvalidLog, testInvalidLog, testInvalidLog, testInvalidLog]));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final List<String> result = await userService.getBlockedIpAddresses(username: 'Test User');

          /// Then
          expect(result.isNotEmpty, true);
          expect(result.length, 1);
          expect(result[0], '1.1.1.1');
        },
      );

      test(
        "Given invalid username When get blocked IP addresses is called Then user's blocked IP addresses are NOT returned",
        () async {
          /// Given
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(null));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final List<String> result = await userService.getBlockedIpAddresses(username: 'Invalid Test User');

          /// Then
          expect(result.isEmpty, true);
        },
      );
    },
  );

  group(
    'Check User Block',
    () {
      test(
        'Given valid username and successful login When check user block is called Then NOT blocked flag is returned',
        () async {
          /// Given
          final Log testSuccessfulLog = Log(id: 1, ipAddress: '1.1.1.1', isSuccessful: true, isUnblocked: false);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User(id: 1)));

          when(mockLogRepository.getLogsByUserId(any)).thenAnswer((Invocation realInvocation) =>
              Future<List<Log>>.value(
                  <Log>[testSuccessfulLog, testSuccessfulLog, testSuccessfulLog, testSuccessfulLog]));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final bool result = await userService.checkUserBlock(username: 'Test User');

          /// Then
          expect(result, false);
        },
      );

      test(
        'Given valid username and failed login When check user block is called Then blocked flag is returned',
        () async {
          /// Given
          final DateTime testTime = DateTime(2000, 1, 1, 12, 0, 0, 0, 0);
          final Log testFailedLogin = Log(
              id: 1,
              ipAddress: '1.1.1.1',
              isSuccessful: false,
              isUnblocked: false,
              loginTime: testTime.millisecondsSinceEpoch + 1);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User(id: 1)));

          when(mockLogRepository.getLogsByUserId(any)).thenAnswer((Invocation realInvocation) =>
              Future<List<Log>>.value(<Log>[testFailedLogin, testFailedLogin, testFailedLogin, testFailedLogin]));

          when(mockClock.now()).thenAnswer((Invocation realInvocation) => testTime);

          final UserService userService = UserService(
              mockUserRepository, null, mockLogRepository, null, null, mockPasswordService,
              clock: mockClock);

          /// When
          final bool result = await userService.checkUserBlock(username: 'Test User');

          /// Then
          expect(result, true);
        },
      );

      test(
        'Given invalid username When check user block is called Then blocked flag is returned',
        () async {
          /// Given
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(null));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final bool result = await userService.checkUserBlock(username: 'Invalid Test User');

          /// Then
          expect(result, true);
        },
      );
    },
  );

  group(
    'Check IP Block',
    () {
      test(
        'Given valid data and successful login When check IP block is called Then NOT blocked flag is returned',
        () async {
          /// Given
          final Log testSuccessfulLog = Log(id: 1, ipAddress: '1.1.1.1', isSuccessful: true, isUnblocked: false);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User(id: 1)));

          when(mockLogRepository.getLogsByUserIdAndIpAddress(any, any)).thenAnswer((Invocation realInvocation) =>
              Future<List<Log>>.value(
                  <Log>[testSuccessfulLog, testSuccessfulLog, testSuccessfulLog, testSuccessfulLog]));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final bool result = await userService.checkIpBlock(username: 'Test User', ipAddress: '1.1.1.1');

          /// Then
          expect(result, false);
        },
      );

      test(
        'Given valid data and failed login When check IP block is called Then blocked flag is returned',
        () async {
          /// Given
          final DateTime testTime = DateTime(2000, 1, 1, 12, 0, 0, 0, 0);
          final Log testFailedLogin = Log(
              id: 1,
              ipAddress: '1.1.1.1',
              isSuccessful: false,
              isUnblocked: false,
              loginTime: testTime.millisecondsSinceEpoch - 1000);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User(id: 1)));

          when(mockLogRepository.getLogsByUserIdAndIpAddress(any, any)).thenAnswer(
              (Invocation realInvocation) => Future<List<Log>>.value(<Log>[testFailedLogin, testFailedLogin]));

          when(mockClock.now()).thenAnswer((Invocation realInvocation) => testTime);

          final UserService userService = UserService(
              mockUserRepository, null, mockLogRepository, null, null, mockPasswordService,
              clock: mockClock);

          /// When
          final bool result = await userService.checkIpBlock(username: 'Test User', ipAddress: '1.1.1.1');

          /// Then
          expect(result, true);
        },
      );

      test(
        'Given valid data and 4 failed login logs When check IP block is called Then blocked flag is returned',
        () async {
          /// Given
          final DateTime testTime = DateTime(2000, 1, 1, 12, 0, 0, 0, 0);
          final Log testFailedLogin = Log(
              id: 1,
              ipAddress: '1.1.1.1',
              isSuccessful: false,
              isUnblocked: false,
              loginTime: testTime.millisecondsSinceEpoch - 100000000);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User(id: 1)));

          when(mockLogRepository.getLogsByUserIdAndIpAddress(any, any)).thenAnswer((Invocation realInvocation) =>
              Future<List<Log>>.value(<Log>[testFailedLogin, testFailedLogin, testFailedLogin, testFailedLogin]));

          when(mockClock.now()).thenAnswer((Invocation realInvocation) => testTime);

          final UserService userService = UserService(
              mockUserRepository, null, mockLogRepository, null, null, mockPasswordService,
              clock: mockClock);

          /// When
          final bool result = await userService.checkIpBlock(username: 'Test User', ipAddress: '1.1.1.1');

          /// Then
          expect(result, true);
        },
      );

      test(
        'Given invalid username When check IP block is called Then blocked flag is returned',
        () async {
          /// Given
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(null));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final bool result = await userService.checkIpBlock(username: 'Invalid Test User', ipAddress: '1.1.1.1');

          /// Then
          expect(result, true);
        },
      );
    },
  );

  group(
    'Unblock IP',
    () {
      test(
        'Given valid data When unblock IP is called Then success is returned',
        () async {
          /// Given
          final Log testSuccessfulLog = Log(id: 1, ipAddress: '1.1.1.1', isSuccessful: true, isUnblocked: false);

          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(User(id: 1)));

          when(mockLogRepository.updateLog(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          when(mockLogRepository.getLogsByUserIdAndIpAddress(any, any)).thenAnswer((Invocation realInvocation) =>
              Future<List<Log>>.value(
                  <Log>[testSuccessfulLog, testSuccessfulLog, testSuccessfulLog, testSuccessfulLog]));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final bool result = await userService.unblockIp(username: 'Test User', blockedIpAddress: '1.1.1.1');

          /// Then
          expect(result, true);
        },
      );

      test(
        'Given invalid username When unblock IP is called Then failure flag is returned',
        () async {
          /// Given
          when(mockUserRepository.getUserByUsername(any))
              .thenAnswer((Invocation realInvocation) => Future<User>.value(null));

          when(mockLogRepository.updateLog(any)).thenAnswer((Invocation realInvocation) => Future<int>.value(1));

          final UserService userService =
              UserService(mockUserRepository, null, mockLogRepository, null, null, mockPasswordService);

          /// When
          final bool result = await userService.unblockIp(username: 'Invalid Test User', blockedIpAddress: '1.1.1.1');

          /// Then
          expect(result, false);
        },
      );
    },
  );
}
