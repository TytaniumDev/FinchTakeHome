import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/base_manager.dart';
import 'package:birdo/model/services/task_service.dart';
import 'package:flutter/foundation.dart';

class TaskManager extends BaseManager {
  final DateTimeService _dateTimeService;

  List<Task> _tasks = [];

  DateTime _currentDay;

  bool _isTimeTravel = false;

  TaskManager({DateTimeService? dateTimeService})
    : _dateTimeService = dateTimeService ?? ServiceLocator.dateTimeService,
      _currentDay = ServiceLocator.dateTimeService.getCurrentDate();

  List<Task> get tasks => _tasks;

  DateTime get currentDay => _currentDay;

  bool get isTimeTravel => _isTimeTravel;

  @override
  Future<void> onInitialize() async {
    await loadTasks();
  }

  Future<void> loadTasks() async {
    debugPrint('TaskManager: Loading tasks for current day...');
    try {
      _isTimeTravel = false;
      _currentDay = _dateTimeService.getCurrentDate();

      _tasks = await TaskService.getCurrentDayTasks();

      debugPrint('TaskManager: Loaded ${_tasks.length} tasks');
      for (var task in _tasks) {
        debugPrint('Task: ${task.title} (${task.id})');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('TaskManager: Error loading tasks: $e');
    }
  }

  Future<void> loadTasksForDay(DateTime date) async {
    debugPrint('TaskManager: Loading tasks for day: $date');
    try {
      _currentDay = date;
      _isTimeTravel = true;

      _tasks = await TaskService.getTasksForDay(date);

      debugPrint('TaskManager: Loaded ${_tasks.length} tasks for specific day');
      for (var task in _tasks) {
        debugPrint('Task: ${task.title} (${task.id})');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('TaskManager: Error loading tasks for day: $e');
    }
  }

  Future<void> completeTask(String taskId, {DateTime? date}) async {
    debugPrint('TaskManager: Completing task: $taskId');
    try {
      final targetDate = date ?? _currentDay;
      final task = await TaskService.getTask(taskId);
      if (task != null) {
        await TaskService.completeTask(task, date: targetDate);
      }
      debugPrint(
        'TaskManager: Task completed successfully for date: ${targetDate.toString()}',
      );

      if (_isTimeTravel || date != null) {
        await loadTasksForDay(targetDate);
      } else {
        await loadTasks();
      }
    } catch (e) {
      debugPrint('TaskManager: Error completing task: $e');
    }
  }

  Future<void> resetTask(String taskId, {DateTime? date}) async {
    debugPrint('TaskManager: Resetting task: $taskId');
    try {
      final targetDate = date ?? _currentDay;
      final task = await TaskService.getTask(taskId);
      if (task != null) {
        await TaskService.resetTask(task, date: targetDate);
      }
      debugPrint(
        'TaskManager: Task reset successfully for date: ${targetDate.toString()}',
      );

      if (_isTimeTravel || date != null) {
        await loadTasksForDay(targetDate);
      } else {
        await loadTasks();
      }
    } catch (e) {
      debugPrint('TaskManager: Error resetting task: $e');
    }
  }

  Future<void> createTask(
    String title,
    int energyReward,
    TaskCategory category, {
    DateTime? date,
  }) async {
    debugPrint('TaskManager: Creating task: $title');
    try {
      final targetDate = date ?? _currentDay;
      final task = await TaskService.createTask(
        title: title,
        energyReward: energyReward,
        category: category,
        date: targetDate,
      );
      debugPrint('TaskManager: Created task: ${task.title} (${task.id})');

      if (_isTimeTravel || date != null) {
        await loadTasksForDay(targetDate);
      } else {
        await loadTasks();
      }
    } catch (e) {
      debugPrint('TaskManager: Error creating task: $e');
    }
  }

  Future<void> updateTask(
    String taskId,
    String title,
    int energyReward,
    TaskCategory category, {
    DateTime? date,
  }) async {
    debugPrint('TaskManager: Updating task: $taskId');
    try {
      final targetDate = date ?? _currentDay;
      final task = await TaskService.getTask(taskId);
      if (task != null) {
        task.title = title;
        task.energyReward = energyReward;
        task.category = category;
        await TaskService.updateTask(task, date: targetDate);
        debugPrint(
          'TaskManager: Task updated successfully for date: ${targetDate.toString()}',
        );
      }

      if (_isTimeTravel || date != null) {
        await loadTasksForDay(targetDate);
      } else {
        await loadTasks();
      }
    } catch (e) {
      debugPrint('TaskManager: Error updating task: $e');
    }
  }

  Future<Task?> getTask(String taskId) async {
    return TaskService.getTask(taskId);
  }

  Future<void> deleteTask(String taskId, {DateTime? date}) async {
    debugPrint('TaskManager: Deleting task: $taskId');
    try {
      final targetDate = date ?? _currentDay;
      final task = await TaskService.getTask(taskId);
      if (task != null) {
        await TaskService.deleteTask(task, date: targetDate);
      }

      if (_isTimeTravel || date != null) {
        await loadTasksForDay(targetDate);
      } else {
        await loadTasks();
      }
    } catch (e) {
      debugPrint('TaskManager: Error deleting task: $e');
    }
  }
}
