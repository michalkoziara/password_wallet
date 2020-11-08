import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:password_wallet/src/data/daos/daos.dart';
import 'package:password_wallet/src/data/models/models.dart';
import 'package:password_wallet/src/repositories/repositories.dart';

class MockPasswordDao extends Mock implements PasswordDao {}

void main() {
  final MockPasswordDao mockPasswordDao = MockPasswordDao();

  setUp(() {});
  tearDown(() {
    reset(mockPasswordDao);
  });

  group(
    'Password Repository',
    () {
      test(
        'Given valid user ID When get passwords is called Then passwords are returned',
        () async {
          /// Given
          const int testUserId = 1;

          final List<Password> testPasswords = <Password>[
            Password(
              userId: 1231,
              password: 'First password',
              vector: 'Vector',
              webAddress: 'WebAddress',
              description: 'Description',
              login: 'Login',
            ),
            Password(
              userId: 1231,
              password: 'Second password',
              vector: 'Vector',
              webAddress: 'WebAddress',
              description: 'Description',
              login: 'Login',
            )
          ];

          when(mockPasswordDao.getPasswordsByUserId(userId: anyNamed('userId'))).thenAnswer(
            (Invocation realInvocation) => Future<List<Password>>.value(
              testPasswords.map((Password testPassword) => Password.copy(testPassword)).toList(),
            ),
          );

          final PasswordRepository passwordRepository = PasswordRepository(passwordDao: mockPasswordDao);

          /// When
          final List<Password> resultPasswords = await passwordRepository.getPasswordsByUserId(testUserId);

          /// Then
          expect(
            verify(mockPasswordDao.getPasswordsByUserId(userId: captureAnyNamed('userId'))).captured.single,
            testUserId,
          );

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

      test(
        'Given valid password ID When get password is called Then password is returned',
        () async {
          /// Given
          final Password testPassword = Password(
            userId: 1231,
            password: 'First password',
            vector: 'Vector',
            webAddress: 'WebAddress',
            description: 'Description',
            login: 'Login',
          );

          when(mockPasswordDao.getPasswordById(id: anyNamed('id'))).thenAnswer(
            (Invocation realInvocation) => Future<Password>.value(Password.copy(testPassword)),
          );

          final PasswordRepository passwordRepository = PasswordRepository(passwordDao: mockPasswordDao);

          /// When
          final Password resultPassword = await passwordRepository.getPasswordById(testPassword.id);

          /// Then
          expect(
            verify(mockPasswordDao.getPasswordById(id: captureAnyNamed('id'))).captured.single,
            testPassword.id,
          );

          expect(resultPassword, isNotNull);
          expect(resultPassword.userId, testPassword.userId);
          expect(resultPassword.password, testPassword.password);
          expect(resultPassword.vector, testPassword.vector);
          expect(resultPassword.webAddress, testPassword.webAddress);
          expect(resultPassword.description, testPassword.description);
          expect(resultPassword.login, testPassword.login);
        },
      );

      test(
        'Given valid password data When create password is called Then success is returned',
        () async {
          /// Given
          final Password testPassword = Password(
            userId: 1231,
            password: 'First password',
            vector: 'Vector',
            webAddress: 'WebAddress',
            description: 'Description',
            login: 'Login',
          );

          when(mockPasswordDao.createPassword(any)).thenAnswer(
            (Invocation realInvocation) => Future<int>.value(1),
          );

          final PasswordRepository passwordRepository = PasswordRepository(passwordDao: mockPasswordDao);

          /// When
          final int result = await passwordRepository.createPassword(testPassword);

          /// Then
          final dynamic capturedPassword = verify(mockPasswordDao.createPassword(captureAny)).captured.single;

          expect(capturedPassword, isNotNull);
          expect(capturedPassword.userId, testPassword.userId);
          expect(capturedPassword.password, testPassword.password);
          expect(capturedPassword.vector, testPassword.vector);
          expect(capturedPassword.webAddress, testPassword.webAddress);
          expect(capturedPassword.description, testPassword.description);
          expect(capturedPassword.login, testPassword.login);

          expect(result, 1);
        },
      );

      test(
        'Given valid passwords data When update passwords is called Then successes are returned',
        () async {
          /// Given
          final List<Password> testPasswords = <Password>[
            Password(
              userId: 1231,
              password: 'First password',
              vector: 'Vector',
              webAddress: 'WebAddress',
              description: 'Description',
              login: 'Login',
            ),
            Password(
              userId: 1231,
              password: 'Second password',
              vector: 'Vector',
              webAddress: 'WebAddress',
              description: 'Description',
              login: 'Login',
            )
          ];

          when(mockPasswordDao.updatePasswords(any)).thenAnswer(
            (Invocation realInvocation) => Future<List<int>>.value(<int>[1, 1]),
          );

          final PasswordRepository passwordRepository = PasswordRepository(passwordDao: mockPasswordDao);

          /// When
          final List<dynamic> results = await passwordRepository.updatePasswords(testPasswords);

          /// Then
          final dynamic capturedPassword = verify(mockPasswordDao.updatePasswords(captureAny)).captured.single;

          expect(capturedPassword, isNotNull);
          expect(capturedPassword, isA<List<Password>>());
          expect(capturedPassword.length, testPasswords.length);

          for (int i = 0; i < (capturedPassword as List<Password>).length; i++) {
            expect(capturedPassword[i].userId, testPasswords[i].userId);
            expect(capturedPassword[i].password, testPasswords[i].password);
            expect(capturedPassword[i].vector, testPasswords[i].vector);
            expect(capturedPassword[i].webAddress, testPasswords[i].webAddress);
            expect(capturedPassword[i].description, testPasswords[i].description);
            expect(capturedPassword[i].login, testPasswords[i].login);
          }

          expect(results, isNotNull);
          expect(results.length, testPasswords.length);

          for (final dynamic result in results) {
            expect(result, 1);
          }
        },
      );
    },
  );
}
