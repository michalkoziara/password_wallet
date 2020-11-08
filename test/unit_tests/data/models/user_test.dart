import 'package:flutter_test/flutter_test.dart';
import 'package:password_wallet/src/data/models/models.dart';

void main() {
  setUp(() {});
  tearDown(() {});

  group(
    'User',
    () {
      test(
        'Given valid map When user from map is called Then user is created',
        () async {
          /// Given
          const Map<String, dynamic> testUserMap = <String, dynamic>{
            'id': 1,
            'username': 'Test Username',
            'passwordHash': 'Test Password Hash',
            'salt': 'Test Salt',
            'isPasswordKeptAsHash': 'true',
          };

          /// When
          final User resultUser = User.fromMap(testUserMap);

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
        'Given valid user When user to map is called Then map based on user data is created',
        () async {
          /// Given
          final User testUser = User(
            id: 1,
            username: 'Test Username',
            passwordHash: 'Test Password Hash',
            salt: 'Test Salt',
            isPasswordKeptAsHash: true,
          );

          /// When
          final Map<String, dynamic> resultUserMap = testUser.toMap();

          /// Then
          expect(resultUserMap, isNotNull);
          expect(resultUserMap, isA<Map<String, dynamic>>());
          expect(resultUserMap['id'], testUser.id);
          expect(resultUserMap['username'], testUser.username);
          expect(resultUserMap['passwordHash'], testUser.passwordHash);
          expect(resultUserMap['salt'], testUser.salt);
          expect(resultUserMap['isPasswordKeptAsHash'], 'true');
        },
      );
    },
  );
}
