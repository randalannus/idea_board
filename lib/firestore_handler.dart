import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idea_board/model/idea.dart';

class FirestoreHandler {
  final db = FirebaseFirestore.instance;

  Future<Idea> getIdea(int id) async {
    throw UnimplementedError();
  }

  Future<Idea> newIdea() async {
    throw UnimplementedError();
  }

  Future<void> editText(int id, String text) async {
    throw UnimplementedError();
  }

  Future<void> archive(int id) async {
    throw UnimplementedError();
  }

  Future<List<Idea>> listIdeas({bool includeArchived = false}) async {
    throw UnimplementedError();
  }

  Future<void> setLastRecommended(int id, int lastRecommended) async {
    throw UnimplementedError();
  }
}
