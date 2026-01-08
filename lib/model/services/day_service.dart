import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class DayService {
  static bool _testMode = false;
  static Box<Day>? _testBox;

  static void enableTestMode([Box<Day>? testBox]) {
    _testMode = true;
    _testBox = testBox;
  }

  static void disableTestMode() {
    _testMode = false;
    _testBox = null;
  }

  static Box<Day> _getBox() {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box<Day>(dayBox);
  }

  static Future<void> saveDay(Day day) async {
    debugPrint('DayService: Saving day: ${day.id}');
    final box = _getBox();
    await box.put(day.id, day);
  }

  static Future<Day> getOrCreate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dayId = ServiceLocator.dateTimeService.generateDayId(normalizedDate);
    debugPrint('DayService: Getting/creating day for date: $dayId');

    final box = _getBox();
    var day = box.get(dayId);
    if (day == null) {
      debugPrint('DayService: Creating new day record');
      day = Day(
        id: dayId,
        date: normalizedDate,
        checkedIn: false,
        energy: 0,
        completedTaskIds: [],
        dailyTasks: [],
      );
      await saveDay(day);
      debugPrint('DayService: Created and saved new day record: ${day.id}');
    } else {
      debugPrint('DayService: Found existing day record: ${day.id}');
    }

    return day;
  }

  static Future<Day?> getDayRecord(DateTime date) async {
    debugPrint('DayService: Getting day record for date: $date');
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dayId = ServiceLocator.dateTimeService.generateDayId(normalizedDate);
    final box = _getBox();
    final day = box.get(dayId);
    if (day != null) {
      debugPrint('DayService: Found day record: ${day.id}');
    } else {
      debugPrint('DayService: Day record not found');
    }
    return day;
  }

  static Future<List<Day>> getHistoricalDays({int limit = 7}) async {
    debugPrint('DayService: Getting historical days (limit: $limit)');
    final now = DateTime.now();
    final days = <Day>[];

    for (var i = 0; i < limit; i++) {
      final date = now.subtract(Duration(days: i));
      final day = await getDayRecord(date);
      if (day != null) {
        days.add(day);
      }
    }

    debugPrint('DayService: Found ${days.length} historical days');
    return days;
  }

  static Future<void> checkIn(DateTime date) async {
    debugPrint('DayService: Checking in for date: $date');
    final day = await getOrCreate(date);

    day.checkIn();
    debugPrint('DayService: Day checked in: ${day.id}');

    await saveDay(day);
  }

  static Future<bool> hasCheckedInToday({DateTime? overrideDate}) async {
    final date =
        overrideDate ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint('DayService: Checking if checked in for date: $date');

    final day = await getDayRecord(date);
    final hasCheckedIn = day?.hasCheckedIn() ?? false;

    debugPrint('DayService: Has checked in: $hasCheckedIn');
    return hasCheckedIn;
  }

  static Future<void> addRainbowStones(DateTime date, int amount) async {
    debugPrint('DayService: Adding $amount rainbow stones for date: $date');
    final day = await getDayRecord(date);
    if (day != null) {
      day.addRainbowStones(amount);
      await saveDay(day);
      debugPrint('DayService: Rainbow stones added to day: ${day.id}');
    } else {
      debugPrint('DayService: Day not found, cannot add rainbow stones');
    }
  }

  static Future<void> completeTask(DateTime date, String taskId) async {
    debugPrint('DayService: Completing task $taskId for date: $date');
    final day = await getOrCreate(date);
    day.completeTask(taskId);
    await saveDay(day);
  }

  static Future<void> removeCompletedTask(DateTime date, String taskId) async {
    debugPrint('DayService: Removing completed task $taskId for date: $date');
    final day = await getDayRecord(date);
    if (day != null) {
      day.completedTaskIds.remove(taskId);
      await saveDay(day);
    }
  }

  static Future<void> addTaskToDay(DateTime date, Task task) async {
    debugPrint('DayService: Adding task ${task.id} to date: $date');
    final day = await getOrCreate(date);
    day.dailyTasks.add(task);
    await saveDay(day);
  }

  static Future<void> updateTaskInDay(DateTime date, Task task) async {
    debugPrint('DayService: Updating task ${task.id} in date: $date');
    final day = await getOrCreate(date);
    final taskIndex = day.dailyTasks.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      day.dailyTasks[taskIndex] = task;
      await saveDay(day);
    }
  }

  static Future<void> removeTaskFromDay(DateTime date, String taskId) async {
    debugPrint('DayService: Removing task $taskId from date: $date');
    final day = await getDayRecord(date);
    if (day != null) {
      day.dailyTasks.removeWhere((t) => t.id == taskId);
      await saveDay(day);
    }
  }

  static Future<void> addEnergyToDay(DateTime date, int amount) async {
    debugPrint('DayService: Adding $amount energy to date: $date');
    final day = await getOrCreate(date);
    day.addEnergy(amount);
    await saveDay(day);
  }
}
