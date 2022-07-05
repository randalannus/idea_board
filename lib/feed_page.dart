import 'dart:math';

import 'package:flutter/material.dart';
import 'package:idea_board/idea_card.dart';
import 'package:idea_board/ideas.dart';
import 'package:provider/provider.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IdeasProvider>(
      builder: (context, provider, _) => FutureBuilder<List<Idea>>(
          future: provider.listIdeas(includeArchived: true),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            }
            final ideas = snapshot.data!;
            if (ideas.isEmpty) {
              return const Center(child: Text("Press + to create an idea"));
            }

            return Scroller(ideas: ideas);
          }),
    );
  }
}

class Scroller extends StatefulWidget {
  Scroller({
    Key? key,
    required this.ideas,
  }) : super(key: key) {
    unarchivedIdeas = ideas.where((idea) => !idea.isArchived).toList();
  }

  final List<Idea> ideas;
  late final List<Idea> unarchivedIdeas;

  @override
  State<Scroller> createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  static const intMaxValue = 9007199254740991;
  final List<int> historicIds = [];
  final Random rng = Random();

  @override
  Widget build(BuildContext context) {
    return TikTokStyleFullPageScroller(
        contentSize: intMaxValue,
        builder: (context, index) {
          Idea? idea = historicIds.length > index
              ? findIdea(historicIds[index])
              : selectRandomIdea();
          if (idea == null) {
            return const Center(
              child: Text("Press + to create an idea"),
            );
          }
          if (historicIds.length > index) {
            historicIds[index] = idea.id;
          } else {
            historicIds.add(idea.id);
          }
          return IdeaCard(idea: idea);
        });
  }

  /// Finds the idea with the specified id.
  /// If there is no idea with the specified id, then null is returned.
  Idea? findIdea(int id) {
    try {
      return widget.ideas.firstWhere((idea) => idea.id == id);
    } on StateError {
      return null;
    }
  }

  /// Selects a random idea.
  /// Id the list of ideas is empty, then null is returned.
  Idea? selectRandomIdea() {
    try {
      return widget.unarchivedIdeas[rng.nextInt(widget.unarchivedIdeas.length)];
    } on RangeError {
      return null;
    }
  }
}
