import 'package:watertracker/domain/models/water_history.dart';

class HistoryState {
  const HistoryState({
    required this.weeks,
    required this.selectedWeek,
    this.isLoading = false,
    this.error,
  });
  
  factory HistoryState.initial() => HistoryState(
    weeks: const [],
    selectedWeek: WeeklyWaterData.mock(2), // Default to week 2
    isLoading: true,
  );
  
  final List<WeeklyWaterData> weeks;
  final WeeklyWaterData selectedWeek;
  final bool isLoading;
  final String? error;
  
  HistoryState copyWith({
    List<WeeklyWaterData>? weeks,
    WeeklyWaterData? selectedWeek,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      weeks: weeks ?? this.weeks,
      selectedWeek: selectedWeek ?? this.selectedWeek,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}