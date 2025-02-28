class WaterHistory {
  const WaterHistory({
    required this.date,
    required this.amount,
  });

  final DateTime date;
  final int amount; // in milliliters

  WaterHistory copyWith({
    DateTime? date,
    int? amount,
  }) {
    return WaterHistory(
      date: date ?? this.date,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
    };
  }

  factory WaterHistory.fromMap(Map<String, dynamic> map) {
    return WaterHistory(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      amount: map['amount'] as int,
    );
  }
}

class WeeklyWaterData {
  const WeeklyWaterData({
    required this.weekNumber,
    required this.dailyData,
    required this.average,
  });

  final int weekNumber;
  final List<DailyWaterData> dailyData;
  final double average;

  factory WeeklyWaterData.fromHistory(
      List<WaterHistory> history, int weekNumber) {
    // Create daily data for each day of the week
    final dailyData = <DailyWaterData>[];
    double totalAmount = 0;
    int daysWithData = 0;

    // Get the start date of the week (assuming week 1 starts from current date - 21 days)
    final startDate =
        DateTime.now().subtract(Duration(days: 21 - (weekNumber - 1) * 7));

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final dayHistory = history
          .where((h) =>
              h.date.year == date.year &&
              h.date.month == date.month &&
              h.date.day == date.day)
          .toList();

      int amount = 0;
      if (dayHistory.isNotEmpty) {
        amount = dayHistory.fold(0, (sum, item) => sum + item.amount);
        totalAmount += amount;
        daysWithData++;
      }

      dailyData.add(
        DailyWaterData(
          date: date,
          amount: amount,
        ),
      );
    }

    final average = daysWithData > 0 ? totalAmount / daysWithData : 0;

    return WeeklyWaterData(
      weekNumber: weekNumber,
      dailyData: dailyData,
      average: average,
    );
  }

  // Mock data for development
  factory WeeklyWaterData.mock(int weekNumber) {
    final dailyData = <DailyWaterData>[];
    double totalAmount = 0;

    // Create mock data for each day of the week
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: 7 - i));
      final amount = i % 2 == 0 ? 1450 : 0; // Alternate between 1.45L and 0

      if (amount > 0) {
        totalAmount += amount;
      }

      dailyData.add(DailyWaterData(
        date: date,
        amount: amount,
      ));
    }

    return WeeklyWaterData(
      weekNumber: weekNumber,
      dailyData: dailyData,
      average: totalAmount / 7,
    );
  }
}

class DailyWaterData {
  const DailyWaterData({
    required this.date,
    required this.amount,
  });

  final DateTime date;
  final int amount; // in milliliters

  // Convert to liters for display
  double get liters => amount / 1000;

  // Get day of week abbreviation
  String get dayAbbreviation {
    switch (date.weekday) {
      case DateTime.monday:
        return 'mo';
      case DateTime.tuesday:
        return 'tu';
      case DateTime.wednesday:
        return 'we';
      case DateTime.thursday:
        return 'th';
      case DateTime.friday:
        return 'fr';
      case DateTime.saturday:
        return 'sa';
      case DateTime.sunday:
        return 'su';
      default:
        return '';
    }
  }
}
