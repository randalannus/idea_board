import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/ideas_service.dart';
import 'package:idea_board/model/idea.dart';

class FeedProvider with ChangeNotifier {
  final Random rng = Random();

  final User user;

  /// List of all ideas for the user.
  final Stream<List<Idea>> ideasStream;
  late final StreamSubscription<List<Idea>> _ideasSub;

  FeedProvider(this.user, this.ideasStream) {
    _ideasSub = ideasStream.listen((newIdeas) {
      _updateIdeas(newIdeas);
      if (feed.length < 3 && canRecommend) {
        recommendIdea(count: 3);
      }
    });
  }

  /// All ideas that the user has
  List<Idea> _ideas = [];

  /// Subset of [_ideas] that are not archived.
  /// This is created lazily.
  /// The feed only recommends ideas from this list.
  List<Idea>? _unarchivedIdeasMemory;
  List<Idea> get _unarchivedIdeas {
    if (_unarchivedIdeasMemory != null) return _unarchivedIdeasMemory!;
    _unarchivedIdeasMemory = _ideas.where((idea) => !idea.isArchived).toList();
    return _unarchivedIdeasMemory!;
  }

  /// Returns true if and only if there are ideas that can be recommended.
  bool get canRecommend => _unarchivedIdeas.isNotEmpty;

  /// Ideas that have been recommended whether the user has seen them (the user
  /// might not have scrolled far enough.)
  final List<String> feed = [];

  /// Which idea is the user currently looking at.
  int _currentPos = 0;
  int get currentPos => _currentPos;
  set currentPos(int position) {
    _currentPos = position;
    notifyListeners();
  }

  /// The biggest position the user has scrolled to.
  /// This is tracked to not recommend ideas that have just been recommended.
  int _lastSeenPos = 0;
  int get lastSeenPos => _lastSeenPos;

  @override
  void dispose() {
    _ideasSub.cancel();
    super.dispose();
  }

  /// Set which feed position the user has scrolled to.
  Future<void> updateLastSeenPos(int position) {
    List<Future> futures = [];
    for (var i = lastSeenPos + 1; i <= position; i++) {
      futures.add(_updateRecomendationIndex(i));
    }
    _lastSeenPos = position;
    return Future.wait(futures);
  }

  /// Call this when any idea changes or a new one is created
  void _updateIdeas(List<Idea> newIdeas) {
    _ideas = newIdeas;
    _unarchivedIdeasMemory = null;
  }

  /// Add [count] ideas to the feed.
  void recommendIdea({int count = 1}) {
    if (count <= 0) return;
    if (!canRecommend) {
      throw StateError("[recommendIdea] called when [canRecommend] is false");
    }
    int lastIndex = _biggestRecommendationIndex();
    List<int> weights = _calcWeights(_unarchivedIdeas, lastIndex);
    for (var i = 0; i < count; i++) {
      Idea idea = _randomChoice(_unarchivedIdeas, weights);
      int index = _unarchivedIdeas.indexOf(idea);
      weights[index] = 0;
      feed.add(idea.id);
    }
    notifyListeners();
  }

  /// Update the lastRecommended field on Firestore to prioritize ideas that
  /// have not beed recommended recently.
  Future<void> _updateRecomendationIndex(int position) {
    return IdeasService.setIdeaLastRecommended(
      userId: user.uid,
      ideaId: feed[position],
      lastRecommended: _biggestRecommendationIndex() + 1,
    );
  }

  /// Finds the biggest value of the lastRecommended field from unarchived ideas
  int _biggestRecommendationIndex() {
    return _unarchivedIdeas.fold<int>(
        0, (prevValue, idea) => max(prevValue, idea.lastRecommended ?? 0));
  }

  /// Calculates weights for a distribution prioritizing ideas that have not
  /// been recommended recently.
  List<int> _calcWeights(List<Idea> ideas, int lastIndex) {
    int maxWeight = ideas.length * 2;
    List<int> weights = [];
    for (var idea in ideas) {
      if (_isUpcoming(idea.id)) {
        weights.add(0);
      } else {
        int lastRecommended = idea.lastRecommended ?? 0;
        weights.add(min(lastIndex - lastRecommended, maxWeight));
      }
    }
    return weights;
  }

  /// Returns true if and only if the idea has been recommended recently and the
  /// user has not yet scrolled to the idea.
  bool _isUpcoming(String ideaId) {
    for (var i = lastSeenPos + 1; i < feed.length; i++) {
      if (feed[i] == ideaId) return true;
    }
    return false;
  }

  /// Chooses a random idea from the list with provided non-negative weights.
  /// If all weights are equal, then a uniform distribution is used.
  Idea _randomChoice(List<Idea> ideas, List<int> weights) {
    int sumWeights = weights.fold(0, (prevValue, weight) => prevValue + weight);
    if (sumWeights == 0) {
      return ideas[rng.nextInt(ideas.length)];
    }
    int randomValue = rng.nextInt(sumWeights) + 1;
    int sumPreviousWeights = 0;
    for (var i = 0; i < ideas.length; i++) {
      sumPreviousWeights += weights[i];
      if (randomValue <= sumPreviousWeights) {
        return ideas[i];
      }
    }
    return ideas.last;
  }
}
