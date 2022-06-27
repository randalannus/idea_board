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
    cards.insert(
        0,
        Card(
            child: InkWell(
          onTap: () => onTap(context, idea.id),
          child: SizedBox(
              width: 300,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  idea.text,
                  textAlign: TextAlign.left,
                ),
              )),
        )));
  }
  return cards;
}

void onTap(BuildContext context, int ideaId) {
  Navigator.push(context,
      MaterialPageRoute<void>(builder: (context) => WritePage(ideaId)));
}
