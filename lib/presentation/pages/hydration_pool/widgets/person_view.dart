import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/assets.dart';

class PersonView extends StatelessWidget {
  final Animation<double> animation;

  const PersonView({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 4 * animation.value),
          child: child,
        );
      },
      child: Image.asset(
        Assets.person,
        height: 300,
      ),
    );
  }
}