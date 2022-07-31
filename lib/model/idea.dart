import 'package:idea_board/legacy/ideas.dart';

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

  @Deprecated("Only used for parsing to and from SQLite")
  Idea.fromMap(Map<String, dynamic> res)
      : id = res[fId],
        text = res[fText],
        createdAt = DateTime.fromMillisecondsSinceEpoch(res[fCreatedAt]),
        isArchived = res[fIsArchived] == 1,
        lastRecommended = res[fLastRecommended];

  @Deprecated("Only used for parsing to and from SQLite")
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
