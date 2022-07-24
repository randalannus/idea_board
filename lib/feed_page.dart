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
              bool hasUnarchived = ideas.any((idea) => !idea.isArchived);
              if (!hasUnarchived) {
                return const Center(child: Text("Press + to create an idea"));
              }
              return Feed(ideas: ideas);
            }));
  }
}

class Feed extends StatefulWidget {
  final List<Idea> ideas;
  const Feed({required this.ideas, Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  static const intMaxValue = 9007199254740991;
  final Random rng = Random();

  List<Idea>? ideas;
  List<Idea>? unarchivedIdeas;

  /// Ids of ideas that appear in the feed
  final List<int> feedIds = [];
  final Controller controller = Controller();
  late final IdeasProvider provider;

  @override
  void initState() {
    ideas = widget.ideas;
    unarchivedIdeas = findUnarchived(ideas!);
    initFeed();

    provider = Provider.of<IdeasProvider>(context, listen: false);
    provider.addListener(_providerListener);
    controller.addListener(_controllerListener);

    super.initState();
  }

  @override
  void dispose() {
    provider.removeListener(_providerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TikTokStyleFullPageScroller(
        contentSize: intMaxValue,
        controller: controller,
        builder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: IdeaCard(idea: findIdea(feedIds[index])),
            ));
  }

  List<Idea> findUnarchived(List<Idea> ideas) {
    return ideas.where((idea) => !idea.isArchived).toList();
  }

  /// Loads the initial 3 ideas to the feed.
  void initFeed() {
    final lastIndex = lastRecommendationIndex();
    final weights = calcWeights(unarchivedIdeas!, lastIndex);
    for (var i = 0; i < 3; i++) {
      final idea = randomChoice(unarchivedIdeas!, weights);
      int index = unarchivedIdeas!.indexOf(idea);
      weights[index] = 0;
      feedIds.add(idea.id);
      Provider.of<IdeasProvider>(context, listen: false)
          .setLastRecommended(idea.id, lastIndex + 1 + i);
    }
  }

  void _providerListener() {
    provider.listIdeas(includeArchived: true).then(_updateIdeas);
  }

  void _updateIdeas(List<Idea> newIdeas) {
    setState(() {
      ideas = newIdeas;
      unarchivedIdeas = findUnarchived(ideas!);
    });
  }

  /// Loads new ideas if the feed is starting to run out.
  void _controllerListener(ScrollEvent event) {
    if (event.pageNo == null || event.pageNo! < feedIds.length - 1) return;

    final lastIndex = lastRecommendationIndex();
    final weights = calcWeights(unarchivedIdeas!, lastIndex);
    final idea = randomChoice(unarchivedIdeas!, weights);
    setState(() => feedIds.add(idea.id));
    Provider.of<IdeasProvider>(context, listen: false)
        .setLastRecommended(idea.id, lastIndex + 1);
  }

  /// Finds the idea with the specified id.
  Idea findIdea(int id) {
    return ideas!.firstWhere((idea) => idea.id == id);
  }

  /// Finds the biggest value of the lastRecommended field from unarchived ideas
  int lastRecommendationIndex() {
    return unarchivedIdeas!.fold(
        0, (prevValue, idea) => max(prevValue, idea.lastRecommended ?? 0));
  }

  /// Calculates weights for a distribution prioritizing ideas that have not
  /// been recommended recently.
  List<int> calcWeights(List<Idea> ideas, int lastIndex) {
    int maxWeight = ideas.length * 2;
    List<int> weights = [];
    for (var idea in ideas) {
      int lastRecommended = idea.lastRecommended ?? 0;
      weights.add(min(lastIndex - lastRecommended, maxWeight));
    }
    return weights;
  }

  /// Chooses a random idea from the list with provided non-negative weights.
  /// If all weights are equal, then a uniform distribution is used.
  Idea randomChoice(List<Idea> ideas, List<int> weights) {
    int sum = weights.fold(0, (prevValue, weight) => prevValue + weight);
    if (sum == 0) {
      return ideas[rng.nextInt(ideas.length)];
    }
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
}
