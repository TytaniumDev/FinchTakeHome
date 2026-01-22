import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class RainbowStonesService {
  static const String _currentBalanceKey = 'current_balance';

  static bool _testMode = false;
  static Box<RainbowStones>? _testBox;

  static void enableTestMode(Box<RainbowStones> testBox) {
    _testMode = true;
    _testBox = testBox;
  }

  static void disableTestMode() {
    _testMode = false;
    _testBox = null;
  }

  static Box<RainbowStones> _getBox() {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box<RainbowStones>(rainbowStonesBox);
  }

  static Future<RainbowStones> getCurrentBalance() async {
    debugPrint('RainbowStonesService: Getting current balance');
    final box = _getBox();
    var stones = box.get(_currentBalanceKey);
    if (stones == null) {
      debugPrint('RainbowStonesService: No balance found, creating new');
      stones = RainbowStones.create();
      await box.put(_currentBalanceKey, stones);
    }
    debugPrint(
      'RainbowStonesService: Current balance: ${stones.currentAmount}',
    );
    return stones;
  }

  static Future<void> saveRainbowStones(RainbowStones stones) async {
    debugPrint('RainbowStonesService: Saving rainbow stones');
    final box = _getBox();
    await box.put(_currentBalanceKey, stones);
  }

  static Future<void> addStones(int amount) async {
    debugPrint('RainbowStonesService: Adding $amount stones');
    final stones = await getCurrentBalance();
    stones.addStones(amount);
    await saveRainbowStones(stones);
    debugPrint('RainbowStonesService: New balance: ${stones.currentAmount}');
  }
  
  static Future<void> removeStones(int amount) async {
    debugPrint('RainbowStonesService: Removing $amount stones');
    final stones = await getCurrentBalance();
    stones.removeStones(amount);
    await saveRainbowStones(stones);
    debugPrint('RainbowStonesService: New balance: ${stones.currentAmount}');
  }

  static Future<bool> spendStones(int amount) async {
    debugPrint('RainbowStonesService: Attempting to spend $amount stones');
    final stones = await getCurrentBalance();
    final success = stones.spendStones(amount);

    if (success) {
      debugPrint('RainbowStonesService: Stones spent successfully');
      await saveRainbowStones(stones);
      debugPrint('RainbowStonesService: New balance: ${stones.currentAmount}');
    } else {
      debugPrint('RainbowStonesService: Insufficient stones to spend');
    }

    return success;
  }

  static Future<int> getTotalEarned() async {
    debugPrint('RainbowStonesService: Getting total earned');
    final stones = await getCurrentBalance();
    final totalEarned = stones.getTotalEarned();
    debugPrint('RainbowStonesService: Total earned: $totalEarned');
    return totalEarned;
  }
}
