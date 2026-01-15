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

  // Shouldn't this not have knowledge of DayService? This feels like it should go in the manager instead.
  static Future<List<Task>> getTasksForDay(DateTime date) async {
    debugPrint(
      'TaskService: Getting tasks for day: ${ServiceLocator.dateTimeService.generateDayId(date)}',
    );
    final day = await DayService.getOrCreate(date);
    debugPrint('TaskService: Found day record: ${day.id}');
    debugPrint(
      'TaskService: Number of stored task IDs in day: ${day.dailyTaskIds.length}',
    );

    // Fetch Task objects for stored IDs (non-recurring + previously seen recurring)
    final storedTasks = <Task>[];
    final invalidTaskIds = <String>[];
    
    for (var taskId in day.dailyTaskIds) {
      final task = await getTask(taskId);
      if (task != null) {
        storedTasks.add(task);
      } else {
        debugPrint('TaskService: Task $taskId not found, marking for removal');
        invalidTaskIds.add(taskId);
      }
    }

    // Remove invalid task IDs
    if (invalidTaskIds.isNotEmpty) {
      day.dailyTaskIds.removeWhere((id) => invalidTaskIds.contains(id));
      await DayService.saveDay(day);
    }

    // Find recurring tasks that should appear on this weekday
    final weekdayInt = day.date.weekday;
    debugPrint(
      'TaskService: Finding recurring tasks for weekday # $weekdayInt',
    );
    final recurringTasksForDay = _getBox().values.where((task) {
      if (task.repeatDayIndices != null && task.repeatDayIndices!.isNotEmpty) {
        return task.repeatDayIndices!.contains(weekdayInt);
      }
      return false;
    }).toList();

    // Track which task IDs we've already included
    final includedTaskIds = <String>{};
    final allTasks = <Task>[];

    // Add stored tasks (non-recurring + previously seen recurring)
    for (var task in storedTasks) {
      includedTaskIds.add(task.id);
      allTasks.add(task);
    }

    // Add new recurring tasks (not already in day.dailyTaskIds)
    bool dayNeedsUpdate = false;
    for (var recurringTask in recurringTasksForDay) {
      if (!includedTaskIds.contains(recurringTask.id)) {
        debugPrint(
          'TaskService: Adding recurring task: ${recurringTask.title} (${recurringTask.id})',
        );
        includedTaskIds.add(recurringTask.id);
        allTasks.add(recurringTask);
        
        // Store recurring task ID in day for historical tracking
        if (!day.dailyTaskIds.contains(recurringTask.id)) {
          day.dailyTaskIds.add(recurringTask.id);
          dayNeedsUpdate = true;
        }
      }
    }

    // Save day if we added new recurring task IDs
    if (dayNeedsUpdate) {
      await DayService.saveDay(day);
      debugPrint('TaskService: Updated day with new recurring task IDs');
    }

    debugPrint(
      'TaskService: Returning ${allTasks.length} tasks (${storedTasks.length} stored, ${recurringTasksForDay.length} recurring)',
    );
    return allTasks;
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
    debugPrint('TaskService: Current task IDs in day: ${day.dailyTaskIds.length}');

    await DayService.addTaskToDay(targetDate, task.id);
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

    await saveTask(task);
    // No need to update Day - task is stored separately
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
