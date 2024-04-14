import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:idea_board/legacy/ideas.dart';
import 'package:idea_board/model/idea.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/auth_service.dart';
import 'package:idea_board/service/feed_provider.dart';
import 'package:idea_board/service/firestore_service.dart';
import 'package:idea_board/ui/pages/feed_page.dart';
import 'package:idea_board/ui/pages/list_page.dart';
import 'package:idea_board/ui/pages/write_page.dart';
import 'package:idea_board/ui/widgets/confimation_dialog.dart';
import 'package:idea_board/ui/widgets/transition_switcher.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const feedPageIndex = 0;
  static const listPageIndex = 1;

  int _activePage = listPageIndex;
  FeedProvider? feedProvider;

  void _setPage(int pageNumber) {
    setState(() {
      _activePage = pageNumber;
    });
  }

  @override
  void initState() {
    _tryTransferIdeas(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context, listen: false);
    if (user == null) return const SizedBox.expand();
    return MultiProvider(
      providers: [
        Provider<User>.value(value: user),
        StreamProvider<List<Idea>>.value(
          value: FirestoreService.ideasListStream(user.uid),
          initialData: const [],
          catchError: (context, error) => [],
        ),
        ChangeNotifierProvider<FeedProvider>(create: (context) {
          var ideasStream = FirestoreService.ideasListStream(user.uid);
          return FeedProvider(user, ideasStream);
        })
      ],
      child: Scaffold(
        appBar: topAppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _fabPressed(context),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: bottomAppBar(),
        body: body(context),
      ),
    );
  }

  PreferredSizeWidget topAppBar() {
    return AppBar(
      title: const Text("Ideas"),
      actions: const [MenuButton()],
    );
  }

  Widget bottomAppBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => _setPage(feedPageIndex),
            icon: const Icon(Icons.home_filled),
          ),
          const SizedBox.shrink(),
          IconButton(
            onPressed: () => _setPage(listPageIndex),
            icon: const Icon(Icons.list),
          )
        ],
      ),
    );
  }

  Widget body(BuildContext context) {
    return MyPageTransitionSwitcher(
      reverse: _activePage == feedPageIndex,
      transitionType: SharedAxisTransitionType.horizontal,
      child: pageContent(_activePage),
    );
  }

  Widget pageContent(int pageIndex) {
    if (pageIndex == feedPageIndex) return const FeedPage();
    if (pageIndex == listPageIndex) return const ListPage();
    throw "Invalid page index";
  }

  Future<void> _fabPressed(BuildContext context) async {
    User user = Provider.of<User>(context, listen: false);
    Idea idea = await FirestoreService.newIdea(user.uid);

    if (!mounted) return; // avoid passing BuildContext across sync gaps
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritePage(
          userId: user.uid,
          ideaId: idea.id,
          initialIdea: idea,
        ),
      ),
    );
  }

  /// Script for copying all ideas from the local SQL databse to Firestore.
  /// All ideas are deleted from the SQL database.
  Future<void> _tryTransferIdeas(BuildContext context) async {
    var provider = Provider.of<IdeasProvider>(context, listen: false);
    User user = Provider.of<User>(context, listen: false);
    bool canTransfer = await provider.canTransferIdeas();
    if (!canTransfer) return;

    var ideas = await provider.listIdeas();
    for (var idea in ideas) {
      var newIdea = await FirestoreService.newIdea(user.uid);
      await FirestoreService.editIdeaText(
          user.uid, newIdea.id, idea.plainText, null);
      if (idea.isArchived) {
        await FirestoreService.archiveIdea(user.uid, newIdea.id);
      }
      await FirestoreService.setIdeaLastRecommended(
        userId: user.uid,
        ideaId: newIdea.id,
        lastRecommended: idea.lastRecommended,
      );
      // ignore: deprecated_member_use_from_same_package
      await FirestoreService.setIdeaCreatedAt(
        userId: user.uid,
        ideaId: newIdea.id,
        createdAt: idea.createdAt,
      );
    }
    await provider.deleteAllIdeas();
  }
}

class MenuButton extends StatefulWidget {
  static const signOutValue = "signOut";
  static const deleteAccountValue = "deleteAccount";

  const MenuButton({super.key});

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).iconTheme.color,
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: MenuButton.signOutValue,
          child: Text("Sign out"),
        ),
        PopupMenuItem(
          value: MenuButton.deleteAccountValue,
          child: Text("Delete account"),
        ),
      ],
      onSelected: (value) async {
        if (value == MenuButton.signOutValue) {
          await AuthService.signOut();
        } else if (value == MenuButton.deleteAccountValue) {
          await onDeletePressed(context);
        }
      },
    );
  }

  Future<void> onDeletePressed(BuildContext context) async {
    bool userAccepted = await showConfirmationDialog(
      context: context,
      dialog: const ConfirmationDialog(
        title: "Delete account",
        content: "Are you sure you want to delete your account?"
            " This action is irreversible.",
        confirmButton: "Delete",
      ),
    );

    if (!userAccepted) return;
    try {
      await AuthService.deleteCurrentUser();
    } on AuthenticationRequiredException {
      if (!mounted) return;
      await _promptSignOut(context);
    }
  }

  Future<void> _promptSignOut(BuildContext context) async {
    bool userAccepted = await showConfirmationDialog(
      context: context,
      dialog: const ConfirmationDialog(
        title: "Error",
        content: "Please sign in again to delete your account",
        confirmButton: "Go to sign in",
      ),
    );
    if (userAccepted) await AuthService.signOut();
  }
}
