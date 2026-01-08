import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/pet_energy.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/service_locator_test_helper.dart';

void main() {
  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });
  
  group('PetEnergy Model Tests', () {
    late PetEnergy petEnergy;

    setUp(() {
      // Create a pet energy for each test
      petEnergy = PetEnergy(
        maxEnergy: 15.0,
        currentEnergy: 0.0,
        lastUpdatedTime: DateTime(2023, 1, 1),
        totalEnergyEarned: 0.0,
        fullEnergyDays: 0,
      );
    });

    test(
      'PetEnergy.create factory creates energy with correct initial values',
      () {
        final energy = PetEnergy.create();

        expect(energy.maxEnergy, equals(15.0));
        expect(energy.currentEnergy, equals(0.0));
        expect(energy.totalEnergyEarned, equals(0.0));
        expect(energy.fullEnergyDays, equals(0));
      },
    );

    test('getCurrentEnergy returns rounded current energy', () {
      petEnergy.currentEnergy = 5.7;
      expect(petEnergy.getCurrentEnergy(), equals(6));

      petEnergy.currentEnergy = 5.2;
      expect(petEnergy.getCurrentEnergy(), equals(5));

      petEnergy.currentEnergy = 0.0;
      expect(petEnergy.getCurrentEnergy(), equals(0));
    });

    test('getMaxEnergy returns rounded max energy', () {
      petEnergy.maxEnergy = 15.7;
      expect(petEnergy.getMaxEnergy(), equals(16));

      petEnergy.maxEnergy = 15.2;
      expect(petEnergy.getMaxEnergy(), equals(15));

      petEnergy.maxEnergy = 20.0;
      expect(petEnergy.getMaxEnergy(), equals(20));
    });

    test('isFullEnergy correctly identifies when energy is full', () {
      petEnergy.currentEnergy = 0.0;
      petEnergy.maxEnergy = 15.0;
      expect(petEnergy.isFullEnergy(), isFalse);

      petEnergy.currentEnergy = 7.5;
      expect(petEnergy.isFullEnergy(), isFalse);

      petEnergy.currentEnergy = 14.9;
      expect(petEnergy.isFullEnergy(), isFalse);

      petEnergy.currentEnergy = 15.0;
      expect(petEnergy.isFullEnergy(), isTrue);

      petEnergy.currentEnergy = 16.0; // Edge case: more than max
      expect(petEnergy.isFullEnergy(), isTrue);
    });

    test('getEnergyPercentage returns correct percentage', () {
      petEnergy.currentEnergy = 0.0;
      petEnergy.maxEnergy = 20.0;
      expect(petEnergy.getEnergyPercentage(), equals(0.0));

      petEnergy.currentEnergy = 10.0;
      expect(petEnergy.getEnergyPercentage(), equals(0.5));

      petEnergy.currentEnergy = 20.0;
      expect(petEnergy.getEnergyPercentage(), equals(1.0));

      petEnergy.currentEnergy = 25.0; // Edge case: more than max
      expect(petEnergy.getEnergyPercentage(), equals(1.25));
    });

    test('addEnergy correctly adds energy and caps at max', () {
      final before = DateTime.now().subtract(const Duration(minutes: 5));
      petEnergy.lastUpdatedTime = before;
      petEnergy.currentEnergy = 5.0;
      petEnergy.maxEnergy = 15.0;
      petEnergy.totalEnergyEarned = 10.0;

      petEnergy.addEnergy(5.0);

      expect(petEnergy.currentEnergy, equals(10.0));
      expect(petEnergy.totalEnergyEarned, equals(15.0));
      expect(petEnergy.lastUpdatedTime.isAfter(before), isTrue);

      // Adding more than max should cap at max
      petEnergy.addEnergy(10.0);

      expect(petEnergy.currentEnergy, equals(15.0));
      expect(petEnergy.totalEnergyEarned, equals(25.0));
    });

    test('increaseMaxEnergy correctly increases max energy', () {
      final before = DateTime.now().subtract(const Duration(minutes: 5));
      petEnergy.lastUpdatedTime = before;
      petEnergy.maxEnergy = 15.0;

      petEnergy.increaseMaxEnergy(5.0);

      expect(petEnergy.maxEnergy, equals(20.0));
      expect(petEnergy.lastUpdatedTime.isAfter(before), isTrue);
    });

    test(
      'markFullEnergyDay increments full energy days when energy is full',
      () {
        final before = DateTime.now().subtract(const Duration(minutes: 5));
        petEnergy.lastUpdatedTime = before;
        petEnergy.fullEnergyDays = 5;

        // Not full energy
        petEnergy.currentEnergy = 10.0;
        petEnergy.maxEnergy = 15.0;
        petEnergy.markFullEnergyDay();

        expect(petEnergy.fullEnergyDays, equals(5));
        expect(petEnergy.lastUpdatedTime, equals(before));

        // Full energy
        petEnergy.currentEnergy = 15.0;
        petEnergy.markFullEnergyDay();

        expect(petEnergy.fullEnergyDays, equals(6));
        expect(petEnergy.lastUpdatedTime.isAfter(before), isTrue);
      },
    );

    test(
      'setCurrentEnergy correctly sets energy and clamps to valid range',
      () {
        final before = DateTime.now().subtract(const Duration(minutes: 5));
        petEnergy.lastUpdatedTime = before;
        petEnergy.maxEnergy = 15.0;

        // Valid energy
        petEnergy.setCurrentEnergy(10);

        expect(petEnergy.currentEnergy, equals(10.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before), isTrue);

        // Energy below 0 should be clamped to 0
        final before2 = petEnergy.lastUpdatedTime;
        petEnergy.setCurrentEnergy(-5);

        expect(petEnergy.currentEnergy, equals(0.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before2), isTrue);

        // Energy above max should be clamped to max
        final before3 = petEnergy.lastUpdatedTime;
        petEnergy.setCurrentEnergy(20);

        expect(petEnergy.currentEnergy, equals(15.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before3), isTrue);
      },
    );

    test('resetForNewDay correctly resets energy', () {
      final before = DateTime.now().subtract(const Duration(minutes: 5));
      petEnergy.lastUpdatedTime = before;
      petEnergy.currentEnergy = 10.0;

      petEnergy.resetForNewDay();

      expect(petEnergy.currentEnergy, equals(0.0));
      expect(petEnergy.lastUpdatedTime.isAfter(before), isTrue);
    });

    test(
      'setMaxEnergyForGrowthStage sets correct max energy for each stage',
      () {
        final before = DateTime.now().subtract(const Duration(minutes: 5));
        petEnergy.lastUpdatedTime = before;

        petEnergy.setMaxEnergyForGrowthStage(PetGrowthStage.egg);
        expect(petEnergy.maxEnergy, equals(15.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before), isTrue);

        final before2 = petEnergy.lastUpdatedTime;
        petEnergy.setMaxEnergyForGrowthStage(PetGrowthStage.baby);
        expect(petEnergy.maxEnergy, equals(20.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before2), isTrue);

        final before3 = petEnergy.lastUpdatedTime;
        petEnergy.setMaxEnergyForGrowthStage(PetGrowthStage.toddler);
        expect(petEnergy.maxEnergy, equals(25.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before3), isTrue);

        final before4 = petEnergy.lastUpdatedTime;
        petEnergy.setMaxEnergyForGrowthStage(PetGrowthStage.child);
        expect(petEnergy.maxEnergy, equals(30.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before4), isTrue);

        final before5 = petEnergy.lastUpdatedTime;
        petEnergy.setMaxEnergyForGrowthStage(PetGrowthStage.teenager);
        expect(petEnergy.maxEnergy, equals(40.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before5), isTrue);

        final before6 = petEnergy.lastUpdatedTime;
        petEnergy.setMaxEnergyForGrowthStage(PetGrowthStage.adult);
        expect(petEnergy.maxEnergy, equals(50.0));
        expect(petEnergy.lastUpdatedTime.isAfter(before6), isTrue);
      },
    );
  });
}
