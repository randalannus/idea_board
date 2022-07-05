import 'package:flutter/material.dart';
import 'package:idea_board/db_handler.dart';
import 'package:idea_board/feed_page.dart';
import 'package:idea_board/ideas.dart';
import 'package:idea_board/list_page.dart';
import 'package:idea_board/themes.dart';
import 'package:idea_board/write_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHandler.initializeDB();
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
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (context) => WritePage(idea.id)));
  });
}