import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

/// Service for Pet persistence operations.
///
/// This service handles direct database operations for Pet entities.
/// All business logic (evolution, energy tracking, day transitions)
/// belongs in PetManager.
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

  /// Get the current (first) pet from the database.
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

  /// Get all pets from the database.
  static Future<List<Pet>> getAllPets() async {
    debugPrint('PetService: Getting all pets');
    final box = _getBox();
    final pets = box.values.toList();
    debugPrint('PetService: Found ${pets.length} pets');
    return pets;
  }

  /// Save a pet to the database.
  static Future<void> savePet(Pet pet) async {
    debugPrint('PetService: Saving pet: ${pet.name} (${pet.id})');
    final box = _getBox();
    await box.put(pet.id, pet);
  }

  /// Create a new pet in the database.
  static Future<void> createPet(Pet pet) async {
    debugPrint('PetService: Creating pet: ${pet.name} (${pet.id})');
    await savePet(pet);
  }

  /// Update a pet in the database.
  static Future<void> updatePet(Pet pet) async {
    debugPrint('PetService: Updating pet: ${pet.name} (${pet.id})');
    await savePet(pet);
  }

  /// Delete a pet from the database.
  static Future<void> deletePet(String id) async {
    debugPrint('PetService: Deleting pet: $id');
    final box = _getBox();
    await box.delete(id);
  }

  /// Create a new pet with the given name and gender.
  static Future<Pet> createNewPet({
    required String name,
    required Gender gender,
  }) async {
    debugPrint('PetService: Creating new pet: $name');
    final pet = Pet.create(name: name, gender: gender);
    await createPet(pet);
    return pet;
  }
}
