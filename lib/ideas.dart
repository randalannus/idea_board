import 'package:flutter/cupertino.dart';
import 'package:idea_board/db_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const fId = "id";
const fText = "text";
const fCreatedAt = "createdAt";
const fIsArchived = "isArchived";
const fLastRecommended = "lastRecommended";

class IdeasProvider with ChangeNotifier {
  Future<Idea> getIdea(int id) async {
    final db = await DBHandler.initializeDB();
    final maps = await db.query(DBHandler.ideasTable,
        where: "$fId = ?", whereArgs: [id], limit: 1);
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
    final Map<String, Object?> map = {fId: id, fText: text};
    await db.update(
      DBHandler.ideasTable,
      map,
      where: "$fId = ?",
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> archive(int id) async {
    final db = await DBHandler.initializeDB();
    final Map<String, Object?> map = {
      fIsArchived: 1,
      fLastRecommended: null,
    };
    await db.update(
      DBHandler.ideasTable,
      map,
      where: "$fId = ?",
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<List<Idea>> listIdeas({bool includeArchived = false}) async {
    final db = await DBHandler.initializeDB();
    final maps = await db.query(
      DBHandler.ideasTable,
      orderBy: "$fCreatedAt ASC",
      where: includeArchived ? null : "$fIsArchived = 0",
    );
    return mapsToIdeas(maps);
  }

  Future<void> setLastRecommended(int id, int lastRecommended) async {
    final db = await DBHandler.initializeDB();
    await db.update(
      DBHandler.ideasTable,
      {fLastRecommended: lastRecommended},
      where: "$fId = ?",
      whereArgs: [id],
    );
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
      : id = res[fId],
        text = res[fText],
        createdAt = DateTime.fromMillisecondsSinceEpoch(res[fCreatedAt]),
        isArchived = res[fIsArchived] == 1,
        lastRecommended = res[fLastRecommended];

  Map<String, Object?> toMap() {
    return {
      fId: id,
      fText: text,
      fCreatedAt: createdAt.millisecondsSinceEpoch,
      fIsArchived: isArchived ? 1 : 0,
      fLastRecommended: lastRecommended,
    };
  }
}
