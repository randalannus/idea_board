import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
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
      onClosed: (String? text) async {
        print(text);
        if (text == null) {
          throw ArgumentError.notNull("text");
        }
        User user = Provider.of<User>(context, listen: false);
        print("editing");
        await FirestoreService.editIdeaText(user.uid, idea.id, text);
        print("edited");
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
          child: Text(
            idea.text,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ),
    );
  }

  Widget openBuilder(BuildContext context, VoidCallback openContainer) {
    return WritePage(ideaId: idea.id, initialText: idea.text);
  }
}
