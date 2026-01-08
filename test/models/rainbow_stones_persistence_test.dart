import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/service_locator_test_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('RainbowStones Persistence Tests', () {
    late Box<RainbowStones> stonesBox;
    late RainbowStones testStones;

    setUpAll(() async {
      // Initialize ServiceLocator
      await ServiceLocatorTestHelper.initialize();

      // Initialize Hive for testing
      Hive.init('test_stones');

      // Register all required adapters
      Hive.registerAdapter(RainbowStonesAdapter());

      // Open the rainbow stones box
      stonesBox = await Hive.openBox<RainbowStones>('rainbow_stones_test');

      // Enable test mode for RainbowStones
      RainbowStones.enableTestMode(stonesBox);
    });

    setUp(() {
      // Create test rainbow stones
      testStones = TestFactory.createTestRainbowStones(
        currentAmount: 100,
        totalEarned: 200,
      );
    });

    tearDown(() async {
      // Clear the box after each test
      await stonesBox.clear();
    });

    tearDownAll(() async {
      // Disable test mode
      RainbowStones.disableTestMode();

      // Close all boxes and delete the test directory
      await Hive.close();
      await Hive.deleteBoxFromDisk('rainbow_stones_test');
    });

    test('save persists rainbow stones to box', () async {
      // Call the method under test
      await testStones.save();

      // Verify the result
      final savedStones = stonesBox.get('current_balance');
      expect(savedStones, equals(testStones));
    });

    test('fetchCurrentBalance returns stones when box is not empty', () async {
      // Add test stones to box
      await stonesBox.put('current_balance', testStones);

      // Call the method under test
      final result = await RainbowStones.fetchCurrentBalance();

      // Verify the result
      expect(result, equals(testStones));
    });

    test('fetchCurrentBalance creates new stones when box is empty', () async {
      // Call the method under test
      final result = await RainbowStones.fetchCurrentBalance();

      // Verify the result
      expect(result, isNotNull);
      expect(result.currentAmount, equals(0));
      expect(result.totalEarned, equals(0));
    });

    test('addStonesToBalance updates stones in box', () async {
      // Add test stones to box
      await stonesBox.put('current_balance', testStones);

      // Call the method under test
      await RainbowStones.addStonesToBalance(50);

      // Verify the result
      final updatedStones = stonesBox.get('current_balance');
      expect(updatedStones?.currentAmount, equals(150));
      expect(updatedStones?.totalEarned, equals(250));
    });

    test(
      'spendStonesFromBalance updates stones in box when successful',
      () async {
        // Add test stones to box
        await stonesBox.put('current_balance', testStones);

        // Call the method under test
        final result = await RainbowStones.spendStonesFromBalance(50);

        // Verify the result
        expect(result, isTrue);
        final updatedStones = stonesBox.get('current_balance');
        expect(updatedStones?.currentAmount, equals(50));
        expect(
          updatedStones?.totalEarned,
          equals(200),
        ); // Total earned doesn't change
      },
    );

    test(
      'spendStonesFromBalance returns false when not enough stones',
      () async {
        // Add test stones to box with low balance
        final lowBalanceStones = TestFactory.createTestRainbowStones(
          currentAmount: 30,
          totalEarned: 200,
        );
        await stonesBox.put('current_balance', lowBalanceStones);

        // Call the method under test
        final result = await RainbowStones.spendStonesFromBalance(50);

        // Verify the result
        expect(result, isFalse);
        final unchangedStones = stonesBox.get('current_balance');
        expect(unchangedStones?.currentAmount, equals(30)); // Unchanged
      },
    );

    test('fetchTotalEarned returns total earned stones', () async {
      // Add test stones to box
      await stonesBox.put('current_balance', testStones);

      // Call the method under test
      final result = await RainbowStones.fetchTotalEarned();

      // Verify the result
      expect(result, equals(200));
    });
  });
}
