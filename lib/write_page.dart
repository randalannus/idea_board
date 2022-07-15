import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:provider/provider.dart';

class WritePage extends StatelessWidget {
  final _controller = TextEditingController();
  final int ideaId;
  final String? initialText;

  WritePage({required this.ideaId, this.initialText, Key? key})
      : super(key: key) {
    if (initialText != null) {
      _controller.text = initialText!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (initialText == null) {
      Provider.of<IdeasProvider>(context, listen: false)
          .getIdea(ideaId)
          .then((idea) => _controller.text = idea.text);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Idea"),
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
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: TextField(
            autofocus: true,
            maxLines: null,
            expands: true,
            controller: _controller,
            onChanged: (text) async => await _onTextChanged(context, text),
            focusNode: FocusNode(),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
            decoration: const InputDecoration(border: InputBorder.none),
            cursorColor: Colors.black,
          ),
        ),
      )),
    );
  }

  Future<void> _onTextChanged(BuildContext context, String text) async {
    await Provider.of<IdeasProvider>(context, listen: false)
        .editText(ideaId, text);
  }

  void _onArchivePressed(BuildContext context) {
    Provider.of<IdeasProvider>(context, listen: false)
        .archive(ideaId)
        .then((_) => Navigator.of(context).pop());
  }
}
