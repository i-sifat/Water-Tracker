import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/presentation/blocs/water/water_bloc.dart';
import 'package:watertracker/presentation/pages/hydration_pool/widgets/hydration_quantity_text.dart';
import 'package:watertracker/presentation/pages/hydration_pool/widgets/person_view.dart';
import 'package:watertracker/presentation/pages/hydration_pool/widgets/remaining_hydration_text.dart';
import 'package:watertracker/presentation/pages/hydration_pool/widgets/water_view.dart';

class HydrationPoolPage extends StatefulWidget {
  const HydrationPoolPage({super.key});

  @override
  State<HydrationPoolPage> createState() => _HydrationPoolPageState();
}

class _HydrationPoolPageState extends State<HydrationPoolPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WaterBloc>();

    return Stack(
      children: [
        Align(
          alignment: const Alignment(0.0, -0.1),
          child: PersonView(animation: _controller),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: WaterView(
            animation: _controller,
            progress: bloc.progress,
          ),
        ),
        Align(
          alignment: const Alignment(0.0, -0.68),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HydrationQuantityText(bloc.currentWater),
              const SizedBox(height: 8),
              RemainingHydrationText(bloc.remainingWater),
            ],
          ),
        ),
      ],
    );
  }
}