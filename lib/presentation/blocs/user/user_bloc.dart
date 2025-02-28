import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/data/services/storage_service.dart';
import 'package:watertracker/domain/models/user_preferences.dart';
import 'package:watertracker/presentation/blocs/user/user_event.dart';
import 'package:watertracker/presentation/blocs/user/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._storageService) : super(UserState.initial()) {
    on<LoadUserPreferences>(_onLoadUserPreferences);
    on<UpdateGender>(_onUpdateGender);

    // Load user preferences when bloc is created
    add(const LoadUserPreferences());
  }

  final StorageService _storageService;

  Future<void> _onLoadUserPreferences(
    LoadUserPreferences event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final prefs = await _storageService.loadUserPreferences();

      if (prefs != null) {
        emit(state.copyWith(
          preferences: prefs,
          isLoading: false,
        ));
      } else {
        // Use default preferences if none are saved
        final defaultPrefs = UserPreferences.initial();
        await _storageService.saveUserPreferences(defaultPrefs);

        emit(state.copyWith(
          preferences: defaultPrefs,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load user preferences',
      ));
    }
  }

  Future<void> _onUpdateGender(
    UpdateGender event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final updatedPrefs = state.preferences.copyWith(
        isMale: event.isMale,
      );

      await _storageService.saveUserPreferences(updatedPrefs);

      emit(state.copyWith(
        preferences: updatedPrefs,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to update gender preference',
      ));
    }
  }
}
