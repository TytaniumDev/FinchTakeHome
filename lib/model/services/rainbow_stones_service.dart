import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class RainbowStonesService {
  static const String _currentBalanceKey = 'current_balance';

  static Future<RainbowStones> getCurrentBalance() async {
    debugPrint('RainbowStonesService: Getting current balance');
    final box = Hive.box<RainbowStones>(rainbowStonesBox);
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
    final box = Hive.box<RainbowStones>(rainbowStonesBox);
    await box.put(_currentBalanceKey, stones);
  }

  static Future<void> addStones(int amount) async {
    debugPrint('RainbowStonesService: Adding $amount stones');
    final stones = await getCurrentBalance();
    stones.addStones(amount);
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
