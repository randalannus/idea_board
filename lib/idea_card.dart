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
        child: InkWell(
      onTap: () => onTap(context, idea.id),
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
    ));
  }

  void onTap(BuildContext context, int ideaId) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (context) => WritePage(ideaId)));
  }
}
