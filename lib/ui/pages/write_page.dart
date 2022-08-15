import 'package:flutter/material.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/firestore_service.dart';
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
    return WillPopScope(
      onWillPop: () {
        _onBackPressed(context);
        return Future.value(false);
      },
      child: Scaffold(
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
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              autofocus: initialText == null || initialText!.isEmpty,
              controller: _controller,
              focusNode: FocusNode(),
              style: Theme.of(context).textTheme.bodyText1,
              decoration: const InputDecoration(border: InputBorder.none),
              cursorColor: Colors.black,
            ),
          ),
        )),
      ),
    );
  }

  Future<void> _loadTextIfNeeded(BuildContext context) async {
    if (initialText != null || _controller.text.isNotEmpty) return;
    User user = Provider.of<User>(context, listen: false);
    var idea = await FirestoreService.getIdea(user.uid, ideaId);
    if (idea.text.isEmpty) return;
    _controller.text = idea.text;
  }

  Future<void> _onArchivePressed(BuildContext context) async {
    User user = Provider.of<User>(context, listen: false);
    Navigator.of(context).pop(_controller.text);
    await FirestoreService.archiveIdea(user.uid, ideaId);
  }

  void _onBackPressed(BuildContext context) {
    Navigator.of(context).pop(_controller.text);
  }
}
