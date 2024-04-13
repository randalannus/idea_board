import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:idea_board/model/user.dart';
import 'package:idea_board/ui/pages/write_page.dart';
import 'package:idea_board/model/idea.dart';
import 'package:provider/provider.dart';

class IdeaCard extends StatelessWidget {
  final Idea idea;
  const IdeaCard({required this.idea, super.key});

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
              scrollController: ScrollController(),
              focusNode: FocusNode(),
              configurations: quill.QuillEditorConfigurations(
                controller: createQuillController(idea),
                scrollable: false,
                autoFocus: false,
                readOnly: true,
                expands: false,
                padding: EdgeInsets.zero,
                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                    Theme.of(context).textTheme.bodyText2!,
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget openBuilder(BuildContext context, VoidCallback openContainer) {
    User user = Provider.of<User>(context, listen: false);
    return WritePage(
      userId: user.uid,
      ideaId: idea.id,
      initialIdea: idea,
    );
  }
}
