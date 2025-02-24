import 'package:flutter/material.dart';
import 'package:watertracker/core/resources/app_symbols.dart';

class WaterInput {
  final int milliliters;
  final IconData icon;
  final Color backgroundColor;

  const WaterInput({
    required this.milliliters,
    required this.icon,
    required this.backgroundColor,
  });

  factory WaterInput.small() = _Small;
  factory WaterInput.regular() = _Regular;
  factory WaterInput.medium() = _Medium;
  factory WaterInput.large() = _Large;
}

class _Small extends WaterInput {
  const _Small()
      : super(
          milliliters: 180,
          icon: AppSymbols.coffee_cup,
          backgroundColor: const Color(0xFFF1EEFF),
        );
}

class _Regular extends WaterInput {
  const _Regular()
      : super(
          milliliters: 250,
          icon: AppSymbols.water_glass,
          backgroundColor: const Color(0xFFF8F8F6),
        );
}

class _Medium extends WaterInput {
  const _Medium()
      : super(
          milliliters: 500,
          icon: AppSymbols.water,
          backgroundColor: const Color(0xFFFFFAEC),
        );
}

class _Large extends WaterInput {
  const _Large()
      : super(
          milliliters: 750,
          icon: AppSymbols.jug,
          backgroundColor: const Color(0xFFFBE9E3),
        );
}