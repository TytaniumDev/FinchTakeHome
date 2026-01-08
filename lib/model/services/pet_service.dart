import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class PetService {
  static bool _testMode = false;
  static Box<Pet>? _testBox;

  static void enableTestMode(Box<Pet> testBox) {
    _testMode = true;
    _testBox = testBox;
  }

  static void disableTestMode() {
    _testMode = false;
    _testBox = null;
  }

  static Box<Pet> _getBox() {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box<Pet>(petBox);
  }

  static Future<Pet?> getCurrentPet() async {
    debugPrint('PetService: Getting current pet');
    final box = _getBox();
    if (box.isEmpty) {
      debugPrint('PetService: No pets found');
      return null;
    }
    final pet = box.values.first;
    debugPrint('PetService: Found pet: ${pet.name} (${pet.id})');
    return pet;
  }

  static Future<List<Pet>> getAllPets() async {
    debugPrint('PetService: Getting all pets');
    final box = _getBox();
    final pets = box.values.toList();
    debugPrint('PetService: Found ${pets.length} pets');
    return pets;
  }

  static Future<void> savePet(Pet pet) async {
    debugPrint('PetService: Saving pet: ${pet.name} (${pet.id})');
    final box = _getBox();
    await box.put(pet.id, pet);
  }

  static Future<void> createPet(Pet pet) async {
    debugPrint('PetService: Creating pet: ${pet.name} (${pet.id})');
    await savePet(pet);
  }

  static Future<void> updatePet(Pet pet) async {
    debugPrint('PetService: Updating pet: ${pet.name} (${pet.id})');
    await savePet(pet);
  }

  static Future<void> deletePet(String id) async {
    debugPrint('PetService: Deleting pet: $id');
    final box = _getBox();
    await box.delete(id);
  }

  static Future<void> evolvePet(String id) async {
    debugPrint('PetService: Evolving pet: $id');
    final box = _getBox();
    final pet = box.get(id);
    if (pet == null) {
      debugPrint('PetService: Pet not found');
      return;
    }

    if (pet.isReadyToEvolve()) {
      debugPrint('PetService: Pet is ready to evolve');
      pet.evolve();
      await savePet(pet);
      debugPrint('PetService: Pet evolved to ${pet.growthStage}');
    } else {
      debugPrint('PetService: Pet is not ready to evolve');
    }
  }

  static Future<Pet> createNewPet({
    required String name,
    required Gender gender,
  }) async {
    debugPrint('PetService: Creating new pet: $name');
    final pet = Pet.create(name: name, gender: gender);
    await createPet(pet);
    return pet;
  }

  static Future<void> addEnergy(Pet pet, double amount) async {
    debugPrint('PetService: Adding energy to pet: $amount');
    bool wasFullBefore = pet.energy.isFullEnergy();

    pet.energy.addEnergy(amount);

    if (!wasFullBefore && pet.energy.isFullEnergy()) {
      pet.energy.markFullEnergyDay();
      debugPrint('PetService: Marked full energy day');
    }

    await savePet(pet);
  }

  static Future<void> checkIn(Pet pet) async {
    debugPrint('PetService: Checking in pet');
    pet.checkIn();
    await savePet(pet);
  }

  static Future<void> handleDayTransition(Pet pet, DateTime currentDate) async {
    debugPrint('PetService: Handling day transition for pet');

    if (pet.energy.isFullEnergy()) {
      pet.energy.markFullEnergyDay();
      debugPrint('PetService: Marked full energy day during transition');
    }

    if (pet.isReadyToEvolve()) {
      pet.evolve();
      debugPrint('PetService: Pet evolved during day transition');
    }

    int fullEnergyDays = pet.energy.fullEnergyDays;
    double totalEnergyEarned = pet.energy.totalEnergyEarned;

    pet.energy.resetForNewDay();

    pet.energy.fullEnergyDays = fullEnergyDays;
    pet.energy.totalEnergyEarned = totalEnergyEarned;

    pet.energy.setMaxEnergyForGrowthStage(pet.growthStage);

    pet.lastCheckInTime = currentDate;

    await savePet(pet);
  }
}
