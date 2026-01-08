import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:flutter/foundation.dart';

/// This controller coordinates between managers to handle
/// user actions on the settings screen.
class SettingsController extends BaseController {
  /// Manager for pet data and business logic
  final PetManager _petManager;

  /// Manager for rainbow stones data and business logic
  final RainbowStonesManager _rainbowStonesManager;

  /// Constructor
  SettingsController({
    required PetManager petManager,
    required RainbowStonesManager rainbowStonesManager,
  }) : _petManager = petManager,
       _rainbowStonesManager = rainbowStonesManager;

  @override
  Future<void> onInitialize() async {}

  /// Load settings screen data
  Future<void> loadSettingsData() async {
    try {
      // Load current pet
      await _petManager.loadCurrentPet();

      // Load rainbow stones
      await _rainbowStonesManager.loadRainbowStones();

      debugPrint('SettingsController: Settings data loaded successfully');
    } catch (e) {
      debugPrint('SettingsController: Error loading settings data: $e');
    }
  }

  /// Update pet name
  Future<void> updatePetName(String name) async {
    try {
      if (name.isEmpty) {
        debugPrint('SettingsController: Pet name cannot be empty');
        return;
      }

      await _petManager.updatePet(name: name);
      debugPrint('SettingsController: Pet name updated to: $name');
    } catch (e) {
      debugPrint('SettingsController: Error updating pet name: $e');
    }
  }

  /// Update pet gender
  Future<void> updatePetGender(Gender gender) async {
    try {
      await _petManager.updatePet(gender: gender);
      debugPrint('SettingsController: Pet gender updated to: $gender');
    } catch (e) {
      debugPrint('SettingsController: Error updating pet gender: $e');
    }
  }

  /// Purchase item with rainbow stones
  Future<bool> purchaseItem(String itemId, int cost) async {
    try {
      // Check if user has enough stones
      if (!_rainbowStonesManager.hasEnoughStones(cost)) {
        debugPrint(
          'SettingsController: Not enough rainbow stones to purchase item',
        );
        return false;
      }

      // Spend the stones
      final success = await _rainbowStonesManager.spendStones(cost);

      if (success) {
        debugPrint('SettingsController: Item purchased successfully: $itemId');
        // Here you would typically update some inventory or unlock feature
        // This would be implemented in a separate manager
      }

      return success;
    } catch (e) {
      debugPrint('SettingsController: Error purchasing item: $e');
      return false;
    }
  }

  /// Reset app data (for testing/debugging)
  Future<void> resetAppData() async {
    try {
      // This would typically involve resetting all managers
      // For now, we'll just create a new pet
      await _petManager.createPet(name: 'Birdo', gender: Gender.other);

      debugPrint('SettingsController: App data reset successfully');
    } catch (e) {
      debugPrint('SettingsController: Error resetting app data: $e');
    }
  }

  String? get petName => _petManager.currentPet?.name;

  Gender? get petGender => _petManager.currentPet?.gender;

  PetGrowthStage? get petGrowthStage => _petManager.growthStage;

  int get rainbowStonesBalance => _rainbowStonesManager.currentBalance;

  int get totalRainbowStonesEarned => _rainbowStonesManager.totalEarned;
}
