import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idea_board/db_handler.dart';
import 'package:idea_board/feed_page.dart';
import 'package:idea_board/ideas.dart';
import 'package:idea_board/list_page.dart';
import 'package:idea_board/sign_in_page.dart';
import 'package:idea_board/themes.dart';
import 'package:idea_board/write_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHandler.initializeDB();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Force device orientation to vertical
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IdeasProvider>(
      create: (_) => IdeasProvider(),
      child: MaterialApp(
        title: 'Idea Board',
        theme: Themes.mainTheme,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            return MyPageTransitionSwitcher(
              transitionType: SharedAxisTransitionType.scaled,
              child: !snapshot.hasData || snapshot.data == null
                  ? const SignInPage()
                  : const HomePage(),
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
  int _activePage = 0;

  void _setPage(int pageNumber) {
    setState(() {
      _activePage = pageNumber;
    });
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () => _setPage(0),
              icon: const Icon(Icons.home_filled),
            ),
            const SizedBox.shrink(),
            IconButton(
              onPressed: () => _setPage(1),
              icon: const Icon(Icons.list),
            )
          ],
        ),
      ),
      body: MyPageTransitionSwitcher(
        reverse: _activePage == 0,
        transitionType: SharedAxisTransitionType.horizontal,
        child: pageContent(_activePage),
      ),
    );
  }
}

Widget pageContent(int pageIndex) {
  if (pageIndex == 0) return const FeedPage();
  if (pageIndex == 1) return const ListPage();
  throw "Invalid page index";
}

void _fabPressed(BuildContext context) {
  final provider = Provider.of<IdeasProvider>(context, listen: false);
  provider.newIdea().then((idea) {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (context) => WritePage(ideaId: idea.id)));
  });
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
