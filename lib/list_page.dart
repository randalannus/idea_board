import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:provider/provider.dart';

class ListPage extends StatelessWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IdeasProvider>(builder: (context, ideasProvider, _) {
      return SizedBox.expand(
          child: ListView(children: ideasToCards(ideasProvider.ideas)));
    });
  }
}

List<Widget> ideasToCards(List<Idea> ideas) {
  final cards = <Widget>[];
  for (var idea in ideas) {
    cards.insert(
        0,
        Card(
            child: SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text(idea.text)),
        )));
  }
  return cards;
}
