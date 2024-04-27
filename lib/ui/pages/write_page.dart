import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:idea_board/model/idea.dart';
import 'package:idea_board/service/ideas_service.dart';

class WritePage extends StatefulWidget {
  final String ideaId;
  final Idea initialIdea;
  final IdeasService ideasService;

  const WritePage({
    required this.ideaId,
    required this.initialIdea,
    required this.ideasService,
    super.key,
  });

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  late final QuillController _controller;
  late final Saver _saver;
  late final StreamSubscription _changeSub;

  @override
  void initState() {
    _controller = createQuillController(widget.initialIdea);
    _saver = Saver(widget.ideasService, widget.ideaId, _controller);
    _changeSub = _controller.document.changes.listen((_) => _saver.notify());

    super.initState();
  }

  @override
  void dispose() {
    _changeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) => _saver.save(),
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
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).cardColor,
                        child: _buildRichTextEditor(context),
                      ),
                    ),
                    IgnorePointer(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder<SaverState>(
                              stream: _saver.stateChanges,
                              initialData: _saver.state,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();
                                return Text(
                                  _savingMessage(snapshot.data!),
                                  style: TextStyle(
                                    color: Colors.grey.shade300,
                                  ),
                                );
                              }),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              _buildEditorToolbar(context)
            ],
          ),
        ),
      ),
    );
  }

  String _savingMessage(SaverState state) {
    if (state == SaverState.saved) return "Saved";
    if (state == SaverState.saving) return "Saving..";
    return "Network Error";
  }

  Widget _buildEditorToolbar(BuildContext context) {
    var toolbar = QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
        controller: _controller,
        showAlignmentButtons: false,
        showFontFamily: false,
        showFontSize: false,
        showHeaderStyle: false,
        showSearchButton: false,
        showColorButton: false,
        showCodeBlock: false,
        showInlineCode: false,
        showListCheck: false,
        showLink: false,
        showItalicButton: false,
        showUnderLineButton: false,
        showUndo: false,
        showIndent: true,
        showQuote: false,
        showClearFormat: false,
        showBackgroundColorButton: false,
        showStrikeThrough: false,
        showRedo: false,
        showSubscript: false,
        showSuperscript: false,
        toolbarSectionSpacing: 2,
        showDividers: false,
        buttonOptions: const QuillSimpleToolbarButtonOptions(),
      ),
    );

    return toolbar;
  }

  Widget _buildRichTextEditor(BuildContext context) {
    var quillEditor = QuillEditor(
      scrollController: ScrollController(),
      focusNode: FocusNode(),
      configurations: QuillEditorConfigurations(
        controller: _controller,
        scrollable: true,
        autoFocus: false,
        readOnly: false,
        placeholder: 'Write here...',
        expands: false,
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        textCapitalization: TextCapitalization.sentences,
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            Theme.of(context).textTheme.bodyLarge!,
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
        ),
      ),
    );

    return quillEditor;
  }

  Future<void> _onArchivePressed(BuildContext context) async {
    Navigator.of(context).pop();
    await widget.ideasService.archiveIdea(widget.ideaId);
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

/// A class for periodically saving text from Quill to the database.
///
/// Call [Saver.notify] when there are changes to the idea's text.
/// [Saver] will wait and accumulate changes until [Saver.delay] has passed since last call and then save.
/// Calling [Saver.notify] when it is already waiting resets the timer.
///
/// Call [Saver.save] to save immediately and cancel waiting for changes.
class Saver {
  final IdeasService ideasService;
  final String ideaId;
  final QuillController controller;
  static const delay = Duration(seconds: 2);

  Timer? _timer;

  SaverState state = SaverState.saved;
  final _controller = StreamController<SaverState>.broadcast();
  Stream<SaverState> get stateChanges => _controller.stream.distinct();

  Saver(this.ideasService, this.ideaId, this.controller) {
    _controller.add(state);
  }

  void notify() {
    _timer?.cancel();
    _timer = Timer(delay, save);
    _setState(SaverState.saving);
  }

  Future<void> save() async {
    _timer?.cancel();
    try {
      await ideasService
          .editIdeaText(
            ideaId,
            controller.document.toPlainText(),
            jsonEncode(controller.document.toDelta().toJson()),
          )
          .timeout(const Duration(seconds: 5));
    } on TimeoutException catch (_) {
      _setState(SaverState.networkError);
      return;
    }
    _setState(SaverState.saved);
  }

  void _setState(SaverState state) {
    this.state = state;
    _controller.add(state);
  }
}

enum SaverState { saved, saving, networkError }
