import 'dart:math';

import 'package:flutter/material.dart';
import 'package:idea_board/idea_card.dart';
import 'package:idea_board/ideas.dart';
import 'package:provider/provider.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  static const intMaxValue = 9007199254740991;
  final Map<int, int> indexToId = {};

  @override
  Widget build(BuildContext context) {
    return TikTokStyleFullPageScroller(
        contentSize: intMaxValue,
        builder: (context, index) {
          return Consumer<IdeasProvider>(builder: (context, provider, _) {
            final future = !indexToId.containsKey(index)
                ? provider.selectRandom()
                : provider.getIdea(indexToId[index]!);
            return FutureBuilder<Idea>(
                future: future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }
                  final idea = snapshot.data!;
                  indexToId[index] = idea.id;
                  return IdeaCard(idea: idea);
                });
          });
        });
  }
}
