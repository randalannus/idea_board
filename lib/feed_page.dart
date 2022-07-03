import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:provider/provider.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Idea>>(
        future: Provider.of<IdeasProvider>(context, listen: false).listIdeas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final ideas = snapshot.data!;
          ideas.shuffle();
          return TikTokStyleFullPageScroller(
              contentSize: ideas.length,
              builder: (context, index) {
                return Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(ideas[index].text),
                );
              });
        });
  }
}
