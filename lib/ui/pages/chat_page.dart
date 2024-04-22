import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:idea_board/model/chat_message.dart';
import 'package:idea_board/model/idea.dart';
import 'package:idea_board/service/chat_service.dart';
import 'package:idea_board/service/ideas_service.dart';
import 'package:idea_board/ui/widgets/idea_card.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Creating a text controller to prevent a bug in the chat library.
  // The send button does not sometimes appear when starting writing.
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    return StreamProvider<List<ChatMessage>>(
      create: (context) => chatService.messagesStream(),
      initialData: const [],
      child: Consumer<List<ChatMessage>>(
        builder: (context, messages, _) => chat.Chat(
          messages: _convertMessages(messages),
          customMessageBuilder: _customMessageBuilder,
          onSendPressed: (partialText) =>
              chatService.sendMessage(partialText.text),
          user: const types.User(id: "user"),
          theme: _chatTheme(context),
          inputOptions: chat.InputOptions(
            onTextChanged: (text) =>
                setState(() => _textController.text = text),
            textEditingController: _textController,
          ),
          typingIndicatorOptions: chat.TypingIndicatorOptions(
            typingMode: chat.TypingIndicatorMode.name,
            animationSpeed: const Duration(seconds: 1),
            customTypingWidget: Text(
              "Writing",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            typingUsers: _isTyping(messages)
                ? const [types.User(id: "bot", firstName: "Bot")]
                : [],
          ),
        ),
      ),
    );
  }

  Widget _customMessageBuilder(types.CustomMessage message,
      {required int messageWidth}) {
    return MyTextMessage(
      emojiEnlargementBehavior: chat.EmojiEnlargementBehavior.multi,
      hideBackgroundOnEmojiMessages: true,
      message: types.TextMessage(
        author: message.author,
        id: message.id,
        text: message.metadata?[ChatMessage.fText],
      ),
      showName: false,
      usePreviewData: false,
      referencedIdeaIds:
          message.metadata?[ChatMessage.fReferencedIdeaIds] ?? const [],
      writing: message.metadata?[ChatMessage.fWriting] ?? false,
    );
  }

  bool _isTyping(List<ChatMessage> messages) {
    messages = messages.where((msg) => msg.by == SenderType.bot).toList();
    if (messages.isEmpty) return false;
    final last = messages.last;
    return last.writing && last.text.isEmpty;
  }

  chat.ChatTheme _chatTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return chat.DefaultChatTheme(
      backgroundColor: colorScheme.background,
      primaryColor: colorScheme.primary,
      secondaryColor: colorScheme.secondaryContainer,
      errorColor: colorScheme.error,
      inputSurfaceTintColor: colorScheme.surfaceTint,
      inputBackgroundColor: colorScheme.background,
      inputTextColor: colorScheme.onBackground,
      inputTextStyle: theme.textTheme.bodyMedium!,
      emptyChatPlaceholderTextStyle: theme.textTheme.bodyLarge!,
      inputContainerDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: colorScheme.outlineVariant,
        ),
      ),
      inputPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      inputBorderRadius: BorderRadius.circular(10),
      inputMargin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      messageBorderRadius: 10,
      messageInsetsVertical: 6,
      messageInsetsHorizontal: 10,
    );
  }

  static List<types.Message> _convertMessages(List<ChatMessage> messages) {
    return messages
        .where((chatMsg) => chatMsg.text.isNotEmpty || !chatMsg.writing)
        .map<types.Message>(
      (chatMsg) {
        if (chatMsg.by == SenderType.user) {
          return types.TextMessage(
            id: chatMsg.uid,
            text: chatMsg.text,
            createdAt: chatMsg.createdAt?.toUtc().millisecondsSinceEpoch,
            author: types.User(id: chatMsg.by.name),
            type: types.MessageType.text,
          );
        }
        return types.CustomMessage(
          id: chatMsg.uid,
          author: types.User(id: chatMsg.by.name),
          metadata: {
            ChatMessage.fText: chatMsg.text,
            ChatMessage.fReferencedIdeaIds: chatMsg.referencedIdeaIds,
            ChatMessage.fWriting: chatMsg.writing,
          },
          createdAt: chatMsg.createdAt?.toUtc().millisecondsSinceEpoch,
        );
      },
    ).toList();
  }
}

class MyTextMessage extends chat.TextMessage {
  final List<String> referencedIdeaIds;
  final bool writing;

  const MyTextMessage({
    required super.emojiEnlargementBehavior,
    required super.hideBackgroundOnEmojiMessages,
    required super.message,
    required super.showName,
    required super.usePreviewData,
    this.referencedIdeaIds = const [],
    this.writing = false,
    super.key,
  }) : super();

  @override
  Widget build(BuildContext context) {
    Container superWidget = super.build(context) as Container;
    if (referencedIdeaIds.isEmpty || writing) return superWidget;

    final column = superWidget.child as Column;
    column.children.add(const SizedBox(height: 8));
    final ideas = Provider.of<List<Idea>>(context, listen: false);
    for (var ideaId in referencedIdeaIds) {
      final idea = ideas.where((idea) => idea.id == ideaId).first;
      column.children.add(IdeaCard(idea: idea));
      column.children.add(const SizedBox(height: 4));
    }

    return superWidget;
  }
}
