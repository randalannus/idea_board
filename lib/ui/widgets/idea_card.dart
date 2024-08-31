import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/ideas_service.dart';
import 'package:idea_board/ui/pages/write_page.dart';
import 'package:idea_board/model/idea.dart';
import 'package:provider/provider.dart';

class IdeaCard extends StatelessWidget {
  final Idea idea;
  final double maxHeight;

  const IdeaCard({
    required this.idea,
    this.maxHeight = double.infinity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ideasService = Provider.of<IdeasService>(context, listen: false);
    final user = Provider.of<User>(context, listen: false);
    final theme = Theme.of(context);
    return OpenContainer(
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      closedElevation: 0,
      tappable: !idea.isProcessingAudio,
      closedBuilder: closedBuilder,
      openBuilder: (context, _) => MultiProvider(
        providers: [
          Provider.value(value: ideasService),
          Provider.value(value: user),
        ],
        child: openBuilder(context),
      ),
    );
  }

  Widget closedBuilder(BuildContext context, VoidCallback openContainer) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: !idea.isProcessingAudio ? openContainer : null,
      child: Card.outlined(
        margin: const EdgeInsets.all(0),
        color: idea.isProcessingAudio ? theme.highlightColor : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 50,
              maxHeight: maxHeight,
            ),
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
                      Theme.of(context).textTheme.bodyMedium!,
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
      ),
    );
  }

  Widget openBuilder(BuildContext context) {
    return WritePage(
      ideaId: idea.id,
      initialIdea: idea,
    );
  }
}
