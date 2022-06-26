import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:provider/provider.dart';

class WritePage extends StatelessWidget {
  final _controller = TextEditingController();
  final int ideaId;

  WritePage(this.ideaId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: EditableText(
          controller: _controller,
          onChanged: (text) => onTextChanged(context, text),
          focusNode: FocusNode(),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
          cursorColor: Colors.black,
          backgroundCursorColor: Colors.black,
        ),
      ),
    );
  }

  void onTextChanged(BuildContext context, String text) {
    Provider.of<IdeasProvider>(context, listen: false).edit(ideaId, text);
  }
}
