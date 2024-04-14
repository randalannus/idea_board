import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatPage extends StatelessWidget {
  ChatPage({super.key});

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return chat.Chat(
      messages: const [],
      onSendPressed: (_) {},
      user: const types.User(id: "1"),
      theme: _chatTheme(context),
      inputOptions: chat.InputOptions(
        onTextChanged: (text) => _textController.text = text,
        textEditingController: _textController,
      ),
    );
  }

  chat.ChatTheme _chatTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return chat.DefaultChatTheme(
      backgroundColor: colorScheme.background,
      primaryColor: colorScheme.primary,
      secondaryColor: colorScheme.secondary,
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
    );
  }
}
