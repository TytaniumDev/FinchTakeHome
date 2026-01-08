import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/managers/base_manager.dart';
import 'package:birdo/model/services/pet_service.dart';
import 'package:flutter/foundation.dart';

class PetManager extends BaseManager {
  final DateTimeService _dateTimeService;

  Pet? _currentPet;

  PetManager({DateTimeService? dateTimeService})
    : _dateTimeService = dateTimeService ?? ServiceLocator.dateTimeService;

  Pet? get currentPet => _currentPet;

  double get energyPercentage => _currentPet?.getEnergyPercentage() ?? 0.0;

  int get currentEnergy => _currentPet?.energy.getCurrentEnergy() ?? 0;

  int get maxEnergy => _currentPet?.energy.getMaxEnergy() ?? 0;

  bool get isEnergyFull => _currentPet?.energy.isFullEnergy() ?? false;

  PetGrowthStage? get growthStage => _currentPet?.growthStage;

  bool get isReadyToEvolve => _currentPet?.isReadyToEvolve() ?? false;

  int get requiredFullEnergyDaysForEvolution =>
      _currentPet?.getRequiredFullEnergyDaysForEvolution() ?? 0;

  int get fullEnergyDays => _currentPet?.energy.fullEnergyDays ?? 0;

  @override
  Future<void> onInitialize() async {
    await loadCurrentPet();
    await checkDayTransition();
  }

  Future<void> loadCurrentPet() async {
    debugPrint('PetManager: Loading current pet...');
    try {
      _currentPet = await PetService.getCurrentPet();

      if (_currentPet == null) {
        // Don't create a default pet here - this will be handled by the NUX flow
        // If we're here and there's no pet, the NUX flow should be shown
        debugPrint('PetManager: No pet found, waiting for NUX flow to create one');
      } else {
        debugPrint('PetManager: Loaded pet: ${_currentPet!.name}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('PetManager: Error loading pet: $e');
    }
  }

  Future<void> createPet({required String name, required Gender gender}) async {
    debugPrint('PetManager: Creating pet: $name');
    try {
      _currentPet = await PetService.createNewPet(name: name, gender: gender);

      debugPrint('PetManager: Pet created successfully: ${_currentPet!.name}');
      notifyListeners();
    } catch (e) {
      debugPrint('PetManager: Error creating pet: $e');
    }
  }

  Future<void> updatePet({String? name, Gender? gender}) async {
    if (_currentPet == null) {
      debugPrint('PetManager: No pet to update');
      return;
    }

    debugPrint('PetManager: Updating pet: ${_currentPet!.id}');
    try {
      if (name != null) {
        _currentPet!.name = name;
      }

      await PetService.updatePet(_currentPet!);

      debugPrint('PetManager: Pet updated successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('PetManager: Error updating pet: $e');
    }
  }

  Future<void> evolvePet() async {
    if (_currentPet == null) {
      debugPrint('PetManager: No pet to evolve');
      return;
    }

    if (!_currentPet!.isReadyToEvolve()) {
      debugPrint('PetManager: Pet is not ready to evolve');
      return;
    }

    debugPrint('PetManager: Evolving pet: ${_currentPet!.id}');
    try {
      await PetService.evolvePet(_currentPet!.id);
      await loadCurrentPet();
      
      debugPrint(
        'PetManager: Pet evolved successfully to ${_currentPet!.growthStage}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('PetManager: Error evolving pet: $e');
    }
  }

  Future<void> addEnergy(double amount) async {
    if (_currentPet == null) {
      debugPrint('PetManager: No pet to add energy to');
      return;
    }

    debugPrint('PetManager: Adding energy to pet: $amount');
    try {
      await PetService.addEnergy(_currentPet!, amount);
      await loadCurrentPet();

      debugPrint('PetManager: Energy added successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('PetManager: Error adding energy: $e');
    }
  }

  bool hasCheckedInToday() {
    return _currentPet?.hasCheckedInToday() ?? false;
  }

  Future<void> checkIn() async {
    if (_currentPet == null) {
      debugPrint('PetManager: No pet to check in');
      return;
    }

    debugPrint('PetManager: Checking in pet');
    try {
      await PetService.checkIn(_currentPet!);
      await loadCurrentPet();

      debugPrint('PetManager: Pet checked in successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('PetManager: Error checking in pet: $e');
    }
  }

  Future<void> checkDayTransition() async {
    if (_currentPet == null) {
      debugPrint('PetManager: No pet to check day transition for');
      return;
    }

    final currentDate = _dateTimeService.getCurrentDate();
    if (!_isSameDay(_currentPet!.lastCheckInTime, currentDate)) {
      debugPrint('PetManager: Day transition detected');

      try {
        await PetService.handleDayTransition(_currentPet!, currentDate);
        await loadCurrentPet();

        debugPrint('PetManager: Day transition handled successfully');
        notifyListeners();
      } catch (e) {
        debugPrint('PetManager: Error handling day transition: $e');
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return _dateTimeService.isSameDay(date1, date2);
  }
}
