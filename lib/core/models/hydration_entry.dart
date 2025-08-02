import 'package:equatable/equatable.dart';
import 'package:watertracker/core/models/hydration_data.dart';

/// Enhanced model representing a single hydration entry with additional functionality
/// This extends the existing HydrationData model with swipeable interface specific features
class HydrationEntry extends Equatable {
  const HydrationEntry({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.type,
    this.notes,
    this.isSynced = false,
  });

  /// Create a new hydration entry with current timestamp
  factory HydrationEntry.create({
    required int amount,
    DrinkType type = DrinkType.water,
    String? notes,
    bool isSynced = false,
  }) {
    return HydrationEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      amount: amount,
      type: type,
      notes: notes,
      isSynced: isSynced,
    );
  }

  /// Create from existing HydrationData
  factory HydrationEntry.fromHydrationData(HydrationData data) {
    return HydrationEntry(
      id: data.id,
      timestamp: data.timestamp,
      amount: data.amount,
      type: data.type,
      notes: data.notes,
      isSynced: data.isSynced,
    );
  }

  /// Create from JSON
  factory HydrationEntry.fromJson(Map<String, dynamic> json) {
    return HydrationEntry(
      id: json['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      amount: json['amount'] as int,
      type: DrinkType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DrinkType.water,
      ),
      notes: json['notes'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  /// Unique identifier for this hydration entry
  final String id;

  /// When this hydration was recorded
  final DateTime timestamp;

  /// Amount of liquid consumed in milliliters
  final int amount;

  /// Type of drink consumed
  final DrinkType type;

  /// Optional notes about this hydration entry
  final String? notes;

  /// Whether this data has been synced to cloud/external services
  final bool isSynced;

  /// Calculate the actual water content based on drink type
  double get waterContent => amount * type.waterContent;

  /// Get the actual water content in milliliters (rounded)
  int get waterContentMl => waterContent.round();

  /// Get the date portion of the timestamp (without time)
  DateTime get date => DateTime(timestamp.year, timestamp.month, timestamp.day);

  /// Get formatted time string (e.g., "2:30 PM")
  String get formattedTime {
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get formatted amount string (e.g., "250 ml")
  String get formattedAmount => '$amount ml';

  /// Get formatted water content string (e.g., "238 ml water")
  String get formattedWaterContent => '$waterContentMl ml water';

  /// Convert to HydrationData for compatibility
  HydrationData toHydrationData() {
    return HydrationData(
      id: id,
      amount: amount,
      timestamp: timestamp,
      type: type,
      notes: notes,
      isSynced: isSynced,
    );
  }

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'amount': amount,
      'type': type.name,
      'notes': notes,
      'isSynced': isSynced,
    };
  }

  /// Create a copy with updated fields
  HydrationEntry copyWith({
    String? id,
    DateTime? timestamp,
    int? amount,
    DrinkType? type,
    String? notes,
    bool? isSynced,
  }) {
    return HydrationEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, amount, type, notes, isSynced];

  @override
  String toString() {
    return 'HydrationEntry(id: $id, amount: ${amount}ml, type: ${type.displayName}, timestamp: $timestamp)';
  }
}

/// Extension for working with lists of HydrationEntry
extension HydrationEntryList on List<HydrationEntry> {
  /// Get total water intake for the list
  int get totalWaterIntake =>
      fold(0, (sum, entry) => sum + entry.waterContentMl);

  /// Get total liquid intake for the list
  int get totalLiquidIntake => fold(0, (sum, entry) => sum + entry.amount);

  /// Filter by date
  List<HydrationEntry> forDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return where((entry) => entry.date == targetDate).toList();
  }

  /// Filter by date range
  List<HydrationEntry> forDateRange(DateTime start, DateTime end) {
    return where(
      (entry) =>
          entry.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.timestamp.isBefore(end.add(const Duration(days: 1))),
    ).toList();
  }

  /// Group by date
  Map<DateTime, List<HydrationEntry>> groupByDate() {
    final grouped = <DateTime, List<HydrationEntry>>{};
    for (final entry in this) {
      final date = entry.date;
      grouped[date] = (grouped[date] ?? [])..add(entry);
    }
    return grouped;
  }

  /// Get entries that need syncing
  List<HydrationEntry> get unsyncedEntries =>
      where((entry) => !entry.isSynced).toList();

  /// Convert to HydrationData list for compatibility
  List<HydrationData> toHydrationDataList() {
    return map((entry) => entry.toHydrationData()).toList();
  }
}
