import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:idea_board/firestore_handler.dart';
import 'package:idea_board/write_page.dart';
import 'package:idea_board/model/idea.dart';
import 'package:provider/provider.dart';

class IdeaCard extends StatelessWidget {
  final Idea idea;
  final EdgeInsetsGeometry padding;

  const IdeaCard(
      {required this.idea, this.padding = const EdgeInsets.all(8.0), Key? key})
      : super(key: key);

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
        User user = Provider.of<User>(context, listen: false);
        if (text == null) {
          throw ArgumentError.notNull("text");
        }
        await FirestoreHandler.editIdeaText(user.uid, idea.id, text);
      },
    );
  }

  Widget closedBuilder(BuildContext context, VoidCallback openContainer) {
    return InkWell(
      onTap: openContainer,
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Text(
            idea.text,
            textAlign: TextAlign.center,
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
