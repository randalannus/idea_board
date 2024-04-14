import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  static const fBy = "by";
  static const fText = "text";
  static const fId = "id";
  static const fCreatedAt = "createdAt";

  final String uid;
  final SenderType by;
  final String text;
  final DateTime createdAt;

  const ChatMessage(
      {required this.uid,
      required this.text,
      required this.by,
      required this.createdAt});

  ChatMessage.fromFirestore(Map<String, dynamic> map)
      : by = map[fBy] == "user" ? SenderType.user : SenderType.bot,
        text = map[fText],
        uid = map[fId],
        createdAt = (map[fCreatedAt] as Timestamp).toDate();

  Map<String, dynamic> toFirestore() {
    return {
      fId: uid,
      fText: text,
      fBy: by.name,
      fCreatedAt: createdAt,
    };
  }
}

enum SenderType {
  user,
  bot;
}
