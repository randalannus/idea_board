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
      isArchived: false,
      lastRecommended: null,
    );

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

  Future<void> setLastRecommended(int ideaId, int lastRecommended) async {
    final db = await DBHandler.initializeDB();
    await db.rawUpdate("""
			UPDATE ${DBHandler.ideasTable}
			SET lastRecommended = $lastRecommended
			WHERE id = $ideaId;
		""");
    notifyListeners();
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
  final int? lastRecommended;

  const Idea({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.isArchived,
    required this.lastRecommended,
  });

  Idea.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        text = res["text"],
        createdAt = DateTime.fromMillisecondsSinceEpoch(res["createdAt"]),
        isArchived = res["isArchived"] == 1,
        lastRecommended = res["lastRecommended"];

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "text": text,
      "createdAt": createdAt.millisecondsSinceEpoch,
      "isArchived": isArchived ? 1 : 0,
      "lastRecommended": lastRecommended,
    };
  }
}
