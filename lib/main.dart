import 'package:flutter/material.dart';
import 'package:idea_board/ideas.dart';
import 'package:idea_board/list_page.dart';
import 'package:idea_board/write_page.dart';
import 'package:provider/provider.dart';

void main() {
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
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
          title: const Text("Idea Board"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _fabPressed(context),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Write"),
          ],
          currentIndex: _activePage,
          onTap: _setPage,
        ),
        body: Center(child: pageContent(_activePage)));
  }
}

Widget pageContent(int pageIndex) {
  if (pageIndex == 0) return const ListPage();
  if (pageIndex == 1) return const ListPage();
  throw "Invalid page index";
}

void _fabPressed(BuildContext context) {
  int id = Provider.of<IdeasProvider>(context, listen: false).newIdea().id;
  Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Idea"),
      ),
      body: Center(child: WritePage(id)),
    );
  }));
}
