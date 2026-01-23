import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/pet_energy.dart';
import 'package:birdo/model/services/pet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/service_locator_test_helper.dart';
import '../helpers/test_helpers.dart';

/// Tests for Pet entity persistence through PetService.
/// Business logic tests (evolution, energy tracking, day transitions)
/// are tested in PetManager tests.
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

    group('CRUD Operations', () {
      test('getCurrentPet returns first pet when box is not empty', () async {
        await petBox.put(testPet.id, testPet);

        final result = await PetService.getCurrentPet();

        expect(result, isNotNull);
        expect(result!.id, equals(testPet.id));
        expect(result.name, equals(testPet.name));
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

      test('createPet persists pet correctly', () async {
        final pet = Pet.create(name: 'Created Pet', gender: Gender.male);

        await PetService.createPet(pet);

        final savedPet = petBox.get(pet.id);
        expect(savedPet, isNotNull);
        expect(savedPet?.name, equals('Created Pet'));
        expect(savedPet?.gender, equals(Gender.male));
      });

      test('updatePet persists changes', () async {
        await petBox.put(testPet.id, testPet);

        testPet.name = 'Modified Name';
        await PetService.updatePet(testPet);

        final updatedPet = petBox.get(testPet.id);
        expect(updatedPet?.name, equals('Modified Name'));
      });
    });

    group('Pet Properties', () {
      test('pet preserves all properties through save/load cycle', () async {
        final pet = await PetService.createNewPet(
          name: 'Full Pet',
          gender: Gender.female,
        );

        final loaded = await PetService.getCurrentPet();

        expect(loaded, isNotNull);
        expect(loaded!.name, equals('Full Pet'));
        expect(loaded.gender, equals(Gender.female));
        expect(loaded.growthStage, equals(PetGrowthStage.egg));
        expect(loaded.energy, isNotNull);
      });

      test('pet energy is preserved correctly', () async {
        await petBox.put(testPet.id, testPet);

        // Modify energy
        testPet.energy.addEnergy(5);
        await PetService.savePet(testPet);

        final loaded = petBox.get(testPet.id);
        expect(loaded?.energy.getCurrentEnergy(), equals(5));
      });

      test('pet growth stages are preserved', () async {
        for (final stage in PetGrowthStage.values) {
          final pet = TestFactory.createTestPet(
            id: 'stage-${stage.name}',
            growthStage: stage,
          );
          await petBox.put(pet.id, pet);

          final loaded = petBox.get(pet.id);
          expect(loaded?.growthStage, equals(stage));
        }
      });

      test('pet genders are preserved', () async {
        for (final gender in Gender.values) {
          final pet = Pet.create(name: 'Gender Test', gender: gender);
          await PetService.createPet(pet);

          final loaded = petBox.get(pet.id);
          expect(loaded?.gender, equals(gender));
        }
      });
    });
  });
}
