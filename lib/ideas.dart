import 'package:flutter/cupertino.dart';
import 'package:idea_board/db_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class IdeasProvider with ChangeNotifier {
  Future<Idea> getIdea(int id) async {
    final db = await DBHandler.initializeDB();
    final maps = await db.query(DBHandler.ideasTable,
        where: 'id = ?', whereArgs: [id], limit: 1);
    return Idea.fromMap(maps[0]);
  }

  Future<Idea> newIdea() async {
    final db = await DBHandler.initializeDB();
    final idea = Idea(
        id: const Uuid().v4().hashCode,
        text: "",
        createdAt: DateTime.now(),
        isArchived: false);

    await db.insert(
      DBHandler.ideasTable,
      idea.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
    return idea;
  }

  Future<void> editText(int id, String text) async {
    final db = await DBHandler.initializeDB();
    final Map<String, Object?> map = {"id": id, "text": text};
    await db.update(
      DBHandler.ideasTable,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> archive(int id) async {
    final db = await DBHandler.initializeDB();
    final Map<String, Object?> map = {"id": id, "isArchived": 1};
    await db.update(
      DBHandler.ideasTable,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<List<Idea>> listIdeas({bool includeArchived = false}) async {
    final db = await DBHandler.initializeDB();
    String? where;
    List<Object?>? whereArgs;
    if (!includeArchived) {
      where = "isArchived = ?";
      whereArgs = [0];
    }
    final maps = await db.query(DBHandler.ideasTable,
        orderBy: "createdAt ASC", where: where, whereArgs: whereArgs);
    return mapsToIdeas(maps);
  }

  Future<Idea> selectRandom() async {
    final db = await DBHandler.initializeDB();
    final maps = await db.rawQuery(
        "SELECT * FROM ${DBHandler.ideasTable} ORDER BY RANDOM() LIMIT 1;");
    return Idea.fromMap(maps[0]);
  }

  List<Idea> mapsToIdeas(List<Map<String, dynamic>> maps) {
    return maps.map<Idea>(Idea.fromMap).toList();
  }
}

class Idea {
  final int id;
  final String text;
  final DateTime createdAt;
  final bool isArchived;

  const Idea(
      {required this.id,
      required this.text,
      required this.createdAt,
      required this.isArchived});
  Idea.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        text = res["text"],
        isArchived = res["isArchived"] == 1,
        createdAt = DateTime.fromMillisecondsSinceEpoch(res["createdAt"]);

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "text": text,
      "createdAt": createdAt.millisecondsSinceEpoch,
      "isArchived": isArchived ? 1 : 0
    };
  }
}
