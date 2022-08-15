import 'package:flutter/material.dart';
import 'package:idea_board/ui/widgets/idea_card.dart';
import 'package:provider/provider.dart';
import 'package:idea_board/model/idea.dart';

class ListPage extends StatelessWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<List<Idea>>(builder: (context, ideas, _) {
      List<Idea> unarchivedIdeas =
          ideas.where((idea) => !idea.isArchived).toList();
      if (unarchivedIdeas.isEmpty) {
        return const Center(
          child: Text("Press + to create an idea"),
        );
      }
      return ideasListView(unarchivedIdeas);
    });
  }

  Widget ideasListView(List<Idea> unarchivedIdeas) {
    const double sepHeight = 8;
    return Scrollbar(
      radius: const Radius.circular(20),
      child: ListView.separated(
        key: const PageStorageKey("ideasList"),
        itemCount: unarchivedIdeas.length +
            2, // Add separators to the beginning and end
        itemBuilder: (context, index) {
          if (index == 0 || index == unarchivedIdeas.length + 1) {
            return const SizedBox();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IdeaCard(idea: unarchivedIdeas[index - 1]),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: sepHeight),
      ),
    );
  }
}
