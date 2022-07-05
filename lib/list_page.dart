import 'package:flutter/material.dart';
import 'package:idea_board/idea_card.dart';
import 'package:idea_board/ideas.dart';
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
                  return const SizedBox.shrink();
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
    cards.insert(0, IdeaCard(idea: idea));
  }
  return cards;
}
