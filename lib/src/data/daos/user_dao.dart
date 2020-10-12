import 'package:sqflite_common/sqlite_api.dart';

import '../data_sources/database_provider.dart';
import '../models/models.dart' show User;

/// A data access object representing user data access.
class UserDao {
  /// The database provider.
  final DatabaseProvider _databaseProvider = DatabaseProvider.databaseProvider;

  /// Returns users based on query.
  Future<List<User>> getUsers({List<String> columns, String query}) async {
    final Database database = await _databaseProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null && query != '') {
      if (query.isNotEmpty) {
        result =
            await database.query(userTable, columns: columns, where: 'name LIKE ?', whereArgs: <String>['%$query%']);
      }
    } else {
      result = await database.query(userTable, columns: columns);
    }

    final List<User> users =
        result.isNotEmpty ? result.map((Map<String, dynamic> user) => User.fromMap(user)).toList() : <User>[];
    return users;
  }

  /// Returns user based on id.
  Future<User> getUser({List<String> columns, int id}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result =
        await database.query(userTable, columns: columns, where: 'id = ?', whereArgs: <int>[id]);

    final List<User> users =
        result.isNotEmpty ? result.map((Map<String, dynamic> user) => User.fromMap(user)).toList() : <User>[];
    final User user = users.isNotEmpty ? users[0] : null;

    return user;
  }

  /// Creates user.
  Future<int> createUser(User user) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.insert(userTable, user.toMap());

    return result;
  }

  /// Updates user.
  Future<int> updateUser(User user) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.update(userTable, user.toMap(), where: 'id = ?', whereArgs: <int>[user.id]);

    return result;
  }

  /// Deletes user.
  Future<int> deleteUser(int id) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.delete(userTable, where: 'id = ?', whereArgs: <int>[id]);

    return result;
  }
}
