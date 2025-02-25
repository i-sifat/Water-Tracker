import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/num_extension.dart';

class HydrationQuantityText extends StatelessWidget {
  const HydrationQuantityText(this.milliliters, {super.key});
  final int milliliters;

  @override
  Widget build(BuildContext context) {
    return Text(
      milliliters.asMilliliters(),
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}
