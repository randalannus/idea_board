import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idea_board/model/chat_message.dart';
import 'package:idea_board/model/user.dart';
import 'package:uuid/v4.dart';

class ChatService {
  static const cUsers = "users";
  static const cChats = "chats";
  static const cMessages = "messages";
  static const defaultChat = "__defaultChat";

  static const uuid = UuidV4();
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  final User user;

  const ChatService({required this.user});

  /// Stream of the chat history for the default chat.
  Stream<List<ChatMessage>> messagesStream() {
    return _messagesColRef()
        .orderBy(ChatMessage.fCreatedAt, descending: true)
        .snapshots()
        .map<List<ChatMessage>>((snapshot) => _parseMessages(snapshot.docs))
        .handleError((e) {});
  }

  /// Send a user message to the chatbot.
  Future<void> sendMessage(String text) async {
    final uid = uuid.generate();
    final message = ChatMessage(
      uid: uid,
      text: text,
      by: SenderType.user,
      writing: false,
    );
    final firestoreMap = message.toFirestore();
    firestoreMap[ChatMessage.fCreatedAt] = FieldValue.serverTimestamp();
    await _messagesColRef().doc(uid).set(firestoreMap);
  }

  CollectionReference<Map<String, dynamic>> _messagesColRef() {
    return _db
        .collection(cUsers)
        .doc(user.uid)
        .collection(cChats)
        .doc(defaultChat)
        .collection(cMessages);
  }

  static List<ChatMessage> _parseMessages(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs
        .map<ChatMessage>((e) => ChatMessage.fromFirestore(e.data()))
        .toList();
  }
}
