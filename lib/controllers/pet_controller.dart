import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:flutter/foundation.dart';

/// PetController provides the UI layer interface for pet-related operations.
///
/// ## Architectural Purpose
///
/// While this controller currently delegates most operations to PetManager,
/// it exists because the UI layer should only communicate with Controllers,
/// never directly with Managers. This maintains consistent architecture and:
///
/// 1. **Enforces layer boundaries**: Views → Controllers → Managers → Services
/// 2. **Enables future cross-domain coordination**: If pet operations need to
///    coordinate with other managers (e.g., awarding rainbow stones on evolution),
///    this coordination happens here without changing the UI layer.
/// 3. **Provides a stable API**: The UI depends on PetController's interface,
///    allowing PetManager internals to change without affecting views.
/// 4. **Centralizes logging/error handling**: Controller-level error handling
///    and debug logging is consistent across all pet operations.
///
/// See also:
/// - [PetManager] for pet state management and business logic
/// - [HomeController] for cross-domain coordination examples
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
