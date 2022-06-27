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
    final idea = Idea(const Uuid().v4().hashCode, "");
    await db.insert(
      DBHandler.ideasTable,
      idea.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
    return idea;
  }

  Future edit(Idea idea) async {
    final db = await DBHandler.initializeDB();
    await db.update(
      DBHandler.ideasTable,
      idea.toMap(),
      where: 'id = ?',
      whereArgs: [idea.id],
    );
    notifyListeners();
  }

  Future<List<Idea>> listIdeas() async {
    final db = await DBHandler.initializeDB();
    final maps = await db.query(DBHandler.ideasTable);
    return mapsToIdeas(maps);
  }

  List<Idea> mapsToIdeas(List<Map<String, dynamic>> maps) {
    return maps.map<Idea>(Idea.fromMap).toList();
  }
}

class Idea {
  final int id;
  final String text;

  const Idea(this.id, this.text);
  Idea.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        text = res["text"];

  Map<String, Object?> toMap() {
    return {'id': id, 'text': text};
  }
}
