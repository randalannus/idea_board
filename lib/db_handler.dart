import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHandler {
  static const dbName = "ideas.db";
  static const ideasTable = "ideas";

  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(join(path, dbName), version: 4,
        onCreate: (db, version) async {
      _createTables(db);
    }, onUpgrade: (db, old_version, new_version) async {
      if (old_version <= 3) {
        _dropTables(db);
        _createTables(db);
        return;
      }
    });
  }

  static Future _createTables(Database db) {
    return db.execute(
      """CREATE TABLE $ideasTable(
				id INTEGER PRIMARY KEY,
				text TEXT NOT NULL,
				createdAt INTEGER NOT NULL,
				isArchived INTEGER NOT NULL
			);""",
    );
  }

  static Future _dropTables(Database db) {
    return db.execute(
      "DROP TABLE $ideasTable;",
    );
  }
}
