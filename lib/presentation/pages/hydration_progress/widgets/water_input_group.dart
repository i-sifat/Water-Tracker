import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/resources/app_symbols.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_event.dart';

class WaterInputGroup extends StatelessWidget {
  const WaterInputGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _WaterInputButton(
            icon: AppSymbols.water_glass,
            milliliters: 250,
          ),
          _WaterInputButton(
            icon: AppSymbols.coffee_cup,
            milliliters: 330,
          ),
          _WaterInputButton(
            icon: AppSymbols.jug,
            milliliters: 500,
          ),
        ],
      ),
    );
  }
}

class _WaterInputButton extends StatelessWidget {
  const _WaterInputButton({
    required this.icon,
    required this.milliliters,
  });
  final IconData icon;
  final int milliliters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.unselectedWidgetColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.read<WaterBloc>().add(DrinkWater(milliliters)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 32,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }
}
