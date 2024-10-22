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
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'database.db');

    final Database database = await openDatabase(
      path,
      version: 1,
      onCreate: initializeDatabase,
      onUpgrade: upgradeDatabase,
    );

    database.execute('PRAGMA journal_mode=TRUNCATE');

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
    await database
        .execute('CREATE TABLE ${Constants.userTable} ('
            'id INTEGER PRIMARY KEY, '
            'username TEXT, '
            'passwordHash TEXT, '
            'salt TEXT, '
            'isPasswordKeptAsHash INTEGER '
            ')')
        .then(
          (_) async => await database
              .execute('CREATE TABLE ${Constants.passwordTable} ('
                  'id INTEGER PRIMARY KEY, '
                  'userId INTEGER, '
                  'ownerPasswordId INTEGER, '
                  'isSharedUpdated INTEGER, '
                  'isArchived INTEGER, '
                  'isDeleted INTEGER, '
                  'password TEXT, '
                  'vector TEXT, '
                  'webAddress TEXT, '
                  'description TEXT, '
                  'login TEXT, '
                  'FOREIGN KEY (userId) REFERENCES ${Constants.userTable} (id), '
                  'FOREIGN KEY (ownerPasswordId) REFERENCES ${Constants.passwordTable} (id)'
                  ')')
              .then(
                (_) async => database
                    .execute('CREATE TABLE ${Constants.logTable} ('
                        'id INTEGER PRIMARY KEY, '
                        'userId INTEGER, '
                        'isSuccessful INTEGER, '
                        'ipAddress TEXT, '
                        'isUnblocked INTEGER, '
                        'loginTime INTEGER, '
                        'FOREIGN KEY (userId) REFERENCES ${Constants.userTable} (id)'
                        ')')
                    .then(
                      (_) async => database.execute('CREATE TABLE ${Constants.dataChangeTable} ('
                          'id INTEGER PRIMARY KEY, '
                          'userId INTEGER, '
                          'passwordId INTEGER, '
                          'previousRecordId INTEGER, '
                          'presentRecordId INTEGER, '
                          'actionType TEXT, '
                          'changeTime INTEGER, '
                          'FOREIGN KEY (userId) REFERENCES ${Constants.userTable} (id), '
                          'FOREIGN KEY (passwordId) REFERENCES ${Constants.passwordTable} (id), '
                          'FOREIGN KEY (previousRecordId) REFERENCES ${Constants.passwordTable} (id), '
                          'FOREIGN KEY (presentRecordId) REFERENCES ${Constants.passwordTable} (id) '
                          ')'),
                    ),
              ),
        );
  }
}
