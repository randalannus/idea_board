import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:idea_board/model/chat_message.dart';
import 'package:idea_board/service/chat_service.dart';
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

  bool _isTyping(List<ChatMessage> messages) {
    for (var message in messages) {
      if (message.writing == true && message.text.isEmpty) {
        return true;
      }
    }
    return false;
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
          (chatMsg) => types.TextMessage(
            id: chatMsg.uid,
            text: chatMsg.text,
            createdAt: chatMsg.createdAt?.toUtc().millisecondsSinceEpoch,
            author: types.User(id: chatMsg.by.name),
            type: types.MessageType.text,
          ),
        )
        .toList();
  }
}
