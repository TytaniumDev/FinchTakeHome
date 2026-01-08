import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/pet_energy.dart';
import 'package:birdo/model/services/pet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/service_locator_test_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Pet Model Persistence Tests', () {
    late Box<Pet> petBox;
    late Pet testPet;

    setUpAll(() async {
      await ServiceLocatorTestHelper.initialize();

      Hive.init('test_pet');

      // Register all required adapters
      Hive.registerAdapter(PetAdapter());
      Hive.registerAdapter(PetGrowthStageAdapter());
      Hive.registerAdapter(GenderAdapter());
      Hive.registerAdapter(PetEnergyAdapter());

      petBox = await Hive.openBox<Pet>('pets_test');
      PetService.enableTestMode(petBox);
    });

    setUp(() {
      // Create a test pet
      testPet = TestFactory.createTestPet(
        id: 'test-pet-id',
        name: 'Test Pet',
        growthStage: PetGrowthStage.egg,
      );
    });

    tearDown(() async {
      // Clear the box after each test
      await petBox.clear();
    });

    tearDownAll(() async {
      PetService.disableTestMode();

      await Hive.close();
      await Hive.deleteBoxFromDisk('pets_test');
    });

    test('getCurrentPet returns first pet when box is not empty', () async {
      // Add test pet to box
      await petBox.put(testPet.id, testPet);

      final result = await PetService.getCurrentPet();

      expect(result, equals(testPet));
    });

    test('getCurrentPet returns null when box is empty', () async {
      final result = await PetService.getCurrentPet();

      expect(result, isNull);
    });

    test('createNewPet adds pet to box', () async {
      final pet = await PetService.createNewPet(
        name: 'New Pet',
        gender: Gender.female,
      );

      final savedPet = petBox.get(pet.id);
      expect(savedPet, isNotNull);
      expect(savedPet?.name, equals('New Pet'));
      expect(savedPet?.gender, equals(Gender.female));
    });

    test('savePet updates pet in box', () async {
      await petBox.put(testPet.id, testPet);

      testPet.name = 'Updated Pet';

      await PetService.savePet(testPet);

      final updatedPet = petBox.get(testPet.id);
      expect(updatedPet?.name, equals('Updated Pet'));
    });

    test('deletePet removes pet from box', () async {
      await petBox.put(testPet.id, testPet);

      await PetService.deletePet(testPet.id);

      final deletedPet = petBox.get(testPet.id);
      expect(deletedPet, isNull);
    });

    test('getAllPets returns all pets in box', () async {
      // Create a list of test pets
      final testPets = [
        TestFactory.createTestPet(id: 'pet-1', name: 'Pet 1'),
        TestFactory.createTestPet(id: 'pet-2', name: 'Pet 2'),
      ];

      for (final pet in testPets) {
        await petBox.put(pet.id, pet);
      }

      final result = await PetService.getAllPets();
      expect(result.length, equals(2));
      expect(result.any((p) => p.name == 'Pet 1'), isTrue);
      expect(result.any((p) => p.name == 'Pet 2'), isTrue);
    });

    test('evolvePet evolves pet when ready', () async {
      // Create a pet that is ready to evolve
      final evolvablePet = TestFactory.createTestPet(
        id: 'evolve-pet-id',
        growthStage: PetGrowthStage.egg,
      );

      evolvablePet.energy.fullEnergyDays = 1;
      await petBox.put(evolvablePet.id, evolvablePet);

      await PetService.evolvePet(evolvablePet.id);

      final evolvedPet = petBox.get(evolvablePet.id);
      expect(evolvedPet?.growthStage, equals(PetGrowthStage.baby));
    });

    test('evolvePet does not evolve pet when not ready', () async {
      // Create a pet that is not ready to evolve
      final nonEvolvablePet = TestFactory.createTestPet(
        id: 'non-evolve-pet-id',
        growthStage: PetGrowthStage.egg,
      );

      nonEvolvablePet.energy.fullEnergyDays = 0;
      await petBox.put(nonEvolvablePet.id, nonEvolvablePet);

      await PetService.evolvePet(nonEvolvablePet.id);
      final unchangedPet = petBox.get(nonEvolvablePet.id);
      expect(unchangedPet?.growthStage, equals(PetGrowthStage.egg));
    });

    test('evolvePet does nothing when pet is not found', () async {
      await PetService.evolvePet('non-existent-id');
      expect(petBox.isEmpty, isTrue);
    });
  });
}
