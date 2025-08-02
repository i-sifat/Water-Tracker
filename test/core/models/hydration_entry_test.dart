import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_entry.dart';

void main() {
  group('HydrationEntry', () {
    late DateTime testTimestamp;

    setUp(() {
      testTimestamp = DateTime(2024, 1, 15, 14, 30);
    });

    test('should create instance with required fields', () {
      final entry = HydrationEntry(
        id: 'test_id',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.water,
      );

      expect(entry.id, equals('test_id'));
      expect(entry.timestamp, equals(testTimestamp));
      expect(entry.amount, equals(250));
      expect(entry.type, equals(DrinkType.water));
      expect(entry.notes, isNull);
      expect(entry.isSynced, isFalse);
    });

    test('should create instance with all fields', () {
      final entry = HydrationEntry(
        id: 'test_id',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.coffee,
        notes: 'Morning coffee',
        isSynced: true,
      );

      expect(entry.id, equals('test_id'));
      expect(entry.timestamp, equals(testTimestamp));
      expect(entry.amount, equals(250));
      expect(entry.type, equals(DrinkType.coffee));
      expect(entry.notes, equals('Morning coffee'));
      expect(entry.isSynced, isTrue);
    });

    test('should calculate water content correctly', () {
      final waterEntry = HydrationEntry(
        id: 'test',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.water,
      );
      expect(waterEntry.waterContent, equals(250.0));
      expect(waterEntry.waterContentMl, equals(250));

      final coffeeEntry = HydrationEntry(
        id: 'test',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.coffee,
      );
      expect(coffeeEntry.waterContent, equals(237.5)); // 250 * 0.95
      expect(coffeeEntry.waterContentMl, equals(238));

      final teaEntry = HydrationEntry(
        id: 'test',
        timestamp: testTimestamp,
        amount: 300,
        type: DrinkType.tea,
      );
      expect(teaEntry.waterContent, equals(285.0)); // 300 * 0.95
      expect(teaEntry.waterContentMl, equals(285));
    });

    test('should get date correctly', () {
      final entry = HydrationEntry(
        id: 'test',
        timestamp: DateTime(2024, 1, 15, 14, 30, 45),
        amount: 250,
        type: DrinkType.water,
      );

      expect(entry.date, equals(DateTime(2024, 1, 15)));
    });

    test('should format time correctly', () {
      final morningEntry = HydrationEntry(
        id: 'test',
        timestamp: DateTime(2024, 1, 15, 8, 30),
        amount: 250,
        type: DrinkType.water,
      );
      expect(morningEntry.formattedTime, equals('8:30 AM'));

      final afternoonEntry = HydrationEntry(
        id: 'test',
        timestamp: DateTime(2024, 1, 15, 14, 22),
        amount: 250,
        type: DrinkType.water,
      );
      expect(afternoonEntry.formattedTime, equals('2:22 PM'));

      final midnightEntry = HydrationEntry(
        id: 'test',
        timestamp: DateTime(2024, 1, 15, 0, 5),
        amount: 250,
        type: DrinkType.water,
      );
      expect(midnightEntry.formattedTime, equals('12:05 AM'));

      final noonEntry = HydrationEntry(
        id: 'test',
        timestamp: DateTime(2024, 1, 15, 12),
        amount: 250,
        type: DrinkType.water,
      );
      expect(noonEntry.formattedTime, equals('12:00 PM'));
    });

    test('should format amount correctly', () {
      final entry = HydrationEntry(
        id: 'test',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.water,
      );

      expect(entry.formattedAmount, equals('250 ml'));
    });

    test('should format water content correctly', () {
      final waterEntry = HydrationEntry(
        id: 'test',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.water,
      );
      expect(waterEntry.formattedWaterContent, equals('250 ml water'));

      final coffeeEntry = HydrationEntry(
        id: 'test',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.coffee,
      );
      expect(coffeeEntry.formattedWaterContent, equals('238 ml water'));
    });

    test('should create entry with current timestamp', () {
      final entry = HydrationEntry.create(
        amount: 250,
        type: DrinkType.tea,
        notes: 'Afternoon tea',
      );

      expect(entry.amount, equals(250));
      expect(entry.type, equals(DrinkType.tea));
      expect(entry.notes, equals('Afternoon tea'));
      expect(entry.isSynced, isFalse);
      expect(entry.id, isNotEmpty);
      expect(entry.timestamp, isA<DateTime>());
    });

    test('should create from HydrationData', () {
      final hydrationData = HydrationData(
        id: 'test_id',
        amount: 300,
        timestamp: testTimestamp,
        type: DrinkType.juice,
        notes: 'Orange juice',
        isSynced: true,
      );

      final entry = HydrationEntry.fromHydrationData(hydrationData);

      expect(entry.id, equals('test_id'));
      expect(entry.amount, equals(300));
      expect(entry.timestamp, equals(testTimestamp));
      expect(entry.type, equals(DrinkType.juice));
      expect(entry.notes, equals('Orange juice'));
      expect(entry.isSynced, isTrue);
    });

    test('should convert to HydrationData', () {
      final entry = HydrationEntry(
        id: 'test_id',
        timestamp: testTimestamp,
        amount: 300,
        type: DrinkType.juice,
        notes: 'Orange juice',
        isSynced: true,
      );

      final hydrationData = entry.toHydrationData();

      expect(hydrationData.id, equals('test_id'));
      expect(hydrationData.amount, equals(300));
      expect(hydrationData.timestamp, equals(testTimestamp));
      expect(hydrationData.type, equals(DrinkType.juice));
      expect(hydrationData.notes, equals('Orange juice'));
      expect(hydrationData.isSynced, isTrue);
    });

    test('should serialize to JSON correctly', () {
      final entry = HydrationEntry(
        id: 'test_id',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.coffee,
        notes: 'Morning coffee',
        isSynced: true,
      );

      final json = entry.toJson();
      expect(json['id'], equals('test_id'));
      expect(json['timestamp'], equals(testTimestamp.millisecondsSinceEpoch));
      expect(json['amount'], equals(250));
      expect(json['type'], equals('coffee'));
      expect(json['notes'], equals('Morning coffee'));
      expect(json['isSynced'], isTrue);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test_id',
        'timestamp': testTimestamp.millisecondsSinceEpoch,
        'amount': 250,
        'type': 'coffee',
        'notes': 'Morning coffee',
        'isSynced': true,
      };

      final entry = HydrationEntry.fromJson(json);
      expect(entry.id, equals('test_id'));
      expect(entry.timestamp, equals(testTimestamp));
      expect(entry.amount, equals(250));
      expect(entry.type, equals(DrinkType.coffee));
      expect(entry.notes, equals('Morning coffee'));
      expect(entry.isSynced, isTrue);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'test_id',
        'timestamp': testTimestamp.millisecondsSinceEpoch,
        'amount': 250,
        'type': 'water',
      };

      final entry = HydrationEntry.fromJson(json);
      expect(entry.id, equals('test_id'));
      expect(entry.timestamp, equals(testTimestamp));
      expect(entry.amount, equals(250));
      expect(entry.type, equals(DrinkType.water));
      expect(entry.notes, isNull);
      expect(entry.isSynced, isFalse);
    });

    test('should create copy with updated fields', () {
      final original = HydrationEntry(
        id: 'test_id',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.water,
      );

      final copy = original.copyWith(
        amount: 300,
        type: DrinkType.tea,
        notes: 'Green tea',
      );

      expect(copy.id, equals('test_id')); // unchanged
      expect(copy.timestamp, equals(testTimestamp)); // unchanged
      expect(copy.amount, equals(300));
      expect(copy.type, equals(DrinkType.tea));
      expect(copy.notes, equals('Green tea'));
      expect(copy.isSynced, isFalse); // unchanged
    });

    test('should implement equality correctly', () {
      final entry1 = HydrationEntry(
        id: 'test_id',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.water,
      );

      final entry2 = HydrationEntry(
        id: 'test_id',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.water,
      );

      final entry3 = HydrationEntry(
        id: 'different_id',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.water,
      );

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });

    test('should have meaningful toString', () {
      final entry = HydrationEntry(
        id: 'test_id',
        timestamp: testTimestamp,
        amount: 250,
        type: DrinkType.coffee,
      );

      final string = entry.toString();
      expect(string, contains('test_id'));
      expect(string, contains('250ml'));
      expect(string, contains('Coffee'));
      expect(string, contains(testTimestamp.toString()));
    });
  });

  group('HydrationEntryList extension', () {
    late List<HydrationEntry> sampleEntries;

    setUp(() {
      sampleEntries = [
        HydrationEntry(
          id: '1',
          timestamp: DateTime(2024, 1, 15, 8),
          amount: 500,
          type: DrinkType.water,
        ),
        HydrationEntry(
          id: '2',
          timestamp: DateTime(2024, 1, 15, 12),
          amount: 300,
          type: DrinkType.tea, // 285ml water
        ),
        HydrationEntry(
          id: '3',
          timestamp: DateTime(2024, 1, 16, 9),
          amount: 250,
          type: DrinkType.coffee, // 238ml water
        ),
      ];
    });

    test('should calculate total water intake correctly', () {
      // 500 + 285 + 238 = 1023ml
      expect(sampleEntries.totalWaterIntake, equals(1023));
    });

    test('should calculate total liquid intake correctly', () {
      // 500 + 300 + 250 = 1050ml
      expect(sampleEntries.totalLiquidIntake, equals(1050));
    });

    test('should filter by date correctly', () {
      final jan15Entries = sampleEntries.forDate(DateTime(2024, 1, 15));
      expect(jan15Entries.length, equals(2));
      expect(jan15Entries[0].id, equals('1'));
      expect(jan15Entries[1].id, equals('2'));

      final jan16Entries = sampleEntries.forDate(DateTime(2024, 1, 16));
      expect(jan16Entries.length, equals(1));
      expect(jan16Entries[0].id, equals('3'));
    });

    test('should filter by date range correctly', () {
      final rangeEntries = sampleEntries.forDateRange(
        DateTime(2024, 1, 15),
        DateTime(2024, 1, 15),
      );
      expect(rangeEntries.length, equals(2));
    });

    test('should group by date correctly', () {
      final grouped = sampleEntries.groupByDate();
      expect(grouped.keys.length, equals(2));
      expect(grouped[DateTime(2024, 1, 15)]?.length, equals(2));
      expect(grouped[DateTime(2024, 1, 16)]?.length, equals(1));
    });

    test('should filter unsynced entries correctly', () {
      final entriesWithSync = [
        ...sampleEntries,
        HydrationEntry(
          id: '4',
          timestamp: DateTime(2024, 1, 17, 10),
          amount: 200,
          type: DrinkType.water,
          isSynced: true,
        ),
      ];

      final unsynced = entriesWithSync.unsyncedEntries;
      expect(unsynced.length, equals(3)); // Original 3 entries are not synced
      expect(unsynced.every((entry) => !entry.isSynced), isTrue);
    });

    test('should convert to HydrationData list correctly', () {
      final hydrationDataList = sampleEntries.toHydrationDataList();
      expect(hydrationDataList.length, equals(3));
      expect(hydrationDataList[0], isA<HydrationData>());
      expect(hydrationDataList[0].id, equals('1'));
      expect(hydrationDataList[0].amount, equals(500));
    });
  });
}
