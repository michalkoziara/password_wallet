import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/constants.dart';

/// A database provider.
class DatabaseProvider {
  /// The database provider instance.
  static final DatabaseProvider databaseProvider = DatabaseProvider();

  Database _database;

  /// Gets database.
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await createDatabase();
    return _database;
  }

  /// Creates database.
  Future<Database> createDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'database.db');

    final Database database = await openDatabase(
      path,
      version: 1,
      onCreate: initializeDatabase,
      onUpgrade: upgradeDatabase,
    );
    return database;
  }

  /// Upgrades old version of database.
  void upgradeDatabase(
    Database database,
    int oldVersion,
    int newVersion,
  ) {
    if (newVersion > oldVersion) {}
  }

  /// Initialises database structure.
  Future<void> initializeDatabase(Database database, int version) async {
    final String userTable = Constants.userTable;

    await database.execute('CREATE TABLE $userTable ('
        'id INTEGER PRIMARY KEY, '
        'username TEXT, '
        'passwordHash TEXT, '
        'salt TEXT, '
        'isPasswordKeptAsHash INTEGER '
        ')');
  }
}
