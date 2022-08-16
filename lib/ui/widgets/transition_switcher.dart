import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

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
