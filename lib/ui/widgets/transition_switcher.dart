import 'package:animations/animations.dart';

class MyPageTransitionSwitcher extends PageTransitionSwitcher {
  MyPageTransitionSwitcher({
    required SharedAxisTransitionType transitionType,
    super.child,
    super.reverse,
    super.duration,
    super.key,
  }) : super(
          transitionBuilder: (child, animation, secondaryAnimation) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: transitionType,
            child: child,
          ),
        );
}
