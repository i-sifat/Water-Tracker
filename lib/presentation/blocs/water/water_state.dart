import 'package:watertracker/domain/models/water_settings.dart';

abstract class WaterState {
  final WaterSettings settings;
  final String? error;
  final bool isLoading;

  const WaterState({
    required this.settings,
    this.error,
    this.isLoading = false,
  });
}

class WaterInitial extends WaterState {
  const WaterInitial() : super(settings: const WaterSettings.initial());
}

class WaterLoading extends WaterState {
  const WaterLoading({required super.settings});
}

class WaterLoaded extends WaterState {
  const WaterLoaded({required super.settings});
}

class WaterError extends WaterState {
  const WaterError({
    required super.settings,
    required String error,
  }) : super(error: error);
}