import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/model_factories.dart';

void main() {
  group('HydrationData', () {
    test('should create instance with required fields', () {
      final data = HydrationData(
        id: 'test_id',
        amount: 250,
        timestamp: DateTime(2024, 1, 1, 10),
      );

      expect(data.id, equals('test_id'));
      expect(data.amount, equals(250));
      expect(data.timestamp, equals(DateTime(2024, 1, 1, 10)));
      expect(data.type, equals(DrinkType.water));
      expect(data.isSynced, equals(false));
      expect(data.notes, isNull);
    });

    test('should calculate water content correctly', () {
      final waterData = HydrationData(
        id: 'test',
        amount: 250,
        timestamp: DateTime.now(),
      );
      expect(waterData.waterContent, equals(250));

      final coffeeData = HydrationData(
        id: 'test',
        amount: 250,
        timestamp: DateTime.now(),
        type: DrinkType.coffee,
      );
      expect(coffeeData.waterContent, equals(238)); // 250 * 0.95 = 237.5 -> 238
    });

    test('should get date without time', () {
      final data = HydrationData(
        id: 'test',
        amount: 250,
        timestamp: DateTime(2024, 1, 15, 14, 30, 45),
      );

      expect(data.date, equals(DateTime(2024, 1, 15)));
    });

    test('should create copy with updated fields', () {
      final original = HydrationData(
        id: 'test',
        amount: 250,
        timestamp: DateTime.now(),
      );

      final copy = original.copyWith(amount: 300, type: DrinkType.tea);

      expect(copy.id, equals(original.id));
      expect(copy.amount, equals(300));
      expect(copy.type, equals(DrinkType.tea));
      expect(copy.timestamp, equals(original.timestamp));
    });

    test('should serialize to and from JSON', () {
      final original = HydrationData(
        id: 'test_id',
        amount: 250,
        timestamp: DateTime(2024, 1, 1, 10),
        type: DrinkType.coffee,
        isSynced: true,
        notes: 'Morning coffee',
      );

      final json = original.toJson();
      final restored = HydrationData.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.amount, equals(original.amount));
      expect(restored.timestamp, equals(original.timestamp));
      expect(restored.type, equals(original.type));
      expect(restored.isSynced, equals(original.isSynced));
      expect(restored.notes, equals(original.notes));
    });

    test('should create instance with factory method', () {
      final data = HydrationData.create(
        amount: 300,
        type: DrinkType.tea,
        notes: 'Afternoon tea',
      );

      expect(data.amount, equals(300));
      expect(data.type, equals(DrinkType.tea));
      expect(data.notes, equals('Afternoon tea'));
      expect(data.id, isNotEmpty);
      expect(data.timestamp, isA<DateTime>());
    });

    group('DrinkType', () {
      test('should have correct water content percentages', () {
        expect(DrinkType.water.waterContent, equals(1.0));
        expect(DrinkType.tea.waterContent, equals(0.95));
        expect(DrinkType.coffee.waterContent, equals(0.95));
        expect(DrinkType.juice.waterContent, equals(0.85));
        expect(DrinkType.soda.waterContent, equals(0.90));
        expect(DrinkType.sports.waterContent, equals(0.92));
        expect(DrinkType.other.waterContent, equals(0.80));
      });

      test('should have display names', () {
        expect(DrinkType.water.displayName, equals('Water'));
        expect(DrinkType.coffee.displayName, equals('Coffee'));
        expect(DrinkType.tea.displayName, equals('Tea'));
      });
    });

    group('HydrationDataList extension', () {
      late List<HydrationData> testData;

      setUp(() {
        testData = [
          HydrationData(
            id: '1',
            amount: 250,
            timestamp: DateTime(2024, 1, 1, 8),
          ),
          HydrationData(
            id: '2',
            amount: 200,
            timestamp: DateTime(2024, 1, 1, 12),
            type: DrinkType.coffee,
          ),
          HydrationData(
            id: '3',
            amount: 300,
            timestamp: DateTime(2024, 1, 2, 9),
          ),
        ];
      });

      test('should calculate total water intake', () {
        final totalWater = testData.totalWaterIntake;
        // 250 * 1.0 + 200 * 0.95 + 300 * 1.0 = 250 + 190 + 300 = 740
        expect(totalWater, equals(740));
      });

      test('should calculate total liquid intake', () {
        final totalLiquid = testData.totalLiquidIntake;
        expect(totalLiquid, equals(750)); // 250 + 200 + 300
      });

      test('should filter by date', () {
        final jan1Data = testData.forDate(DateTime(2024));
        expect(jan1Data.length, equals(2));
        expect(jan1Data.every((d) => d.date == DateTime(2024)), isTrue);
      });

      test('should group by date', () {
        final grouped = testData.groupByDate();
        expect(grouped.keys.length, equals(2));
        expect(grouped[DateTime(2024)]?.length, equals(2));
        expect(grouped[DateTime(2024, 1, 2)]?.length, equals(1));
      });

      test('should filter unsynced entries', () {
        testData[0] = testData[0].copyWith(isSynced: true);
        final unsynced = testData.unsyncedEntries;
        expect(unsynced.length, equals(2));
        expect(unsynced.every((d) => !d.isSynced), isTrue);
      });
    });
  });

  group('ModelFactories', () {
    test('should create HydrationData with factory', () {
      final data = ModelFactories.createHydrationData(
        amount: 250,
        type: DrinkType.coffee,
      );

      expect(data.amount, equals(250));
      expect(data.type, equals(DrinkType.coffee));
      expect(data.id, isNotEmpty);
    });

    test('should create list of HydrationData', () {
      final dataList = ModelFactories.createHydrationDataList(count: 5);
      expect(dataList.length, equals(5));
      expect(dataList.every((d) => d.id.isNotEmpty), isTrue);
    });

    test('should create daily hydration data', () {
      final date = DateTime(2024);
      final dailyData = ModelFactories.createDailyHydrationData(
        date: date,
        entryCount: 6,
        totalAmount: 1800,
      );

      expect(dailyData.length, equals(6));
      expect(dailyData.every((d) => d.date == date), isTrue);
      expect(dailyData.totalLiquidIntake, greaterThan(1500));
    });
  });

  group('HydrationDataBuilder', () {
    test('should build HydrationData with fluent interface', () {
      final data = HydrationDataBuilder()
          .withAmount(300)
          .asCoffee()
          .synced()
          .today()
          .withNotes('Morning coffee')
          .build();

      expect(data.amount, equals(300));
      expect(data.type, equals(DrinkType.coffee));
      expect(data.isSynced, isTrue);
      expect(data.notes, equals('Morning coffee'));
    });
  });
}