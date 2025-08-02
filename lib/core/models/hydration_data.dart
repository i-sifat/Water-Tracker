import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Enum representing different types of drinks
enum DrinkType {
  water,
  tea,
  coffee,
  juice,
  soda,
  sports,
  other;

  /// Water content percentage for each drink type
  double get waterContent {
    switch (this) {
      case DrinkType.water:
        return 1;
      case DrinkType.tea:
        return 0.95;
      case DrinkType.coffee:
        return 0.95;
      case DrinkType.juice:
        return 0.85;
      case DrinkType.soda:
        return 0.90;
      case DrinkType.sports:
        return 0.92;
      case DrinkType.other:
        return 0.80;
    }
  }

  /// Display name for the drink type
  String get displayName {
    switch (this) {
      case DrinkType.water:
        return 'Water';
      case DrinkType.tea:
        return 'Tea';
      case DrinkType.coffee:
        return 'Coffee';
      case DrinkType.juice:
        return 'Juice';
      case DrinkType.soda:
        return 'Soda';
      case DrinkType.sports:
        return 'Sports Drink';
      case DrinkType.other:
        return 'Other';
    }
  }

  /// Icon for the drink type
  IconData get icon {
    switch (this) {
      case DrinkType.water:
        return Icons.water_drop;
      case DrinkType.tea:
        return Icons.local_cafe;
      case DrinkType.coffee:
        return Icons.coffee;
      case DrinkType.juice:
        return Icons.local_drink;
      case DrinkType.soda:
        return Icons.local_bar;
      case DrinkType.sports:
        return Icons.sports_bar;
      case DrinkType.other:
        return Icons.local_drink;
    }
  }

  /// Color associated with the drink type
  Color get color {
    switch (this) {
      case DrinkType.water:
        return const Color(0xFF2196F3); // Blue
      case DrinkType.tea:
        return const Color(0xFF8D6E63); // Brown
      case DrinkType.coffee:
        return const Color(0xFF5D4037); // Dark Brown
      case DrinkType.juice:
        return const Color(0xFFFF9800); // Orange
      case DrinkType.soda:
        return const Color(0xFF9C27B0); // Purple
      case DrinkType.sports:
        return const Color(0xFF4CAF50); // Green
      case DrinkType.other:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }
}

/// Model representing a single hydration entry
class HydrationData extends Equatable {
  const HydrationData({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.type = DrinkType.water,
    this.isSynced = false,
    this.notes,
  });

  /// Create from JSON
  factory HydrationData.fromJson(Map<String, dynamic> json) {
    return HydrationData(
      id: json['id'] as String,
      amount: json['amount'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      type: DrinkType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DrinkType.water,
      ),
      isSynced: json['isSynced'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Create a new hydration entry with current timestamp
  factory HydrationData.create({
    required int amount,
    DrinkType type = DrinkType.water,
    String? notes,
    bool isSynced = false,
  }) {
    return HydrationData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: DateTime.now(),
      type: type,
      notes: notes,
      isSynced: isSynced,
    );
  }

  /// Unique identifier for this hydration entry
  final String id;

  /// Amount of liquid consumed in milliliters
  final int amount;

  /// When this hydration was recorded
  final DateTime timestamp;

  /// Type of drink consumed
  final DrinkType type;

  /// Whether this data has been synced to cloud/external services
  final bool isSynced;

  /// Optional notes about this hydration entry
  final String? notes;

  /// Calculate the actual water content based on drink type
  int get waterContent => (amount * type.waterContent).round();

  /// Get the date portion of the timestamp (without time)
  DateTime get date => DateTime(timestamp.year, timestamp.month, timestamp.day);

  /// Create a copy with updated fields
  HydrationData copyWith({
    String? id,
    int? amount,
    DateTime? timestamp,
    DrinkType? type,
    bool? isSynced,
    String? notes,
  }) {
    return HydrationData(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.name,
      'isSynced': isSynced,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, amount, timestamp, type, isSynced, notes];

  @override
  String toString() {
    return 'HydrationData(id: $id, amount: ${amount}ml, type: ${type.displayName}, timestamp: $timestamp)';
  }
}

/// Extension for working with lists of HydrationData
extension HydrationDataList on List<HydrationData> {
  /// Get total water intake for the list
  int get totalWaterIntake => fold(0, (sum, data) => sum + data.waterContent);

  /// Get total liquid intake for the list
  int get totalLiquidIntake => fold(0, (sum, data) => sum + data.amount);

  /// Filter by date
  List<HydrationData> forDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return where((data) => data.date == targetDate).toList();
  }

  /// Filter by date range
  List<HydrationData> forDateRange(DateTime start, DateTime end) {
    return where(
      (data) =>
          data.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
          data.timestamp.isBefore(end.add(const Duration(days: 1))),
    ).toList();
  }

  /// Group by date
  Map<DateTime, List<HydrationData>> groupByDate() {
    final grouped = <DateTime, List<HydrationData>>{};
    for (final data in this) {
      final date = data.date;
      grouped[date] = (grouped[date] ?? [])..add(data);
    }
    return grouped;
  }

  /// Get entries that need syncing
  List<HydrationData> get unsyncedEntries =>
      where((data) => !data.isSynced).toList();
}
