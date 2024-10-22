import 'package:sqflite_common/sqlite_api.dart';

import '../../utils/constants.dart';
import '../data_sources/database_provider.dart';
import '../models/models.dart' show DataChange;

/// A data access object representing the data change access.
class DataChangeDao {
  /// Creates data access object representing the data change access.
  DataChangeDao({DatabaseProvider databaseProvider})
      : _databaseProvider = databaseProvider ?? DatabaseProvider.databaseProvider;

  /// The database provider.
  final DatabaseProvider _databaseProvider;

  /// Returns data changes based on user's ID.
  Future<List<DataChange>> getDataChangesByUserId({List<String> columns, int userId}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result = await database.query(
      Constants.dataChangeTable,
      columns: columns,
      where: 'userId = ?',
      whereArgs: <int>[userId],
    );

    final List<DataChange> dataChanges = result.isNotEmpty
        ? result.map((Map<String, dynamic> dataChange) => DataChange.fromMap(dataChange)).toList()
        : <DataChange>[];

    return dataChanges;
  }

  /// Returns data changes based on password's ID.
  Future<List<DataChange>> getDataChangesByPasswordId({List<String> columns, int passwordId}) async {
    final Database database = await _databaseProvider.database;

    final List<Map<String, dynamic>> result = await database.query(
      Constants.dataChangeTable,
      columns: columns,
      where: 'passwordId = ?',
      whereArgs: <int>[passwordId],
    );

    final List<DataChange> dataChanges = result.isNotEmpty
        ? result.map((Map<String, dynamic> dataChange) => DataChange.fromMap(dataChange)).toList()
        : <DataChange>[];

    return dataChanges;
  }

  /// Creates data change.
  Future<int> createDataChange(DataChange dataChange) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.insert(Constants.dataChangeTable, dataChange.toMap());

    return result;
  }

  /// Updates data change.
  Future<int> updateDataChange(DataChange dataChange) async {
    final Database database = await _databaseProvider.database;

    final int result = await database.update(
      Constants.dataChangeTable,
      dataChange.toMap(),
      where: 'id = ?',
      whereArgs: <int>[dataChange.id],
    );

    return result;
  }
}
