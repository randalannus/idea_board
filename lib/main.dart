import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

String fbHost = const String.fromEnvironment("FIREBASE_EMULATOR_HOST");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHandler.initializeDB();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("fbHost: $fbHost");
  if (kDebugMode && fbHost.isNotEmpty) {
    print("here");
    FirebaseAuth.instance.useAuthEmulator(fbHost, 9099);
  }
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
      child: ChangeNotifierProvider<IdeasProvider>(
        create: (_) => IdeasProvider(),
        child: MaterialApp(
          title: 'Idea Board',
          theme: Themes.mainTheme,
          home: const MyHomePage(),
        ),
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

  void _setPage(int pageNumber) {
    setState(() {
      _activePage = pageNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    if (user == null) {
      return const SignInPage();
    }
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
