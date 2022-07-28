import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _activePage = 0;

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        //Send to auth screen
        _setPage(2);
      } else {
        _setPage(0);
      }
    });
  }

  void _setPage(int pageNumber) {
    setState(() {
      if (FirebaseAuth.instance.currentUser == null && pageNumber != 2) {
        return;
      }
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
                  icon: const Icon(Icons.home_filled)),
              const SizedBox.shrink(),
              IconButton(
                  onPressed: () => _setPage(1), icon: const Icon(Icons.list))
            ],
          ),
        ),
        body: Center(child: pageContent(_activePage)));
  }
}

Widget pageContent(int pageIndex) {
  if (pageIndex == 0) return const FeedPage();
  if (pageIndex == 1) return const ListPage();
  if (pageIndex == 2) return const SignInPage();
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
