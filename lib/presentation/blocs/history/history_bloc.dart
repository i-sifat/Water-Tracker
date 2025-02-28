import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/domain/models/water_history.dart';
import 'package:watertracker/presentation/blocs/history/history_event.dart';
import 'package:watertracker/presentation/blocs/history/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState.initial()) {
    on<LoadHistory>(_onLoadHistory);
    on<SelectWeek>(_onSelectWeek);
    
    // Load history when bloc is created
    add(const LoadHistory());
  }
  
  void _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) {
    // For now, we'll use mock data
    // In a real app, this would load from a repository
    final weeks = <WeeklyWaterData>[];
    
    for (int i = 1; i <= 4; i++) {
      weeks.add(WeeklyWaterData.mock(i));
    }
    
    emit(state.copyWith(
      weeks: weeks,
      selectedWeek: weeks[1], // Default to week 2 as shown in the design
      isLoading: false,
    ));
  }
  
  void _onSelectWeek(SelectWeek event, Emitter<HistoryState> emit) {
    final selectedWeek = state.weeks.firstWhere(
      (week) => week.weekNumber == event.weekNumber,
      orElse: () => state.selectedWeek,
    );
    
    emit(state.copyWith(selectedWeek: selectedWeek));
  }
}