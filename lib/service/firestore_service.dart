import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idea_board/model/idea.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  static const cUsers = "users";
  static const cIdeas = "ideas";

  static const _uuid = Uuid();
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Fetch the idea from the database. If no such idea exists for the userId,
  /// an [ArgumentError] is thrown.
  static Future<Idea> getIdea(String userId, String ideaId) async {
    var snapshot = await _ideasColRef(userId).doc(ideaId).get();
    var data = snapshot.data();
    if (data == null) {
      throw ArgumentError(
          "There is no idea with id [$ideaId] for the user [$userId]");
    }
    return Idea.fromFirestore(data);
  }

  /// Creates a new idea.
  static Future<Idea> newIdea(String userId) async {
    final idea = Idea(
      id: _uuid.v4(),
      plainText: "",
      richText: null,
      createdAt: DateTime.now(),
      isArchived: false,
      lastRecommended: null,
    );
    await _ideasColRef(userId).doc(idea.id.toString()).set(idea.toFirestore());
    return idea;
  }

  /// Changes the text of an idea.
  /// If the idea does not exist, a [FirebaseException] will be thrown.
  static Future<void> editIdeaText(
      String userId, String ideaId, String plainText, String? richText) async {
    var map = {Idea.fPlainText: plainText, Idea.fRichText: richText};
    await _ideasColRef(userId).doc(ideaId).update(map);
  }

  /// Archives an idea.
  /// If the idea does not exist, a [FirebaseException] will be thrown.
  static Future<void> archiveIdea(String userId, String ideaId) async {
    var map = {Idea.fIsArchived: true};
    await _ideasColRef(userId).doc(ideaId).update(map);
  }

  /// An event is sent whenever the list of all ideas for a user changes.
  static Stream<List<Idea>> ideasListStream(String userId) {
    return _ideasColRef(userId)
        .orderBy(Idea.fCreatedAt, descending: true)
        .snapshots()
        .map<List<Idea>>(
          (querySnapshot) => querySnapshot.docs
              .map<Idea>(
                (docSnapshot) => Idea.fromFirestore(docSnapshot.data()),
              )
              .toList(),
        )
        .handleError((_) {});
  }

  /// Sets the lastRecommended field of an idea.
  /// If the idea does not exist, a [FirebaseException] will be thrown.
  static Future<void> setIdeaLastRecommended({
    required String userId,
    required String ideaId,
    required int? lastRecommended,
  }) async {
    var map = {Idea.fLastRecommended: lastRecommended};
    await _ideasColRef(userId).doc(ideaId).update(map);
  }

  @Deprecated("Only used to transfer ideas from local SQL database")
  static Future<void> setIdeaCreatedAt({
    required String userId,
    required String ideaId,
    required DateTime createdAt,
  }) async {
    var map = {Idea.fCreatedAt: createdAt};
    await _ideasColRef(userId).doc(ideaId).update(map);
  }

  static CollectionReference<Map<String, dynamic>> _ideasColRef(String userId) {
    return _db.collection(cUsers).doc(userId).collection(cIdeas);
  }
}
