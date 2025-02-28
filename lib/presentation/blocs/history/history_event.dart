abstract class HistoryEvent {
  const HistoryEvent();
}

class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

class SelectWeek extends HistoryEvent {
  const SelectWeek(this.weekNumber);
  
  final int weekNumber;
}