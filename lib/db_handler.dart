import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHandler {
  static const dbName = "ideas.db";
  static const ideasTable = "ideas";

  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, dbName),
      version: 1,
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE $ideasTable(id INTEGER PRIMARY KEY, text TEXT NOT NULL)",
        );
      },
    );
  }
}
