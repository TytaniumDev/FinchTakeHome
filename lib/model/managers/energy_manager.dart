import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/pet_energy.dart';
import 'package:birdo/model/managers/base_manager.dart';
import 'package:flutter/foundation.dart';

class EnergyManager extends BaseManager {
  PetEnergy? _currentEnergy;

  EnergyManager({PetEnergy? initialEnergy}) : _currentEnergy = initialEnergy;

  PetEnergy? get currentEnergy => _currentEnergy;

  double get energyPercentage => _currentEnergy?.getEnergyPercentage() ?? 0.0;

  int get currentEnergyValue => _currentEnergy?.getCurrentEnergy() ?? 0;

  int get maxEnergyValue => _currentEnergy?.getMaxEnergy() ?? 0;

  bool get isEnergyFull => _currentEnergy?.isFullEnergy() ?? false;

  int get fullEnergyDays => _currentEnergy?.fullEnergyDays ?? 0;

  double get totalEnergyEarned => _currentEnergy?.totalEnergyEarned ?? 0.0;

  @override
  Future<void> onInitialize() async {
    _currentEnergy ??= PetEnergy.create();
    debugPrint(
      'EnergyManager: Initialized with energy: ${_currentEnergy?.getCurrentEnergy() ?? 0}/${_currentEnergy?.getMaxEnergy() ?? 0}',
    );
  }

  void setEnergy(PetEnergy energy) {
    _currentEnergy = energy;
    debugPrint(
      'EnergyManager: Energy set to ${energy.getCurrentEnergy()}/${energy.getMaxEnergy()}',
    );
    notifyListeners();
  }

  void addEnergy(double amount) {
    if (_currentEnergy == null) {
      debugPrint('EnergyManager: No energy to add to');
      return;
    }

    debugPrint('EnergyManager: Adding energy: $amount');
    bool wasFullBefore = _currentEnergy!.isFullEnergy();

    _currentEnergy!.addEnergy(amount);

    if (!wasFullBefore && _currentEnergy!.isFullEnergy()) {
      _currentEnergy!.markFullEnergyDay();
      debugPrint('EnergyManager: Marked full energy day');
    }

    notifyListeners();
  }

  void setMaxEnergy(double maxEnergy) {
    if (_currentEnergy == null) {
      debugPrint('EnergyManager: No energy to set max for');
      return;
    }

    debugPrint('EnergyManager: Setting max energy: $maxEnergy');
    _currentEnergy!.maxEnergy = maxEnergy;
    notifyListeners();
  }

  void resetForNewDay() {
    if (_currentEnergy == null) {
      debugPrint('EnergyManager: No energy to reset');
      return;
    }

    debugPrint('EnergyManager: Resetting energy for new day');

    int fullEnergyDays = _currentEnergy!.fullEnergyDays;
    double totalEnergyEarned = _currentEnergy!.totalEnergyEarned;

    _currentEnergy!.resetForNewDay();

    _currentEnergy!.fullEnergyDays = fullEnergyDays;
    _currentEnergy!.totalEnergyEarned = totalEnergyEarned;

    notifyListeners();
  }

  void setMaxEnergyForGrowthStage(PetGrowthStage stage) {
    if (_currentEnergy == null) {
      debugPrint('EnergyManager: No energy to set max for growth stage');
      return;
    }

    debugPrint('EnergyManager: Setting max energy for growth stage: $stage');
    _currentEnergy!.setMaxEnergyForGrowthStage(stage);
    notifyListeners();
  }

  void markFullEnergyDay() {
    if (_currentEnergy == null) {
      debugPrint('EnergyManager: No energy to mark full day for');
      return;
    }

    if (_currentEnergy!.isFullEnergy()) {
      debugPrint('EnergyManager: Marking full energy day');
      _currentEnergy!.markFullEnergyDay();
      notifyListeners();
    }
  }
}
