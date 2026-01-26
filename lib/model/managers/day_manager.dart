import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/managers/base_manager.dart';
import 'package:birdo/model/services/day_service.dart';
import 'package:flutter/foundation.dart';

/// Manager for Day state and single-domain operations.
///
/// Maintains in-memory day state and delegates persistence to DayService.
/// Cross-domain coordination belongs in controllers.
class DayManager extends BaseManager {
  final DateTimeService _dateTimeService;

  Day? _currentDay;

  List<Day> _historicalDays = [];

  DayManager({DateTimeService? dateTimeService})
    : _dateTimeService = dateTimeService ?? ServiceLocator.dateTimeService;

  Day? get currentDay => _currentDay;

  List<Day> get historicalDays => _historicalDays;

  bool get hasCheckedInToday => _currentDay?.hasCheckedIn() ?? false;

  @override
  Future<void> onInitialize() async {
    await loadCurrentDay();
    await loadHistoricalDays();
  }

  Future<void> loadCurrentDay() async {
    debugPrint('DayManager: Loading current day...');
    try {
      final currentDate = _dateTimeService.getCurrentDate();
      _currentDay = await DayService.getDayRecord(currentDate);

      if (_currentDay == null) {
        debugPrint(
          'DayManager: No day record found for today, creating new one',
        );
        _currentDay = await DayService.getOrCreate(currentDate);
      } else {
        debugPrint(
          'DayManager: Loaded day record for ${_currentDay!.getDateString()}',
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('DayManager: Error loading current day: $e');
    }
  }

  Future<void> loadHistoricalDays({int limit = 7}) async {
    debugPrint('DayManager: Loading historical days...');
    try {
      _historicalDays = await DayService.getHistoricalDays(limit: limit);
      debugPrint(
        'DayManager: Loaded ${_historicalDays.length} historical days',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('DayManager: Error loading historical days: $e');
    }
  }

  /// Get or create a Day record for the given date.
  Future<Day> getOrCreateDay(DateTime date) async {
    debugPrint('DayManager: Getting or creating day for ${date.toString()}');
    return await DayService.getOrCreate(date);
  }

  Future<void> checkIn() async {
    debugPrint('DayManager: Checking in for today...');
    try {
      final currentDate = _dateTimeService.getCurrentDate();
      await DayService.checkIn(currentDate);

      await loadCurrentDay();

      debugPrint('DayManager: Check-in successful');
    } catch (e) {
      debugPrint('DayManager: Error checking in: $e');
    }
  }

  Future<void> addRainbowStones(int amount) async {
    if (_currentDay == null) {
      debugPrint('DayManager: No current day to add rainbow stones to');
      return;
    }

    debugPrint('DayManager: Adding $amount rainbow stones to current day');
    try {
      final currentDate = _dateTimeService.getCurrentDate();
      await DayService.addRainbowStones(currentDate, amount);

      await loadCurrentDay();

      debugPrint('DayManager: Rainbow stones added successfully');
    } catch (e) {
      debugPrint('DayManager: Error adding rainbow stones: $e');
    }
  }

  Future<Day?> getDayRecord(DateTime date) async {
    debugPrint('DayManager: Getting day record for ${date.toString()}');
    try {
      return await DayService.getDayRecord(date);
    } catch (e) {
      debugPrint('DayManager: Error getting day record: $e');
      return null;
    }
  }

  Future<void> updateDayRecord(Day day) async {
    debugPrint('DayManager: Updating day record for ${day.getDateString()}');
    try {
      await DayService.saveDay(day);

      if (_currentDay != null && day.id == _currentDay!.id) {
        await loadCurrentDay();
      }

      await loadHistoricalDays();

      debugPrint('DayManager: Day record updated successfully');
    } catch (e) {
      debugPrint('DayManager: Error updating day record: $e');
    }
  }

  /// Add a task ID to the current day.
  Future<void> addTaskToDay(String taskId) async {
    if (_currentDay == null) {
      debugPrint('DayManager: No current day to add task to');
      return;
    }

    debugPrint('DayManager: Adding task $taskId to current day');
    try {
      final currentDate = _dateTimeService.getCurrentDate();
      await DayService.addTaskToDay(currentDate, taskId);
      await loadCurrentDay();

      debugPrint('DayManager: Task added to day successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('DayManager: Error adding task to day: $e');
    }
  }

  /// Add a task ID to a specific day.
  Future<void> addTaskToDayForDate(DateTime date, String taskId) async {
    debugPrint('DayManager: Adding task $taskId to day ${date.toString()}');
    try {
      await DayService.addTaskToDay(date, taskId);
      debugPrint('DayManager: Task added to day successfully');
    } catch (e) {
      debugPrint('DayManager: Error adding task to day: $e');
    }
  }

  /// Remove a task ID from a specific day.
  Future<void> removeTaskFromDay(DateTime date, String taskId) async {
    debugPrint('DayManager: Removing task $taskId from day ${date.toString()}');
    try {
      await DayService.removeTaskFromDay(date, taskId);
      debugPrint('DayManager: Task removed from day successfully');
    } catch (e) {
      debugPrint('DayManager: Error removing task from day: $e');
    }
  }

  /// Remove invalid task IDs from a day and save.
  Future<void> removeInvalidTaskIds(Day day, List<String> invalidTaskIds) async {
    if (invalidTaskIds.isEmpty) return;

    debugPrint('DayManager: Removing ${invalidTaskIds.length} invalid task IDs from day');
    day.dailyTaskIds.removeWhere((id) => invalidTaskIds.contains(id));
    await DayService.saveDay(day);
  }

  /// Add energy to the current day.
  Future<void> addEnergyToDay(int energyAmount) async {
    if (_currentDay == null) {
      debugPrint('DayManager: No current day to add energy to');
      return;
    }

    debugPrint('DayManager: Adding $energyAmount energy to current day');
    try {
      final currentDate = _dateTimeService.getCurrentDate();
      await DayService.addEnergyToDay(currentDate, energyAmount);
      debugPrint('DayManager: Added $energyAmount energy');

      await loadCurrentDay();

      debugPrint('DayManager: Energy added successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('DayManager: Error adding energy to day: $e');
    }
  }

  /// Remove energy from the current day.
  Future<void> removeEnergyFromDay(int energyAmount) async {
    if (_currentDay == null) {
      debugPrint('DayManager: No current day to remove energy from');
      return;
    }

    debugPrint('DayManager: Removing $energyAmount energy from current day');
    try {
      final currentDate = _dateTimeService.getCurrentDate();
      await DayService.addEnergyToDay(currentDate, -energyAmount);
      debugPrint('DayManager: Removed $energyAmount energy');

      await loadCurrentDay();

      debugPrint('DayManager: Energy removed successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('DayManager: Error removing energy from day: $e');
    }
  }

  int getTotalEnergy() {
    return _currentDay?.getTotalEnergy() ?? 0;
  }

  int getRainbowStonesEarned() {
    return _currentDay?.rainbowStonesEarned ?? 0;
  }
}
