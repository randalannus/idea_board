import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:idea_board/legacy/ideas.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/auth_service.dart';
import 'package:idea_board/themes.dart';
import 'package:idea_board/ui/pages/home_page.dart';
import 'package:idea_board/ui/pages/sign_in_page.dart';
import 'package:idea_board/ui/widgets/transition_switcher.dart';
import 'package:provider/provider.dart';

class IdeaBoardApp extends StatelessWidget {
  const IdeaBoardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IdeasProvider()),
        StreamProvider<User?>.value(
          value: AuthService.userChanges(),
          initialData: AuthService.currentUser,
        ),
      ],
      child: MaterialApp(
        title: 'Idea Board',
        theme: Themes.mainTheme,
        home: Consumer<User?>(
          builder: (context, user, _) {
            return MyPageTransitionSwitcher(
              transitionType: SharedAxisTransitionType.scaled,
              child: user == null ? const SignInPage() : const HomePage(),
            );
          },
        ),
      ),
    );
  }
}
