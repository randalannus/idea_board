import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:idea_board/model/idea.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/auth_service.dart';
import 'package:idea_board/service/chat_service.dart';
import 'package:idea_board/service/feed_provider.dart';
import 'package:idea_board/service/ideas_service.dart';
import 'package:idea_board/ui/pages/chat_page.dart';
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
  static const chatPageIndex = 2;

  int _activePage = listPageIndex;
  int _prevPage = listPageIndex;
  FeedProvider? feedProvider;

  void _setPage(int pageNumber) {
    setState(() {
      _prevPage = _activePage;
      _activePage = pageNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context, listen: false);
    if (user == null) return const SizedBox.expand();
    return MultiProvider(
      providers: [
        Provider<User>.value(value: user),
        Provider<ChatService>(create: ((_) => ChatService(user: user))),
        StreamProvider<List<Idea>>.value(
          value: IdeasService.ideasListStream(user.uid),
          initialData: const [],
          catchError: (context, error) => [],
        ),
        ChangeNotifierProvider<FeedProvider>(create: (context) {
          var ideasStream = IdeasService.ideasListStream(user.uid);
          return FeedProvider(user, ideasStream);
        })
      ],
      child: Scaffold(
        appBar: topAppBar(),
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
          IconButton(
            onPressed: () => _setPage(listPageIndex),
            icon: const Icon(Icons.list),
          ),
          IconButton(
            onPressed: () => _setPage(chatPageIndex),
            icon: const Icon(Icons.chat),
          ),
          FloatingActionButton(
            onPressed: () => _fabPressed(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget body(BuildContext context) {
    return MyPageTransitionSwitcher(
      reverse: _activePage < _prevPage,
      transitionType: SharedAxisTransitionType.horizontal,
      child: pageContent(_activePage),
    );
  }

  Widget pageContent(int pageIndex) {
    if (pageIndex == feedPageIndex) return const FeedPage();
    if (pageIndex == listPageIndex) return const ListPage();
    if (pageIndex == chatPageIndex) return const ChatPage();
    throw "Invalid page index";
  }

  Future<void> _fabPressed(BuildContext context) async {
    User user = Provider.of<User>(context, listen: false);
    Idea idea = await IdeasService.newIdea(user.uid);

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
