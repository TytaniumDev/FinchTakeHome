import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/services/day_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class TaskService {
  static bool _testMode = false;
  static Box<Task>? _testBox;

  static void enableTestMode(Box<Task> testBox) {
    _testMode = true;
    _testBox = testBox;
  }

  static void disableTestMode() {
    _testMode = false;
    _testBox = null;
  }

  static Box<Task> _getBox() {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box<Task>(taskBox);
  }

  static Future<void> saveTask(Task task) async {
    debugPrint('TaskService: Saving task: ${task.title} (${task.id})');
    final box = _getBox();
    await box.put(task.id, task);
  }

  static Future<Task?> getTask(String taskId) async {
    debugPrint('TaskService: Getting task: $taskId');
    try {
      final box = _getBox();
      final task = box.get(taskId);
      if (task != null) {
        debugPrint('TaskService: Found task: ${task.title} (${task.id})');
      } else {
        debugPrint('TaskService: Task not found');
      }
      return task;
    } catch (e) {
      debugPrint('TaskService: Error getting task: $e');
      return null;
    }
  }
  
  static Future<List<Task>> getCurrentDayTasks() async {
    debugPrint('TaskService: Getting current day tasks...');
    final currentDate = ServiceLocator.dateTimeService.getCurrentDate();
    return getTasksForDay(currentDate);
  }

  // TODO: Update test for this method
  // Shouldn't this not have knowledge of DayService? This feels like it should go in the manager instead.
  static Future<List<Task>> getTasksForDay(DateTime date) async {
    debugPrint(
      'TaskService: Getting tasks for day: ${ServiceLocator.dateTimeService.generateDayId(date)}',
    );
    final day = await DayService.getOrCreate(date);
    debugPrint('TaskService: Found day record: ${day.id}');
    debugPrint(
      'TaskService: Number of non-repeat tasks in day: ${day.dailyTasks.length}',
    );

    // Grab only tasks that have a repeat day on this day.
    final weekdayInt = day.date.weekday;
    debugPrint(
      'TaskService: Finding repeating tasks for weekday # $weekdayInt',
    );
    final repeatTasksForDay = _getBox().values.where((task) {
      if (task.repeatDayIndices != null) {
        final repeatDayIndices = task.repeatDayIndices!;
        return repeatDayIndices
            .where((dayIndex) => dayIndex == weekdayInt)
            .isNotEmpty;
      }
      return false;
    }).toList();

    // Add repeating tasks if they aren't already in the day's task list.
    for (var repeatTask in repeatTasksForDay) {
      final alreadyInDay = day.dailyTasks.any(
        (task) => task.id == repeatTask.id,
      );
      if (!alreadyInDay) {
        debugPrint(
          'TaskService: Adding repeating task to day: ${repeatTask.title} (${repeatTask.id})',
        );
        day.dailyTasks.add(repeatTask);
      } else {
        debugPrint(
          'TaskService: Repeating task already in day: ${repeatTask.title} (${repeatTask.id})',
        );
      }
    }

    debugPrint(
      'TaskService: Number of total tasks in day: ${day.dailyTasks.length}',
    );

    if (day.dailyTasks.isEmpty) {
      debugPrint('TaskService: No tasks found for this day');
      return [];
    }

    debugPrint('TaskService: Returning ${day.dailyTasks.length} tasks');
    for (var task in day.dailyTasks) {
      debugPrint('TaskService: Task: ${task.title} (${task.id})');
    }
    return day.dailyTasks;
  }

  static Future<Task> createTask({
    required String title,
    required int energyReward,
    required TaskCategory category,
    DateTime? date,
    List<int>? repeatDayIndices,
  }) async {
    final task = Task.create(
      title: title,
      energyReward: energyReward,
      category: category,
      repeatDayIndices: repeatDayIndices,
    );

    await saveTask(task);
    debugPrint('TaskService: Saved task to taskBox');

    // With repeated tasks, the first task day may not be today.
    // Only add to the day if the task is meant to appear today.
    if (repeatDayIndices != null && repeatDayIndices.isNotEmpty) {
      final todayWeekday = ServiceLocator.dateTimeService
          .getCurrentDate()
          .weekday;
      final appearsToday = repeatDayIndices.any(
        (dayIndex) => dayIndex == todayWeekday,
      );
      if (!appearsToday) {
        debugPrint(
          'TaskService: Task does not repeat today, skipping adding to day record',
        );
        return task;
      }
    }

    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Creating task: ${task.title} (${task.id}) for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    final day = await DayService.getOrCreate(targetDate);
    debugPrint('TaskService: Found day record: ${day.id}');
    debugPrint('TaskService: Current tasks in day: ${day.dailyTasks.length}');

    await DayService.addTaskToDay(targetDate, task);
    debugPrint('TaskService: Added task to day using DayService');

    return task;
  }

  static Future<void> completeTask(Task task, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Completing task: ${task.id} for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    task.complete();
    await saveTask(task);

    await DayService.completeTask(targetDate, task.id);
  }

  static Future<void> resetTask(Task task, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Resetting task: ${task.id} for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    task.reset();
    await saveTask(task);

    await DayService.removeCompletedTask(targetDate, task.id);
  }

  static Future<void> updateTask(Task task, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Updating task: ${task.title} (${task.id}) for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    await DayService.updateTaskInDay(targetDate, task);

    await saveTask(task);
  }

  static Future<void> deleteTask(Task task, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Deleting task: ${task.id} for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    await DayService.removeTaskFromDay(targetDate, task.id);

    final box = _getBox();
    await box.delete(task.id);
  }
}
