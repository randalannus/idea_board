import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:idea_board/write_page.dart';

class IdeaCard extends StatelessWidget {
  final Idea idea;
  final EdgeInsetsGeometry padding;

  const IdeaCard(
      {required this.idea, this.padding = const EdgeInsets.all(8.0), Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: OpenContainer(
        closedBuilder: closedBuilder,
        openBuilder: openBuilder,
      ),
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
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ),
    );
  }

  Widget openBuilder(BuildContext context, VoidCallback openContainer) {
    return WritePage(idea.id);
  }
}
