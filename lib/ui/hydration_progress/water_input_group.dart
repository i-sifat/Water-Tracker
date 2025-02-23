import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/bloc/water_bloc.dart';
import 'package:watertracker/domain/model/water_input.dart';
import 'package:watertracker/ui/hydration_progress/water_button.dart';

class WaterInputGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void addInput(WaterInput value) {
      context.read<WaterBloc>().drinkWater(value);
    }

    return Wrap(
      children: [
        WaterButton(
          input: WaterInput.small(),
          onPressed: addInput,
        ),
        WaterButton(
          input: WaterInput.regular(),
          onPressed: addInput,
        ),
        WaterButton(
          input: WaterInput.medium(),
          onPressed: addInput,
        ),
        WaterButton(
          input: WaterInput.large(),
          onPressed: addInput,
        ),
      ],
    );
  }
}
