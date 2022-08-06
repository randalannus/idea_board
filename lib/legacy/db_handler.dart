import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHandler {
  static const dbName = "ideas.db";
  static const ideasTable = "ideas";

  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(join(path, dbName), version: 5,
        onCreate: (db, version) async {
      await _createTables(db);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion <= 3) {
        await _dropTables(db);
        await _createTables(db);
        return;
      } else if (oldVersion == 4) {
        await _4to5(db);
      }
    });
  }

  static Future _createTables(Database db) {
    return db.execute(
      """CREATE TABLE $ideasTable(
				id INTEGER PRIMARY KEY,
				text TEXT NOT NULL,
				createdAt INTEGER NOT NULL,
				isArchived INTEGER NOT NULL,
				lastRecommended INTEGER
			);""",
    );
  }

  // ignore: non_constant_identifier_names
  static Future<void> _4to5(Database db) async {
    await db.execute(
      """ALTER TABLE $ideasTable
  			ADD lastRecommended INTEGER;
			""",
    );
  }

  static Future _dropTables(Database db) {
    return db.execute(
      "DROP TABLE $ideasTable;",
    );
  }
}
