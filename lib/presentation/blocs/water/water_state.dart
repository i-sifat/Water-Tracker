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
  WaterInitial() : super(settings: WaterSettings.initial());
}

class WaterLoading extends WaterState {
  const WaterLoading({required super.settings}) : super(isLoading: true);
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
