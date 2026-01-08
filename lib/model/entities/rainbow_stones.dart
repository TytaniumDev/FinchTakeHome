import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

part 'rainbow_stones.g.dart';

@HiveType(typeId: 7)
class RainbowStones extends HiveObject {
  @HiveField(0)
  int currentAmount;

  @HiveField(1)
  int totalEarned;

  @HiveField(2)
  DateTime lastUpdated;

  final DateTimeService _dateTimeService;

  static const String _boxName = rainbowStonesBox;
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

  RainbowStones({
    required this.currentAmount,
    required this.totalEarned,
    required this.lastUpdated,
    DateTimeService? dateTimeService,
  }) : _dateTimeService = dateTimeService ?? ServiceLocator.dateTimeService;

  factory RainbowStones.create({DateTimeService? dateTimeService}) {
    final dts = dateTimeService ?? ServiceLocator.dateTimeService;
    return RainbowStones(
      currentAmount: 0,
      totalEarned: 0,
      lastUpdated: dts.getCurrentDate(),
      dateTimeService: dts,
    );
  }

  void addStones(int amount) {
    currentAmount += amount;
    totalEarned += amount;
    lastUpdated = _dateTimeService.getCurrentDate();
  }

  bool spendStones(int amount) {
    if (currentAmount >= amount) {
      currentAmount -= amount;
      lastUpdated = _dateTimeService.getCurrentDate();
      return true;
    }
    return false;
  }

  int getCurrentBalance() => currentAmount;

  int getTotalEarned() => totalEarned;

  static Future<Box<RainbowStones>> _getBox() async {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box<RainbowStones>(_boxName);
  }

  @override
  Future<void> save() async {
    debugPrint('RainbowStones: Saving stones, current balance: $currentAmount');
    final box = await _getBox();
    await box.put(_currentBalanceKey, this);
  }

  static Future<RainbowStones> fetchCurrentBalance() async {
    debugPrint('RainbowStones: Getting current balance');
    final box = await _getBox();
    var stones = box.get(_currentBalanceKey);
    if (stones == null) {
      debugPrint('RainbowStones: No stones found, creating new');
      stones = RainbowStones.create();
      await stones.save();
    } else {
      debugPrint(
        'RainbowStones: Found stones with balance: ${stones.currentAmount}',
      );
    }
    return stones;
  }

  static Future<void> addStonesToBalance(int amount) async {
    debugPrint('RainbowStones: Adding $amount stones');
    final stones = await fetchCurrentBalance();
    stones.addStones(amount);
    await stones.save();
    debugPrint(
      'RainbowStones: New balance after adding: ${stones.currentAmount}',
    );
  }

  static Future<bool> spendStonesFromBalance(int amount) async {
    debugPrint('RainbowStones: Attempting to spend $amount stones');
    final stones = await fetchCurrentBalance();
    final success = stones.spendStones(amount);
    if (success) {
      debugPrint(
        'RainbowStones: Spend successful, new balance: ${stones.currentAmount}',
      );
      await stones.save();
    } else {
      debugPrint(
        'RainbowStones: Spend failed, insufficient balance: ${stones.currentAmount}',
      );
    }
    return success;
  }

  static Future<int> fetchTotalEarned() async {
    debugPrint('RainbowStones: Getting total earned');
    final stones = await fetchCurrentBalance();
    debugPrint('RainbowStones: Total earned: ${stones.totalEarned}');
    return stones.totalEarned;
  }
}
