import 'dart:math';

import 'package:flutter/material.dart';
import 'package:idea_board/ui/widgets/idea_card.dart';
import 'package:idea_board/service/feed_provider.dart';
import 'package:idea_board/model/idea.dart';
import 'package:provider/provider.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  static const intMaxValue = 9007199254740991;
  final Controller controller = Controller();

  @override
  void initState() {
    controller.addListener(_controllerListener);

    // Jump to last feed position when the scroller widget has been built
    var feedProvider = Provider.of<FeedProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.jumpToPosition(feedProvider.currentPos);
    });
    // TODO: Close sub
    feedProvider.currentPosChanges.listen((event) {
      controller.jumpToPosition(event);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var ideas = Provider.of<List<Idea>>(context);
    var feedProvider = Provider.of<FeedProvider>(context);
    if (ideas.isEmpty) {
      return const Center(child: Text("Press + to create an idea"));
    } else if (feedProvider.feed.isEmpty) {
      return const SizedBox();
    }
    return TikTokStyleFullPageScroller(
      contentSize: intMaxValue,
      controller: controller,
      builder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: IdeaCard(
            idea: _findIdea(ideas, feedProvider.feed[index]),
          ),
        );
      },
    );
  }

  Idea _findIdea(List<Idea> ideas, String ideaId) {
    return ideas.firstWhere((idea) => idea.id == ideaId);
  }

  void _controllerListener(ScrollEvent event) {
    if (event.pageNo == null || event.success != ScrollSuccess.SUCCESS) return;
    var feedProvider = Provider.of<FeedProvider>(context, listen: false);
    // Make sure the feed has at least 2 ideas recommended after the current one.
    feedProvider.currentPos = event.pageNo!;
    feedProvider.updateLastSeenPos(event.pageNo!).then((value) {
      feedProvider.recommendIdea(
        count: max(0, event.pageNo! - (feedProvider.feed.length - 1) + 2),
      );
    });
  }
}
