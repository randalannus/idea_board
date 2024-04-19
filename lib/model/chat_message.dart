import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  static const fBy = "by";
  static const fText = "text";
  static const fId = "id";
  static const fCreatedAt = "createdAt";
  static const fReplyingTo = "replyingTo";
  static const fWriting = "writing";

  final String uid;
  final SenderType by;
  final String text;
  final DateTime? createdAt;

  /// True if the message is still being written
  final bool writing;

  /// Id of the message that is being replied to.
  final String? replyingTo;

  ChatMessage({
    required this.uid,
    required this.text,
    required this.by,
    required this.writing,
    this.createdAt,
    this.replyingTo,
  });

  ChatMessage.fromFirestore(Map<String, dynamic> map)
      : by = map[fBy] == "user" ? SenderType.user : SenderType.bot,
        text = map[fText],
        uid = map[fId],
        createdAt = (map[fCreatedAt] as Timestamp?)?.toDate(),
        writing = map[fWriting],
        replyingTo = map[fReplyingTo];

  Map<String, dynamic> toFirestore() {
    return {
      fId: uid,
      fText: text,
      fBy: by.name,
      fCreatedAt: createdAt,
      fWriting: writing,
      fReplyingTo: replyingTo,
    };
  }
}

enum SenderType {
  user,
  bot;
}
