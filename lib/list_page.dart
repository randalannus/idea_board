import 'package:flutter/material.dart';
import 'package:idea_board/idea_card.dart';
import 'package:provider/provider.dart';
import 'package:idea_board/model/idea.dart';

class ListPage extends StatelessWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<List<Idea>>(builder: (context, ideas, _) {
      if (ideas.isEmpty) {
        return const Center(
          child: Text("Press + to create an idea"),
        );
      }
      return ideasListView(ideas);
    });
  }

  Widget ideasListView(List<Idea> ideas) {
    const double sepHeight = 8;
    return ListView.separated(
      key: const PageStorageKey("ideasList"),
      itemCount: ideas.length + 2, // Add separators to the beginning and end
      itemBuilder: (context, index) {
        if (index == 0 || index == ideas.length + 1) {
          return const SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IdeaCard(idea: ideas[index - 1]),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: sepHeight),
    );
  }
}
