import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/managers/base_manager.dart';
import 'package:birdo/model/services/task_service.dart';
import 'package:flutter/foundation.dart';

/// Manager for Task state and single-domain operations.
///
/// Maintains in-memory task state and delegates persistence to TaskService.
/// Cross-domain coordination (with DayManager, RepeatingTaskManager) belongs
/// in TaskController.
class TaskManager extends BaseManager {
  List<Task> _tasks = [];

  DateTime? _currentDay;

  bool _isTimeTravel = false;

  TaskManager();

  List<Task> get tasks => _tasks;

  DateTime? get currentDay => _currentDay;

  bool get isTimeTravel => _isTimeTravel;

  /// Returns a new list of completed tasks (where isCompleted == true).
  /// Returns a new list instance each time to trigger proper UI rebuilds.
  List<Task> get completedTasks =>
      List<Task>.from(_tasks.where((t) => t.isCompleted));

  /// Returns the count of completed tasks.
  int get completedTaskCount => _tasks.where((t) => t.isCompleted).length;

  /// Checks if a specific task is completed.
  bool isTaskCompleted(String taskId) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      return task.isCompleted;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> onInitialize() async {
    // Just initialize state - actual loading is done by TaskController
    // _currentDay will be set when setTasks() is called
  }

  /// Set the tasks list and current day. Called by TaskController after orchestration.
  void setTasks(List<Task> tasks, DateTime date, {bool isTimeTravel = false}) {
    _tasks = tasks;
    _currentDay = date;
    _isTimeTravel = isTimeTravel;
    notifyListeners();
  }

  /// Get a task by ID from the service.
  Future<Task?> getTask(String taskId) async {
    return TaskService.getTask(taskId);
  }

  /// Get multiple tasks by their IDs.
  Future<List<Task>> getTasksByIds(List<String> taskIds) async {
    return TaskService.getTasksByIds(taskIds);
  }

  /// Get IDs of tasks that don't exist in the database.
  Future<List<String>> getInvalidTaskIds(List<String> taskIds) async {
    return TaskService.getInvalidTaskIds(taskIds);
  }

  /// Complete a task (mark as complete and save).
  Future<void> completeTask(String taskId) async {
    debugPrint('TaskManager: Completing task: $taskId');
    try {
      final task = await TaskService.getTask(taskId);
      if (task != null) {
        await TaskService.completeTask(task);
        // Update local state
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index >= 0) {
          _tasks[index] = task;
          notifyListeners();
        }
      }
      debugPrint('TaskManager: Task completed successfully');
    } catch (e) {
      debugPrint('TaskManager: Error completing task: $e');
    }
  }

  /// Reset a task (mark as incomplete and save).
  Future<void> resetTask(String taskId) async {
    debugPrint('TaskManager: Resetting task: $taskId');
    try {
      final task = await TaskService.getTask(taskId);
      if (task != null) {
        await TaskService.resetTask(task);
        // Update local state
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index >= 0) {
          _tasks[index] = task;
          notifyListeners();
        }
      }
      debugPrint('TaskManager: Task reset successfully');
    } catch (e) {
      debugPrint('TaskManager: Error resetting task: $e');
    }
  }

  /// Create a new task (does not associate with day - that's done by controller).
  Future<Task> createTask({
    required String title,
    required int energyReward,
    required TaskCategory category,
    String? repeatingTaskId,
  }) async {
    debugPrint('TaskManager: Creating task: $title');
    final task = await TaskService.createTask(
      title: title,
      energyReward: energyReward,
      category: category,
      repeatingTaskId: repeatingTaskId,
    );
    debugPrint('TaskManager: Created task: ${task.title} (${task.id})');
    return task;
  }

  /// Create a task from a repeating task template.
  Future<Task> createTaskFromTemplate(RepeatingTask template) async {
    debugPrint('TaskManager: Creating task from template: ${template.title}');
    final task = await TaskService.createTaskFromTemplate(template: template);
    debugPrint('TaskManager: Created task from template: ${task.id}');
    return task;
  }

  /// Update a task's properties.
  Future<void> updateTask(
    String taskId,
    String title,
    int energyReward,
    TaskCategory category,
  ) async {
    debugPrint('TaskManager: Updating task: $taskId');
    try {
      final task = await TaskService.getTask(taskId);
      if (task != null) {
        task.title = title;
        task.energyReward = energyReward;
        task.category = category;
        await TaskService.updateTask(task);
        // Update local state
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index >= 0) {
          _tasks[index] = task;
          notifyListeners();
        }
        debugPrint('TaskManager: Task updated successfully');
      }
    } catch (e) {
      debugPrint('TaskManager: Error updating task: $e');
    }
  }

  /// Delete a task (does not handle day - that's done by controller).
  Future<void> deleteTask(String taskId) async {
    debugPrint('TaskManager: Deleting task: $taskId');
    try {
      await TaskService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      debugPrint('TaskManager: Task deleted successfully');
    } catch (e) {
      debugPrint('TaskManager: Error deleting task: $e');
    }
  }

  /// Add a task to the local tasks list and notify listeners.
  void addTaskToList(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  /// Remove a task from the local tasks list.
  void removeTaskFromList(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }
}
