import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/domain/models/water_settings.dart';
import 'package:watertracker/data/repositories/water_repository.dart';

class WaterBloc extends Cubit<WaterSettings> {
  WaterBloc(this._repository) : super(WaterSettings.initial()) {
    _subscription = _repository.waterSettings.listen((event) {
      emit(event);
    });
  }

  final WaterRepository _repository;
  StreamSubscription<WaterSettings>? _subscription;

  int get currentWater => state.currentMilliliters;
  int get remainingWater =>
      state.currentMilliliters <= state.recommendedMilliliters
          ? state.recommendedMilliliters - state.currentMilliliters
          : 0;
  double get progress =>
      state.currentMilliliters / state.recommendedMilliliters;

  Future<void> drinkWater(int milliliters) async {
    await _repository.drinkWater(milliliters);
  }

  void changeAlarmEnabled(bool enabled) {
    _repository.changeAlarmEnabled(enabled);
  }

  void setRecommendedMilliliters(int milliliters) {
    _repository.setRecommendedMilliliters(milliliters);
  }

  void clearDataStore() {
    _repository.clearDataStore();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}