import 'package:sqflite_common/sqlite_api.dart';

import '../../utils/constants.dart';
import '../data_sources/database_provider.dart';
import '../models/models.dart' show Password;

/// A data access object representing password data access.
class PasswordDao {
  /// Creates data access object representing password data access.
  PasswordDao({DatabaseProvider databaseProvider})
      : _databaseProvider = databaseProvider ?? DatabaseProvider.databaseProvider;

  /// The database provider.
  final DatabaseProvider _databaseProvider;

  /// Returns passwords based on user's ID.
  Future<List<Password>> getPasswordsByUserId({List<String> columns, int userId}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result = await database.query(
      Constants.passwordTable,
      columns: columns,
      where: 'userId = ?',
      whereArgs: <int>[userId],
    );

    final List<Password> passwords = result.isNotEmpty
        ? result.map((Map<String, dynamic> password) => Password.fromMap(password)).toList()
        : <Password>[];

    return passwords;
  }

  /// Returns passwords based on update status and user's ID.
  Future<List<Password>> getPasswordsByUserIdAndUpdateStatus({List<String> columns, int userId}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result = await database.query(
      Constants.passwordTable,
      columns: columns,
      where: 'userId = ? AND isSharedUpdated = ?',
      whereArgs: <dynamic>[userId, true],
    );

    final List<Password> passwords = result.isNotEmpty
        ? result.map((Map<String, dynamic> password) => Password.fromMap(password)).toList()
        : <Password>[];

    return passwords;
  }

  /// Returns passwords based on owner password's ID.
  Future<List<Password>> getPasswordsByOwnerPasswordId({List<String> columns, int ownerPasswordId}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result = await database.query(
      Constants.passwordTable,
      columns: columns,
      where: 'ownerPasswordId = ?',
      whereArgs: <int>[ownerPasswordId],
    );

    final List<Password> passwords = result.isNotEmpty
        ? result.map((Map<String, dynamic> password) => Password.fromMap(password)).toList()
        : <Password>[];

    return passwords;
  }

  /// Returns password based on ID.
  Future<Password> getPasswordById({List<String> columns, int id}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result = await database.query(
      Constants.passwordTable,
      columns: columns,
      where: 'id = ?',
      whereArgs: <int>[id],
    );

    final List<Password> passwords = result.isNotEmpty
        ? result.map((Map<String, dynamic> password) => Password.fromMap(password)).toList()
        : <Password>[];
    final Password password = passwords.isNotEmpty ? passwords[0] : null;

    return password;
  }

  /// Creates password.
  Future<int> createPassword(Password password) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.insert(
      Constants.passwordTable,
      password.toMap(),
    );

    return result;
  }

  /// Updates multiple passwords in a batch.
  Future<List<dynamic>> updatePasswords(List<Password> passwords) async {
    final Database database = await _databaseProvider.database;

    final Batch batch = database.batch();

    for (final Password password in passwords) {
      batch.update(
        Constants.passwordTable,
        password.toMap(),
        where: 'id = ?',
        whereArgs: <int>[password.id],
      );
    }

    final List<dynamic> result = await batch.commit();
    return result;
  }

  /// Updates password based on ID.
  Future<int> updatePassword(Password password) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.update(
      Constants.passwordTable,
      password.toMap(),
      where: 'id = ?',
      whereArgs: <int>[password.id],
    );

    return result;
  }

  /// Deletes password based on ID.
  Future<int> deletePasswordById({List<String> columns, int id}) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.delete(
      Constants.passwordTable,
      where: 'id = ?',
      whereArgs: <int>[id],
    );

    return result;
  }
}
