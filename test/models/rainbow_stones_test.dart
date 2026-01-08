import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/service_locator_test_helper.dart';

void main() {
  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });
  
  group('RainbowStones Model Tests', () {
    late RainbowStones rainbowStones;

    setUp(() {
      // Create rainbow stones for each test
      rainbowStones = RainbowStones(
        currentAmount: 0,
        totalEarned: 0,
        lastUpdated: DateTime(2023, 1, 1),
      );
    });

    test('RainbowStones constructor initializes with correct values', () {
      expect(rainbowStones.currentAmount, equals(0));
      expect(rainbowStones.totalEarned, equals(0));
      expect(rainbowStones.lastUpdated, equals(DateTime(2023, 1, 1)));
    });

    test(
      'RainbowStones.create factory creates stones with correct initial values',
      () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final stones = RainbowStones.create();

        expect(stones.currentAmount, equals(0));
        expect(stones.totalEarned, equals(0));
        expect(stones.lastUpdated.isAfter(before), isTrue);

        // Last updated time should be close to now
        final now = DateTime.now();
        final difference = now.difference(stones.lastUpdated).inSeconds.abs();
        expect(
          difference,
          lessThan(5),
        ); // Allow 5 seconds difference for test execution
      },
    );

    test('addStones correctly adds stones', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));

      rainbowStones.currentAmount = 10;
      rainbowStones.totalEarned = 20;
      rainbowStones.lastUpdated = DateTime(2023, 1, 1);

      rainbowStones.addStones(5);

      expect(rainbowStones.currentAmount, equals(15));
      expect(rainbowStones.totalEarned, equals(25));
      expect(rainbowStones.lastUpdated.isAfter(before), isTrue);

      // Adding negative stones (edge case)
      final before2 = rainbowStones.lastUpdated;
      rainbowStones.addStones(-3);

      expect(rainbowStones.currentAmount, equals(12));
      expect(rainbowStones.totalEarned, equals(22));
      expect(rainbowStones.lastUpdated.isAfter(before2), isTrue);
    });

    test('spendStones correctly spends stones and returns success/failure', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));

      rainbowStones.currentAmount = 10;
      rainbowStones.lastUpdated = DateTime(2023, 1, 1);

      // Successful spend
      final success = rainbowStones.spendStones(5);

      expect(success, isTrue);
      expect(rainbowStones.currentAmount, equals(5));
      expect(rainbowStones.lastUpdated.isAfter(before), isTrue);

      // Failed spend (not enough stones)
      final before2 = rainbowStones.lastUpdated;
      final failure = rainbowStones.spendStones(10);

      expect(failure, isFalse);
      expect(rainbowStones.currentAmount, equals(5));
      expect(rainbowStones.lastUpdated, equals(before2));

      // Exact amount spend
      final before3 = rainbowStones.lastUpdated;
      final exactSuccess = rainbowStones.spendStones(5);

      expect(exactSuccess, isTrue);
      expect(rainbowStones.currentAmount, equals(0));
      expect(rainbowStones.lastUpdated.isAfter(before3), isTrue);

      // Zero amount spend (edge case)
      final before4 = rainbowStones.lastUpdated;
      final zeroSuccess = rainbowStones.spendStones(0);

      expect(zeroSuccess, isTrue);
      expect(rainbowStones.currentAmount, equals(0));
      expect(rainbowStones.lastUpdated.isAfter(before4), isTrue);
    });

    test('getCurrentBalance returns correct balance', () {
      rainbowStones.currentAmount = 15;
      expect(rainbowStones.getCurrentBalance(), equals(15));

      rainbowStones.currentAmount = 0;
      expect(rainbowStones.getCurrentBalance(), equals(0));
    });

    test('getTotalEarned returns correct total earned', () {
      rainbowStones.totalEarned = 25;
      expect(rainbowStones.getTotalEarned(), equals(25));

      rainbowStones.totalEarned = 0;
      expect(rainbowStones.getTotalEarned(), equals(0));
    });
  });
}
