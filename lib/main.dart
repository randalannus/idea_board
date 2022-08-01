import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:idea_board/firestore_handler.dart';
import 'package:idea_board/legacy/db_handler.dart';
import 'package:flutter/services.dart';
import 'package:idea_board/feed_page.dart';
import 'package:idea_board/legacy/ideas.dart';
import 'package:idea_board/list_page.dart';
import 'package:idea_board/model/idea.dart';
import 'package:idea_board/sign_in_page.dart';
import 'package:idea_board/themes.dart';
import 'package:idea_board/write_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

String fbHost = const String.fromEnvironment("FIREBASE_EMULATOR_HOST");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHandler.initializeDB();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode && fbHost.isNotEmpty) {
    FirebaseAuth.instance.useAuthEmulator(fbHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(fbHost, 8080);
  }
  // Force device orientation to vertical
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IdeasProvider()),
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.userChanges(),
          initialData: FirebaseAuth.instance.currentUser,
        ),
      ],
      child: MaterialApp(
        title: 'Idea Board',
        theme: Themes.mainTheme,
        home: Consumer<User?>(
          builder: (context, user, _) {
            return MyPageTransitionSwitcher(
              transitionType: SharedAxisTransitionType.scaled,
              child: user == null
                  ? const SignInPage()
                  : MultiProvider(
                      providers: [
                        Provider<User>.value(value: user),
                        StreamProvider<List<Idea>>.value(
                          value: FirestoreHandler.ideasListStream(user.uid),
                          initialData: const [],
                        )
                      ],
                      child: const HomePage(),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const feedPageIndex = 0;
  static const listPageIndex = 1;

  int _activePage = feedPageIndex;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ideas"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fabPressed(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomAppBar(),
      body: body(context),
    );
  }

  Widget bottomAppBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              _setPage(feedPageIndex);
              GoogleSignIn().signOut();
              FirebaseAuth.instance.signOut();
            },
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

  void _fabPressed(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    FirestoreHandler.newIdea(user.uid).then((idea) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => WritePage(ideaId: idea.id),
        ),
      );
    });
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
      var newIdea = await FirestoreHandler.newIdea(user.uid);
      await FirestoreHandler.editIdeaText(user.uid, newIdea.id, idea.text);
      if (idea.isArchived) {
        await FirestoreHandler.archiveIdea(user.uid, newIdea.id);
      }
      await FirestoreHandler.setIdeaLastRecommended(
        userId: user.uid,
        ideaId: newIdea.id,
        lastRecommended: idea.lastRecommended,
      );
      // ignore: deprecated_member_use_from_same_package
      await FirestoreHandler.setIdeaCreatedAt(
        userId: user.uid,
        ideaId: newIdea.id,
        createdAt: idea.createdAt,
      );
    }
    await provider.deleteAllIdeas();
  }
}

class MyPageTransitionSwitcher extends PageTransitionSwitcher {
  MyPageTransitionSwitcher({
    required SharedAxisTransitionType transitionType,
    Widget? child,
    bool reverse = false,
    Duration duration = const Duration(milliseconds: 300),
    Key? key,
  }) : super(
          transitionBuilder: (child, animation, secondaryAnimation) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: transitionType,
            child: child,
          ),
          child: child,
          reverse: reverse,
          duration: duration,
          key: key,
        );
}
