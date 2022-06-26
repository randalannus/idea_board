import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:provider/provider.dart';

class WritePage extends StatelessWidget {
  final _controller = TextEditingController();
  final int ideaId;

  WritePage(this.ideaId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller.text =
        Provider.of<IdeasProvider>(context, listen: false).getIdea(ideaId).text;
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Idea"),
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
            onChanged: (text) => onTextChanged(context, text),
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

  void onTextChanged(BuildContext context, String text) {
    Provider.of<IdeasProvider>(context, listen: false).edit(ideaId, text);
  }
}
