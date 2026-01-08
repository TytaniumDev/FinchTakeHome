import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/base_manager.dart';
import 'package:birdo/model/services/day_service.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> addTaskToDay(Task task) async {
    if (_currentDay == null) {
      debugPrint('DayManager: No current day to add task to');
      return;
    }

    debugPrint('DayManager: Adding task ${task.id} to current day');
    try {
      final currentDate = _dateTimeService.getCurrentDate();
      await DayService.addTaskToDay(currentDate, task);
      await loadCurrentDay();

      debugPrint('DayManager: Task added to day successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('DayManager: Error adding task to day: $e');
    }
  }

  Future<void> completeTask(String taskId) async {
    if (_currentDay == null) {
      debugPrint('DayManager: No current day to complete task for');
      return;
    }

    debugPrint('DayManager: Completing task $taskId for current day');
    try {
      final currentDate = _dateTimeService.getCurrentDate();

      await DayService.completeTask(currentDate, taskId);

      Task? task;
      for (var t in _currentDay!.dailyTasks) {
        if (t.id == taskId) {
          task = t;
          break;
        }
      }

      if (task != null) {
        await DayService.addEnergyToDay(currentDate, task.energyReward);
        debugPrint('DayManager: Added ${task.energyReward} energy from task');
      }

      await loadCurrentDay();

      debugPrint('DayManager: Task completed successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('DayManager: Error completing task: $e');
    }
  }

  bool isTaskCompleted(String taskId) {
    return _currentDay?.isTaskCompleted(taskId) ?? false;
  }

  int getTotalEnergy() {
    return _currentDay?.getTotalEnergy() ?? 0;
  }

  int getRainbowStonesEarned() {
    return _currentDay?.rainbowStonesEarned ?? 0;
  }
}
