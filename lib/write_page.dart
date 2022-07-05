import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:provider/provider.dart';

class WritePage extends StatelessWidget {
  final _controller = TextEditingController();
  final int ideaId;

  WritePage(this.ideaId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<IdeasProvider>(context, listen: false)
        .getIdea(ideaId)
        .then((idea) => _controller.text = idea.text);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Idea"),
        iconTheme: Theme.of(context).iconTheme,
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
            onChanged: (text) async => await onTextChanged(context, text),
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

  Future onTextChanged(BuildContext context, String text) async {
    await Provider.of<IdeasProvider>(context, listen: false)
        .edit(Idea(ideaId, text));
  }
}
