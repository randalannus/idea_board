import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:idea_board/write_page.dart';
import 'package:provider/provider.dart';

class ListPage extends StatelessWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IdeasProvider>(builder: (context, ideasProvider, _) {
      return SizedBox.expand(
          child: FutureBuilder<List<Idea>>(
              future: ideasProvider.listIdeas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                    children: ideasToCards(context, snapshot.data!));
              }));
    });
  }
}

List<Widget> ideasToCards(BuildContext context, List<Idea> ideas) {
  final cards = <Widget>[];
  for (var idea in ideas) {
    cards.insert(0, IdeaCard(idea));
  }
  return cards;
}

class IdeaCard extends StatelessWidget {
  final Idea idea;

  const IdeaCard(this.idea, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      onTap: () => onTap(context, idea.id),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Text(
            idea.text,
            textAlign: TextAlign.left,
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
