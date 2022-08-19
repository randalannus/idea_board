import 'package:cloud_firestore/cloud_firestore.dart';

class Idea {
  static const fId = "id";
  static const fPlainText = "text";
  static const fRichText = "richText";
  static const fCreatedAt = "createdAt";
  static const fIsArchived = "isArchived";
  static const fLastRecommended = "lastRecommended";

  final String id;
  final String plainText;
  final String? richText;
  final DateTime createdAt;
  final bool isArchived;
  final int? lastRecommended;

  const Idea({
    required this.id,
    required this.plainText,
    required this.richText,
    required this.createdAt,
    required this.isArchived,
    required this.lastRecommended,
  });

  Map<String, dynamic> toFirestore() {
    return {
      fId: id,
      fPlainText: plainText,
      fRichText: richText,
      fCreatedAt: createdAt,
      fIsArchived: isArchived,
      fLastRecommended: lastRecommended,
    };
  }

  Idea.fromFirestore(Map<String, dynamic> map)
      : id = map[fId],
        plainText = map[fPlainText],
        richText = map[fRichText],
        createdAt = (map[fCreatedAt] as Timestamp).toDate(),
        isArchived = map[fIsArchived],
        lastRecommended = map[fLastRecommended];

  @Deprecated("Only used for parsing to and from SQLite")
  Idea.fromMap(Map<String, dynamic> res)
      : id = res[fId].toString(),
        plainText = res[fPlainText],
        richText = null,
        createdAt = DateTime.fromMillisecondsSinceEpoch(res[fCreatedAt]),
        isArchived = res[fIsArchived] == 1,
        lastRecommended = res[fLastRecommended];

  @Deprecated("Only used for parsing to and from SQLite")
  Map<String, Object?> toMap() {
    return {
      fId: int.parse(id),
      fPlainText: plainText,
      fCreatedAt: createdAt.millisecondsSinceEpoch,
      fIsArchived: isArchived ? 1 : 0,
      fLastRecommended: lastRecommended,
    };
  }
}
