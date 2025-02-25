import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/core/utils/error_utils.dart';
import 'package:watertracker/domain/models/water_settings.dart';
import 'package:watertracker/domain/repositories/i_water_repository.dart';
import 'package:watertracker/presentation/blocs/water/water_event.dart';
import 'package:watertracker/presentation/blocs/water/water_state.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final IWaterRepository _repository;
  StreamSubscription<WaterSettings>? _subscription;

  WaterBloc(this._repository) : super(WaterInitial()) {
    _subscription = _repository.waterSettings.listen(
      (settings) => add(WaterSettingsUpdated(settings)),
      onError: (Object error) => emit(WaterError(
        settings: state.settings,
        error: getErrorMessage(error),
      )),
    );

    on<WaterSettingsUpdated>((event, emit) {
      emit(WaterLoaded(settings: event.settings));
    });

    on<DrinkWater>(_handleDrinkWater);
    on<ChangeAlarmEnabled>(_handleChangeAlarmEnabled);
    on<SetRecommendedMilliliters>(_handleSetRecommendedMilliliters);
    on<ClearDataStore>(_handleClearDataStore);
  }

  int get currentWater => state.settings.currentMilliliters;

  int get remainingWater =>
      state.settings.currentMilliliters <= state.settings.recommendedMilliliters
          ? state.settings.recommendedMilliliters -
              state.settings.currentMilliliters
          : 0;

  double get progress =>
      state.settings.currentMilliliters / state.settings.recommendedMilliliters;

  Future<void> _handleDrinkWater(
    DrinkWater event,
    Emitter<WaterState> emit,
  ) async {
    try {
      emit(WaterLoading(settings: state.settings));
      await _repository.drinkWater(event.milliliters);
    } catch (e) {
      emit(WaterError(settings: state.settings, error: getErrorMessage(e)));
    }
  }

  Future<void> _handleChangeAlarmEnabled(
    ChangeAlarmEnabled event,
    Emitter<WaterState> emit,
  ) async {
    try {
      emit(WaterLoading(settings: state.settings));
      await _repository.changeAlarmEnabled(event.enabled);
    } catch (e) {
      emit(WaterError(settings: state.settings, error: getErrorMessage(e)));
    }
  }

  Future<void> _handleSetRecommendedMilliliters(
    SetRecommendedMilliliters event,
    Emitter<WaterState> emit,
  ) async {
    try {
      emit(WaterLoading(settings: state.settings));
      await _repository.setRecommendedMilliliters(event.milliliters);
    } catch (e) {
      emit(WaterError(settings: state.settings, error: getErrorMessage(e)));
    }
  }

  Future<void> _handleClearDataStore(
    ClearDataStore event,
    Emitter<WaterState> emit,
  ) async {
    try {
      emit(WaterLoading(settings: state.settings));
      await _repository.clearDataStore();
    } catch (e) {
      emit(WaterError(settings: state.settings, error: getErrorMessage(e)));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
