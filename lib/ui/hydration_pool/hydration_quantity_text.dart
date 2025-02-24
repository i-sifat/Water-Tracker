import 'package:flutter/material.dart';
import 'package:watertracker/util/num_extension.dart';

class HydrationQuantityText extends StatelessWidget {
  final int quantity;

  const HydrationQuantityText(this.quantity, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.loose(Size.fromWidth(400)),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.decelerate,
        tween: Tween(begin: 0.0, end: quantity.toDouble()),
        builder: (context, value, child) {
          return Text(
            value.asMilliliters(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          );
        },
      ),
    );
  }
}