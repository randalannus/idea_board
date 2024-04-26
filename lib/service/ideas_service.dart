import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idea_board/model/idea.dart';
import 'package:idea_board/model/user.dart';

class IdeasService {
  static const cUsers = "users";
  static const cIdeas = "ideas";

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  User user;

  IdeasService({required this.user});

  /// Fetch the idea from the database. If no such idea exists for the userId,
  /// an [ArgumentError] is thrown.
  Future<Idea> getIdea(String ideaId) async {
    var snapshot = await _ideasColRef(user.uid).doc(ideaId).get();
    var data = snapshot.data();
    if (data == null) {
      throw ArgumentError(
          "There is no idea with id [$ideaId] for the user [${user.uid}]");
    }
    return Idea.fromFirestore(data);
  }

  /// Creates a new idea.
  Future<Idea> newIdea({isProcessingAudio = false}) async {
    final idea = Idea.createNew(isProcessingAudio: isProcessingAudio);
    final map = idea.toFirestore();
    map[Idea.fCreatedAt] = FieldValue.serverTimestamp();
    await _ideasColRef(user.uid).doc(idea.id).set(map);
    return idea;
  }

  /// Changes the text of an idea.
  /// If the idea does not exist, a [FirebaseException] will be thrown.
  Future<void> editIdeaText(
    String ideaId,
    String plainText,
    String? richText,
  ) async {
    var map = {Idea.fPlainText: plainText, Idea.fRichText: richText};
    await _ideasColRef(user.uid).doc(ideaId).update(map);
  }

  /// Archives an idea.
  /// If the idea does not exist, a [FirebaseException] will be thrown.
  Future<void> archiveIdea(String ideaId) async {
    print("IdeasService.archiveIdea called");
    var map = {Idea.fIsArchived: true};
    await _ideasColRef(user.uid).doc(ideaId).update(map);
  }

  /// An event is sent whenever the list of all ideas for a user changes.
  Stream<List<Idea>> ideasListStream() {
    return _ideasColRef(user.uid)
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
  Future<void> setIdeaLastRecommended({
    required String ideaId,
    required int? lastRecommended,
  }) async {
    var map = {Idea.fLastRecommended: lastRecommended};
    await _ideasColRef(user.uid).doc(ideaId).update(map);
  }

  static CollectionReference<Map<String, dynamic>> _ideasColRef(String userId) {
    return _db.collection(cUsers).doc(userId).collection(cIdeas);
  }
}
