import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/num_extension.dart';

class HydrationQuantityText extends StatelessWidget {
  final int milliliters;

  const HydrationQuantityText(this.milliliters, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      milliliters.asMilliliters(),
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}