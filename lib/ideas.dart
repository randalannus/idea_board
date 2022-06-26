import 'package:flutter/cupertino.dart';

class IdeasProvider with ChangeNotifier {
  late final List<Idea> _ideas = [];
  List<Idea> get ideas => _ideas;

  Idea getIdea(int id) {
    return ideas.firstWhere((element) => element.id == id);
  }

  Idea newIdea() {
    final idea = Idea(ideas.length, "");
    ideas.add(idea);
    notifyListeners();
    return idea;
  }

  Idea edit(int id, String text) {
    ideas[id] = Idea(id, text);
    notifyListeners();
    return ideas[id];
  }

  IdeasProvider() {
    for (var i = 0; i < 10; i++) {
      ideas.add(Idea(i, "See on idee number $i"));
    }
  }
}

class Idea {
  final int id;
  final String text;

  const Idea(this.id, this.text);
}
