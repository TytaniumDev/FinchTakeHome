import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:birdo/model/managers/base_manager.dart';
import 'package:birdo/model/services/rainbow_stones_service.dart';
import 'package:flutter/foundation.dart';

class RainbowStonesManager extends BaseManager {
  RainbowStones? _rainbowStones;

  RainbowStonesManager();

  RainbowStones? get rainbowStones => _rainbowStones;

  int get currentBalance => _rainbowStones?.getCurrentBalance() ?? 0;

  int get totalEarned => _rainbowStones?.getTotalEarned() ?? 0;

  @override
  Future<void> onInitialize() async {
    await loadRainbowStones();
  }

  Future<void> loadRainbowStones() async {
    debugPrint('RainbowStonesManager: Loading rainbow stones...');
    try {
      _rainbowStones = await RainbowStonesService.getCurrentBalance();

      debugPrint(
        'RainbowStonesManager: Loaded rainbow stones: ${_rainbowStones?.getCurrentBalance() ?? 0}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('RainbowStonesManager: Error loading rainbow stones: $e');
    }
  }

  Future<void> addStones(int amount) async {
    debugPrint('RainbowStonesManager: Adding stones: $amount');
    try {
      await RainbowStonesService.addStones(amount);

      await loadRainbowStones();

      debugPrint('RainbowStonesManager: Stones added successfully');
    } catch (e) {
      debugPrint('RainbowStonesManager: Error adding stones: $e');
    }
  }

  Future<bool> spendStones(int amount) async {
    debugPrint('RainbowStonesManager: Spending stones: $amount');
    try {
      final success = await RainbowStonesService.spendStones(amount);

      await loadRainbowStones();

      debugPrint('RainbowStonesManager: Stones spent successfully: $success');
      return success;
    } catch (e) {
      debugPrint('RainbowStonesManager: Error spending stones: $e');
      return false;
    }
  }

  bool hasEnoughStones(int amount) {
    return currentBalance >= amount;
  }

  Future<void> awardDailyStones(int amount) async {
    debugPrint('RainbowStonesManager: Awarding daily stones: $amount');
    try {
      await addStones(amount);

      debugPrint('RainbowStonesManager: Daily stones awarded successfully');
    } catch (e) {
      debugPrint('RainbowStonesManager: Error awarding daily stones: $e');
    }
  }

  Future<void> awardTaskCompletionStones(int amount) async {
    debugPrint(
      'RainbowStonesManager: Awarding task completion stones: $amount',
    );
    try {
      await addStones(amount);

      debugPrint(
        'RainbowStonesManager: Task completion stones awarded successfully',
      );
    } catch (e) {
      debugPrint(
        'RainbowStonesManager: Error awarding task completion stones: $e',
      );
    }
  }

  Future<void> awardPetEvolutionStones(int amount) async {
    debugPrint('RainbowStonesManager: Awarding pet evolution stones: $amount');
    try {
      await addStones(amount);

      debugPrint(
        'RainbowStonesManager: Pet evolution stones awarded successfully',
      );
    } catch (e) {
      debugPrint(
        'RainbowStonesManager: Error awarding pet evolution stones: $e',
      );
    }
  }
}
