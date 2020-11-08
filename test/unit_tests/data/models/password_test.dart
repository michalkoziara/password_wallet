import 'package:flutter_test/flutter_test.dart';
import 'package:password_wallet/src/data/models/models.dart';

void main() {
  setUp(() {});
  tearDown(() {});

  group(
    'Password',
    () {
      test(
        'Given valid map When password from map is called Then password is created',
        () async {
          /// Given
          const Map<String, dynamic> testPasswordMap = <String, dynamic>{
            'id': 1,
            'userId': 1,
            'password': 'Test Password',
            'vector': 'Test Vector',
            'webAddress': 'Test Web Address',
            'description': 'Test Description',
            'login': 'Test Login',
          };

          /// When
          final Password resultPassword = Password.fromMap(testPasswordMap);

          /// Then
          expect(resultPassword, isNotNull);
          expect(resultPassword, isA<Password>());
          expect(resultPassword.id, testPasswordMap['id']);
          expect(resultPassword.userId, testPasswordMap['userId']);
          expect(resultPassword.password, testPasswordMap['password']);
          expect(resultPassword.vector, testPasswordMap['vector']);
          expect(resultPassword.webAddress, testPasswordMap['webAddress']);
          expect(resultPassword.description, testPasswordMap['description']);
          expect(resultPassword.login, testPasswordMap['login']);
        },
      );

      test(
        'Given valid password When password to map is called Then map based on password data is created',
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

          /// When
          final Map<String, dynamic> resultPasswordMap = testPassword.toMap();

          /// Then
          expect(resultPasswordMap, isNotNull);
          expect(resultPasswordMap, isA<Map<String, dynamic>>());
          expect(resultPasswordMap['id'], testPassword.id);
          expect(resultPasswordMap['userId'], testPassword.userId);
          expect(resultPasswordMap['password'], testPassword.password);
          expect(resultPasswordMap['vector'], testPassword.vector);
          expect(resultPasswordMap['webAddress'], testPassword.webAddress);
          expect(resultPasswordMap['description'], testPassword.description);
          expect(resultPasswordMap['login'], testPassword.login);
        },
      );
    },
  );
}
