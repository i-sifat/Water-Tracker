import 'package:watertracker/domain/models/water_settings.dart';

abstract class WaterState {
  const WaterState({
    required this.settings,
    this.error,
    this.isLoading = false,
  });
  final WaterSettings settings;
  final String? error;
  final bool isLoading;
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
