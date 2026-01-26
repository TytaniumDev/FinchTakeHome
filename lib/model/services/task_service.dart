import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

/// Service for Task persistence operations.
///
/// This service handles direct database operations for Task entities.
/// All business logic and cross-domain coordination belongs in
/// TaskController or TaskManager.
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

  /// Save a task to the database.
  static Future<void> saveTask(Task task) async {
    debugPrint('TaskService: Saving task: ${task.title} (${task.id})');
    final box = _getBox();
    await box.put(task.id, task);
  }

  /// Get a task by ID.
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

  /// Get multiple tasks by their IDs.
  /// Returns tasks in the same order as the IDs, skipping any not found.
  static Future<List<Task>> getTasksByIds(List<String> taskIds) async {
    debugPrint('TaskService: Getting ${taskIds.length} tasks by IDs');
    final tasks = <Task>[];
    final box = _getBox();

    for (var taskId in taskIds) {
      final task = box.get(taskId);
      if (task != null) {
        tasks.add(task);
      } else {
        debugPrint('TaskService: Task $taskId not found');
      }
    }

    debugPrint('TaskService: Found ${tasks.length} of ${taskIds.length} tasks');
    return tasks;
  }

  /// Get IDs of tasks that were not found in the database.
  static Future<List<String>> getInvalidTaskIds(List<String> taskIds) async {
    final invalidIds = <String>[];
    final box = _getBox();

    for (var taskId in taskIds) {
      final task = box.get(taskId);
      if (task == null) {
        invalidIds.add(taskId);
      }
    }

    return invalidIds;
  }

  /// Create and save a new task.
  /// Does not associate with any day - that coordination belongs in the controller.
  static Future<Task> createTask({
    required String title,
    required int energyReward,
    required TaskCategory category,
    String? repeatingTaskId,
  }) async {
    final task = Task.create(
      title: title,
      energyReward: energyReward,
      category: category,
      repeatingTaskId: repeatingTaskId,
    );

    await saveTask(task);
    debugPrint('TaskService: Created task: ${task.title} (${task.id})');
    return task;
  }

  /// Creates a Task instance from a RepeatingTask template.
  ///
  /// This creates a snapshot of the template at the time of creation.
  /// The Task instance is independent and won't auto-sync with template updates.
  static Future<Task> createTaskFromTemplate({
    required RepeatingTask template,
  }) async {
    final task = Task.create(
      title: template.title,
      energyReward: template.energyReward,
      category: template.category,
      repeatingTaskId: template.id,
    );

    await saveTask(task);
    debugPrint(
      'TaskService: Created task instance from template ${template.id}: ${task.id}',
    );
    return task;
  }

  /// Mark a task as complete and save.
  static Future<void> completeTask(Task task) async {
    debugPrint('TaskService: Completing task: ${task.id}');
    task.complete();
    await saveTask(task);
  }

  /// Reset a task (mark as incomplete) and save.
  static Future<void> resetTask(Task task) async {
    debugPrint('TaskService: Resetting task: ${task.id}');
    task.reset();
    await saveTask(task);
  }

  /// Update a task's properties and save.
  static Future<void> updateTask(Task task) async {
    debugPrint('TaskService: Updating task: ${task.title} (${task.id})');
    await saveTask(task);
  }

  /// Delete a task from the database.
  /// Does not handle day association - that coordination belongs in the controller.
  static Future<void> deleteTask(String taskId) async {
    debugPrint('TaskService: Deleting task: $taskId');
    final box = _getBox();
    await box.delete(taskId);
  }
}
