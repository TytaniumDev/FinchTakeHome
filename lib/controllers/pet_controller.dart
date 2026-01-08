import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:flutter/foundation.dart';

/// This controller coordinates between the PetManager and other components
/// of the system, handling user actions related to pets.
class PetController extends BaseController {
  /// Manager for pet data and business logic
  final PetManager _petManager;

  /// Constructor
  PetController({required PetManager petManager}) : _petManager = petManager;

  @override
  Future<void> onInitialize() async {}

  /// Create a new pet
  Future<void> createPet({required String name, required Gender gender}) async {
    try {
      await _petManager.createPet(name: name, gender: gender);
      debugPrint('PetController: Pet created successfully: $name');
    } catch (e) {
      debugPrint('PetController: Error creating pet: $e');
    }
  }

  /// Update the pet's information
  Future<void> updatePet({String? name, Gender? gender}) async {
    try {
      await _petManager.updatePet(name: name, gender: gender);
      debugPrint('PetController: Pet updated successfully');
    } catch (e) {
      debugPrint('PetController: Error updating pet: $e');
    }
  }

  /// Add energy to the pet
  Future<void> addEnergy(double amount) async {
    try {
      await _petManager.addEnergy(amount);
      debugPrint('PetController: Energy added successfully: $amount');

      // Check if the pet is ready to evolve after adding energy
      if (_petManager.isReadyToEvolve) {
        debugPrint('PetController: Pet is ready to evolve!');
      }
    } catch (e) {
      debugPrint('PetController: Error adding energy: $e');
    }
  }

  /// Evolve the pet if it's ready
  Future<void> evolvePet() async {
    try {
      if (!_petManager.isReadyToEvolve) {
        debugPrint('PetController: Pet is not ready to evolve');
        return;
      }

      await _petManager.evolvePet();
      debugPrint('PetController: Pet evolved successfully');
    } catch (e) {
      debugPrint('PetController: Error evolving pet: $e');
    }
  }

  /// Check in the pet for today
  Future<void> checkIn() async {
    try {
      if (_petManager.hasCheckedInToday()) {
        debugPrint('PetController: Pet has already checked in today');
        return;
      }

      await _petManager.checkIn();
      debugPrint('PetController: Pet checked in successfully');
    } catch (e) {
      debugPrint('PetController: Error checking in pet: $e');
    }
  }

  /// Check if a day transition has occurred and handle it
  Future<void> checkDayTransition() async {
    try {
      await _petManager.checkDayTransition();
      debugPrint('PetController: Day transition checked');
    } catch (e) {
      debugPrint('PetController: Error checking day transition: $e');
    }
  }

  PetGrowthStage? get petGrowthStage => _petManager.growthStage;

  double get energyPercentage => _petManager.energyPercentage;

  int get currentEnergy => _petManager.currentEnergy;

  int get maxEnergy => _petManager.maxEnergy;

  bool get isEnergyFull => _petManager.isEnergyFull;

  bool get isReadyToEvolve => _petManager.isReadyToEvolve;

  int get requiredFullEnergyDaysForEvolution =>
      _petManager.requiredFullEnergyDaysForEvolution;

  int get fullEnergyDays => _petManager.fullEnergyDays;
}
