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
          future: provider.listIdeas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            }
            final ideas = snapshot.data!;
            return Scroller(ideas: ideas);
          }),
    );
  }
}

class Scroller extends StatefulWidget {
  const Scroller({
    Key? key,
    required this.ideas,
  }) : super(key: key);

  final List<Idea> ideas;

  @override
  State<Scroller> createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  static const intMaxValue = 9007199254740991;
  final Map<int, int> indexToId = {};
  final Random rng = Random();

  @override
  Widget build(BuildContext context) {
    return TikTokStyleFullPageScroller(
        contentSize: intMaxValue,
        builder: (context, index) {
          Idea idea = indexToId.containsKey(index)
              ? findIdea(indexToId[index]!)
              : selectRandomIdea();
          indexToId[index] = idea.id;
          return IdeaCard(idea: idea);
        });
  }

  Idea findIdea(int id) {
    return widget.ideas.firstWhere((idea) => idea.id == id);
  }

  Idea selectRandomIdea() {
    return widget.ideas[rng.nextInt(widget.ideas.length)];
  }
}
