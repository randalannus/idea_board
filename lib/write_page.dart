import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:idea_board/firestore_handler.dart';
import 'package:provider/provider.dart';

class WritePage extends StatelessWidget {
  final _controller = TextEditingController();
  final String ideaId;
  final String? initialText;

  WritePage({required this.ideaId, this.initialText, Key? key})
      : super(key: key) {
    if (initialText != null) {
      _controller.text = initialText!;
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadTextIfNeeded(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Idea"),
        backgroundColor: Theme.of(context).cardColor,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          IconButton(
              onPressed: () => _onArchivePressed(context),
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Center(
          child: SizedBox.expand(
        child: Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: TextField(
            maxLines: null,
            expands: true,
            autofocus: initialText == null || initialText!.isEmpty,
            controller: _controller,
            onChanged: (text) async => await _onTextChanged(context, text),
            focusNode: FocusNode(),
            style: Theme.of(context).textTheme.bodyText1,
            decoration: const InputDecoration(border: InputBorder.none),
            cursorColor: Colors.black,
          ),
        ),
      )),
    );
  }

  Future<void> _loadTextIfNeeded(BuildContext context) async {
    if (initialText != null || _controller.text.isNotEmpty) return;
    User user = Provider.of<User>(context, listen: false);
    var idea = await FirestoreHandler.getIdea(user.uid, ideaId);
    _controller.text = idea.text;
  }

  Future<void> _onTextChanged(BuildContext context, String text) async {
    User user = Provider.of<User>(context, listen: false);
    await FirestoreHandler.editIdeaText(user.uid, ideaId, text);
  }

  Future<void> _onArchivePressed(BuildContext context) async {
    User user = Provider.of<User>(context, listen: false);
    await FirestoreHandler.archiveIdea(user.uid, ideaId);
  }
}
