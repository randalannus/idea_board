import 'package:flutter/cupertino.dart';
import 'package:idea_board/legacy/db_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:idea_board/model/idea.dart';

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
    // ignore: deprecated_member_use_from_same_package
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
      // ignore: deprecated_member_use_from_same_package
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
      orderBy: "$fCreatedAt DESC",
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
    // ignore: deprecated_member_use_from_same_package
    return maps.map<Idea>(Idea.fromMap).toList();
  }
}
