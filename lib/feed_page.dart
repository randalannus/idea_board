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
          Idea? idea;
          if (historicIds.length > index) {
            idea = findIdea(historicIds[index]);
            historicIds[index] = idea.id;
          } else {
            int lastIndex = lastRecommendationIndex();
            ;
            idea = recommendIdea(lastIndex);
            historicIds.add(idea.id);
            Provider.of<IdeasProvider>(context)
                .setLastRecommended(idea.id, lastIndex + 1);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: IdeaCard(idea: idea),
          );
        });
  }

  /// Finds the idea with the specified id.
  Idea findIdea(int id) {
    return widget.ideas.firstWhere((idea) => idea.id == id);
  }

  /// Selects a random idea.
  Idea selectRandomIdea() {
    final ideas = widget.unarchivedIdeas;
    return ideas[rng.nextInt(ideas.length)];
  }

  Idea randomChoice(List<Idea> ideas, List<int> weights) {
    int sum = weights.fold(0, (prevValue, weight) => prevValue + weight);
    int randomValue = rng.nextInt(sum) + 1;
    int sum2 = 0;
    for (var i = 0; i < ideas.length; i++) {
      sum2 += weights[i];
      if (randomValue <= sum2) {
        return ideas[i];
      }
    }
    return ideas.last;
  }

  int lastRecommendationIndex() {
    return widget.unarchivedIdeas.fold(
        -1, (prevValue, idea) => max(prevValue, idea.lastRecommended ?? -1));
  }

  Idea recommendIdea(int lastIndex) {
    final ideas = widget.unarchivedIdeas;
    final weights = calcWeights(ideas, lastIndex);
    return randomChoice(ideas, weights);
  }

  List<int> calcWeights(List<Idea> ideas, int lastIndex) {
    int maxWeight = ideas.length * 2;
    List<int> weights = [];
    for (var idea in ideas) {
      if (idea.lastRecommended == null) {
        weights.add(maxWeight);
      } else {
        weights.add(min(lastIndex - idea.lastRecommended!, maxWeight));
      }
    }
    return weights;
  }
}
