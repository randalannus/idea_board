import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/firestore_service.dart';
import 'package:idea_board/ui/pages/write_page.dart';
import 'package:idea_board/model/idea.dart';
import 'package:provider/provider.dart';

class IdeaCard extends StatelessWidget {
  final Idea idea;
  const IdeaCard({required this.idea, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      closedElevation: 0,
      closedColor: Theme.of(context).cardColor,
      closedBuilder: closedBuilder,
      openBuilder: openBuilder,
      onClosed: (quill.Document? textDocument) async {
        if (textDocument == null) {
          throw ArgumentError.notNull("text");
        }
        User user = Provider.of<User>(context, listen: false);
        await FirestoreService.editIdeaText(
          user.uid,
          idea.id,
          textDocument.toPlainText(),
          jsonEncode(textDocument.toDelta().toJson()),
        );
      },
    );
  }

  Widget closedBuilder(BuildContext context, VoidCallback openContainer) {
    return InkWell(
      onTap: openContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: AbsorbPointer(
            child: quill.QuillEditor(
              controller: createQuillController(idea),
              scrollController: ScrollController(),
              scrollable: false,
              focusNode: FocusNode(),
              autoFocus: false,
              readOnly: true,
              expands: false,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget openBuilder(BuildContext context, VoidCallback openContainer) {
    return WritePage(ideaId: idea.id, initialIdea: idea);
  }
}
