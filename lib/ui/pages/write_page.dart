import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:idea_board/model/idea.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/firestore_service.dart';
import 'package:provider/provider.dart';

class WritePage extends StatefulWidget {
  final String ideaId;
  final Idea initialIdea;

  const WritePage({
    required this.ideaId,
    required this.initialIdea,
    Key? key,
  }) : super(key: key);

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  late final QuillController _controller;

  @override
  void initState() {
    _controller = createQuillController(widget.initialIdea);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.delete),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: _buildRichTextEditor(context),
                ),
              ),
              _buildEditorToolbar(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorToolbar(BuildContext context) {
    var toolbar = QuillToolbar.basic(
      controller: _controller,
      showAlignmentButtons: false,
      showFontFamily: false,
      showFontSize: false,
      showHeaderStyle: false,
      showVideoButton: false,
      showSearchButton: false,
      showColorButton: false,
      showCodeBlock: false,
      showInlineCode: false,
      showListCheck: false,
      showLink: false,
      showItalicButton: false,
      showUnderLineButton: false,
      showUndo: false,
      showImageButton: false,
      showIndent: true,
      showQuote: false,
      showClearFormat: false,
      showBackgroundColorButton: false,
      showStrikeThrough: false,
      showRedo: false,
      toolbarIconSize: 24,
      toolbarSectionSpacing: 2,
      showDividers: false,
    );

    return toolbar;
  }

  Widget _buildRichTextEditor(BuildContext context) {
    var quillEditor = QuillEditor(
      controller: _controller,
      scrollController: ScrollController(),
      scrollable: true,
      focusNode: FocusNode(),
      autoFocus: false,
      readOnly: false,
      placeholder: 'Write here...',
      expands: false,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      textCapitalization: TextCapitalization.sentences,
    );

    return quillEditor;
  }

  Future<void> _onArchivePressed(BuildContext context) async {
    User user = Provider.of<User>(context, listen: false);
    Navigator.of(context).pop(_controller.document);
    await FirestoreService.archiveIdea(user.uid, widget.ideaId);
  }

  void _onBackPressed(BuildContext context) {
    Navigator.of(context).pop(_controller.document);
  }
}

QuillController createQuillController(Idea idea) {
  Document parsedDocument;
  if (idea.richText != null && idea.richText!.isNotEmpty) {
    List<dynamic>? decodedJson = jsonDecode(idea.richText!);
    if (decodedJson == null) throw "Invalid json";
    parsedDocument = Document.fromJson(decodedJson);
  } else if (idea.plainText.isNotEmpty) {
    parsedDocument = Document()..insert(0, idea.plainText);
  } else {
    parsedDocument = Document();
  }
  return QuillController(
    document: parsedDocument,
    selection: const TextSelection.collapsed(offset: 0),
  );
}
