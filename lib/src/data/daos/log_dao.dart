import 'package:sqflite_common/sqlite_api.dart';

import '../../utils/constants.dart';
import '../data_sources/database_provider.dart';
import '../models/models.dart' show Log;

/// A data access object representing a log data access.
class LogDao {
  /// Creates data access object representing a log data access.
  LogDao({DatabaseProvider databaseProvider})
      : _databaseProvider = databaseProvider ?? DatabaseProvider.databaseProvider;

  /// The database provider.
  final DatabaseProvider _databaseProvider;

  /// Returns logs based on user's ID.
  Future<List<Log>> getLogsByUserId({List<String> columns, int userId}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result = await database.query(
      Constants.logTable,
      columns: columns,
      where: 'userId = ?',
      whereArgs: <int>[userId],
      orderBy: 'loginTime DESC',
    );

    final List<Log> logs =
        result.isNotEmpty ? result.map((Map<String, dynamic> log) => Log.fromMap(log)).toList() : <Log>[];

    return logs;
  }

  /// Returns logs based on user's ID and IP address.
  Future<List<Log>> getLogsByUserIdAndIpAddress({List<String> columns, int userId, String ipAddress}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result = await database.query(
      Constants.logTable,
      columns: columns,
      where: 'userId = ? AND ipAddress = ?',
      whereArgs: <Object>[userId, ipAddress],
      orderBy: 'loginTime DESC',
    );

    final List<Log> logs =
        result.isNotEmpty ? result.map((Map<String, dynamic> log) => Log.fromMap(log)).toList() : <Log>[];

    return logs;
  }

  /// Creates log.
  Future<int> createLog(Log log) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.insert(Constants.logTable, log.toMap());

    return result;
  }

  /// Updates log.
  Future<int> updateLog(Log log) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.update(
      Constants.logTable,
      log.toMap(),
      where: 'id = ?',
      whereArgs: <int>[log.id],
    );

    return result;
  }
}
