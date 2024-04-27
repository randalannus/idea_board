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
import 'package:idea_board/ui/pages/recording_page.dart';
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
        Provider<IdeasService>.value(value: IdeasService(user: user)),
      ],
      child: MultiProvider(
        providers: [
          Provider<ChatService>(create: (_) => ChatService(user: user)),
          StreamProvider<List<Idea>>(
            create: (context) => Provider.of<IdeasService>(
              context,
              listen: false,
            ).ideasListStream(),
            initialData: const [],
            catchError: (context, error) => [],
          ),
          ChangeNotifierProvider(create: (context) {
            return FeedProvider(
                user,
                Provider.of<IdeasService>(
                  context,
                  listen: false,
                ));
          }),
        ],
        child: Scaffold(
          endDrawer: const SettingsDrawer(),
          drawerEdgeDragWidth: 0,
          bottomNavigationBar: bottomAppBar(),
          body: SafeArea(child: body(context)),
        ),
      ),
    );
  }

  Widget bottomAppBar() {
    return BottomAppBar(
      child: Builder(builder: (context) {
        return Row(
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
            InkWell(
              onLongPress: () => _openRecordingPage(context),
              child: FloatingActionButton(
                onPressed: () => _fabPressed(context),
                child: const Icon(Icons.add),
              ),
            ),
            IconButton(
              onPressed: () => _setPage(chatPageIndex),
              icon: const Icon(Icons.chat),
            ),
            IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.settings),
            )
          ],
        );
      }),
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
    final ideasService = Provider.of<IdeasService>(context, listen: false);
    Idea idea = await ideasService.newIdea();

    if (!mounted) return; // avoid passing BuildContext across sync gaps
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritePage(
          ideaId: idea.id,
          initialIdea: idea,
          ideasService: ideasService,
        ),
      ),
    );
  }

  Future<void> _openRecordingPage(BuildContext context) async {
    final ideasService = Provider.of<IdeasService>(context, listen: false);
    final user = Provider.of<User>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            Provider.value(value: ideasService),
            Provider.value(value: user),
          ],
          child: const RecordingPage(),
        ),
      ),
    );
  }
}

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            const ListTile(
              title: Text("Sign out"),
              leading: Icon(Icons.logout),
              onTap: AuthService.signOut,
            ),
            ListTile(
              title: const Text("Delete account"),
              onTap: () => onDeletePressed(context),
              leading: const Icon(Icons.delete_forever),
              iconColor: Theme.of(context).colorScheme.error,
              textColor: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
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
