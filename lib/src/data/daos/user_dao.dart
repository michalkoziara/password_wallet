import 'package:sqflite_common/sqlite_api.dart';

import '../../utils/constants.dart';
import '../data_sources/database_provider.dart';
import '../models/models.dart' show User;

/// A data access object representing user data access.
class UserDao {
  /// The database provider.
  final DatabaseProvider _databaseProvider = DatabaseProvider.databaseProvider;

  /// Returns user based on username.
  Future<User> getUserByUsername(
      {List<String> columns, String username}) async {
    final Database database = await _databaseProvider.database;

    List<Map<String, dynamic>> result;
    if (username != null && username != '') {
      if (username.isNotEmpty) {
        result = await database.query(Constants.userTable,
            columns: columns,
            where: 'username = ?',
            whereArgs: <String>[username]);
      }
    } else {
      result = await database.query(Constants.userTable, columns: columns);
    }

    final List<User> users = result.isNotEmpty
        ? result.map((Map<String, dynamic> user) => User.fromMap(user)).toList()
        : <User>[];
    final User user = users.isNotEmpty ? users[0] : null;

    return user;
  }

  /// Creates user.
  Future<int> createUser(User user) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.insert(Constants.userTable, user.toMap());

    return result;
  }

  /// Updates user.
  Future<int> updateUser(User user) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.update(Constants.userTable, user.toMap(),
        where: 'id = ?', whereArgs: <int>[user.id]);

    return result;
  }
}
