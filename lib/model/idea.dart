import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Idea {
  static const fId = "id";
  static const fPlainText = "text";
  static const fRichText = "richText";
  static const fCreatedAt = "createdAt";
  static const fIsArchived = "isArchived";
  static const fLastRecommended = "lastRecommended";
  static const fIsProcessingAudio = "isProcessingAudio";

  final String id;
  final String plainText;
  final String? richText;
  final DateTime createdAt;
  final bool isArchived;
  final int? lastRecommended;
  final bool isProcessingAudio;

  const Idea({
    required this.id,
    required this.plainText,
    required this.richText,
    required this.createdAt,
    required this.isArchived,
    required this.lastRecommended,
    required this.isProcessingAudio,
  });

  Idea.createNew({this.isProcessingAudio = false})
      : id = const Uuid().v4(),
        plainText = "",
        richText = null,
        createdAt = DateTime.now(),
        isArchived = false,
        lastRecommended = null;

  Map<String, dynamic> toFirestore() {
    return {
      fId: id,
      fPlainText: plainText,
      fRichText: richText,
      fCreatedAt: createdAt,
      fIsArchived: isArchived,
      fLastRecommended: lastRecommended,
      fIsProcessingAudio: isProcessingAudio,
    };
  }

  Idea.fromFirestore(Map<String, dynamic> map)
      : id = map[fId],
        plainText = map[fPlainText] ?? "",
        richText = map[fRichText],
        createdAt = (map[fCreatedAt] as Timestamp).toDate(),
        isArchived = map[fIsArchived] ?? false,
        lastRecommended = map[fLastRecommended],
        isProcessingAudio = map[fIsProcessingAudio] ?? false;
}
