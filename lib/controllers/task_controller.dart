import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/core/constants/rewards.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/repeating_task_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:flutter/foundation.dart';

/// This controller coordinates between the TaskManager and other components
/// of the system, handling user actions related to tasks.
class TaskController extends BaseController {
  final TaskManager _taskManager;
  final RepeatingTaskManager _repeatingTaskManager;
  final PetManager _petManager;
  final DayManager _dayManager;
  final RainbowStonesManager _rainbowStonesManager;

  TaskController({
    required TaskManager taskManager,
    required RepeatingTaskManager repeatingTaskManager,
    required PetManager petManager,
    required DayManager dayManager,
    required RainbowStonesManager rainbowStonesManager,
  }) : _taskManager = taskManager,
       _repeatingTaskManager = repeatingTaskManager,
       _petManager = petManager,
       _dayManager = dayManager,
       _rainbowStonesManager = rainbowStonesManager;

  @override
  Future<void> onInitialize() async {}

  /// Load tasks for the current day
  Future<void> loadTasks() async {
    await _taskManager.loadTasks();
  }

  /// Load tasks for a specific day
  Future<void> loadTasksForDay(DateTime date) async {
    await _taskManager.loadTasksForDay(date);
  }

  /// Complete a task and add energy to the pet and day
  Future<void> completeTask(String taskId, {DateTime? date}) async {
    try {
      // Get the task to determine energy reward
      final task = await _taskManager.getTask(taskId);
      if (task == null) {
        debugPrint('TaskController: Task not found: $taskId');
        return;
      }

      // Complete the task
      await _taskManager.completeTask(taskId, date: date);

      // Add energy to the pet
      await _petManager.addEnergy(task.energyReward.toDouble());

      // Update day record (pass energy reward to avoid DayManager fetching task)
      await _dayManager.completeTask(taskId, energyReward: task.energyReward);

      // Award rainbow stones for task completion (if applicable)
      if (task.category == TaskCategory.productivity) {
        await _rainbowStonesManager.awardTaskCompletionStones(
          productivityTaskCompletionReward,
        );
        await _dayManager.addRainbowStones(productivityTaskCompletionReward);
      }

      // Award additional rainbow stones if the task is a repeating task instance
      if (task.repeatingTaskId != null) {
        await _rainbowStonesManager.awardTaskCompletionStones(
          repeatedTaskCompletionReward,
        );
        await _dayManager.addRainbowStones(repeatedTaskCompletionReward);
      }

      debugPrint(
        'TaskController: Task completed and energy added to pet and day: $taskId',
      );
    } catch (e) {
      debugPrint('TaskController: Error completing task: $e');
    }
  }

  /// Un-complete a task (mark as incomplete)
  Future<void> uncompleteTask(String taskId, {DateTime? date}) async {
    try {
      // Get the task to determine energy reward
      final task = await _taskManager.getTask(taskId);
      if (task == null) {
        debugPrint('TaskController: Task not found: $taskId');
        return;
      }
      await _taskManager.resetTask(taskId, date: date);

      // Remove energy from the pet
      await _petManager.removeEnergy(task.energyReward.toDouble());

      // Update day record (pass energy reward to avoid DayManager fetching task)
      await _dayManager.uncompleteTask(taskId, energyReward: task.energyReward);

      // Remove rainbow stones for task completion (if applicable)
      if (task.category == TaskCategory.productivity) {
        await _rainbowStonesManager.removeTaskCompletionStones(
          productivityTaskCompletionReward,
        );
        await _dayManager.addRainbowStones(-productivityTaskCompletionReward);
      }

      // Remove additional rainbow stones if the task is a repeating task instance
      if (task.repeatingTaskId != null) {
        await _rainbowStonesManager.removeTaskCompletionStones(
          repeatedTaskCompletionReward,
        );
        await _dayManager.addRainbowStones(-repeatedTaskCompletionReward);
      }

    } catch (e) {
      debugPrint('TaskController: Error completing task: $e');
    }
  }

  /// Reset a task (mark as incomplete)
  Future<void> resetTask(String taskId, {DateTime? date}) async {
    await _taskManager.resetTask(taskId, date: date);
  }

  /// Create a new one-time task
  Future<void> createTask(
    String title,
    int energyReward,
    TaskCategory category, {
    DateTime? date,
  }) async {
    await _taskManager.createTask(
      title,
      energyReward,
      category,
      date: date,
    );
  }

  /// Create a new recurring task template
  Future<void> createRepeatingTask(
    String title,
    int energyReward,
    TaskCategory category,
    List<int> repeatDayIndices,
  ) async {
    // Create the template
    await _repeatingTaskManager.createRepeatingTask(
      title: title,
      energyReward: energyReward,
      category: category,
      repeatDayIndices: repeatDayIndices,
    );

    // Reload tasks for current day (may create instance if today matches)
    await _taskManager.loadTasks();
  }

  /// Update an existing task instance (disconnects from template if it was linked)
  Future<void> updateTask(
    String taskId,
    String title,
    int energyReward,
    TaskCategory category, {
    DateTime? date,
  }) async {
    // Get the task to disconnect it from template
    final task = await _taskManager.getTask(taskId);
    if (task != null && task.repeatingTaskId != null) {
      // Disconnect from template by setting repeatingTaskId to null
      task.repeatingTaskId = null;
    }

    await _taskManager.updateTask(
      taskId,
      title,
      energyReward,
      category,
      date: date,
    );
  }

  /// Update a recurring task template (affects all future instances)
  Future<void> updateRepeatingTask(
    String repeatingTaskId,
    String title,
    int energyReward,
    TaskCategory category,
    List<int> repeatDayIndices,
  ) async {
    final template = await _repeatingTaskManager.getRepeatingTask(repeatingTaskId);
    if (template == null) {
      debugPrint('TaskController: Repeating task template not found: $repeatingTaskId');
      return;
    }

    template.title = title;
    template.energyReward = energyReward;
    template.category = category;
    template.repeatDayIndices = repeatDayIndices;

    await _repeatingTaskManager.updateRepeatingTask(template);
    await _taskManager.loadTasks(); // Refresh to show changes
  }

  /// Delete a task instance
  Future<void> deleteTask(String taskId, {DateTime? date}) async {
    await _taskManager.deleteTask(taskId, date: date);
  }

  /// Delete a recurring task template (stops creating new instances)
  Future<void> deleteRepeatingTask(String repeatingTaskId) async {
    await _repeatingTaskManager.deleteRepeatingTask(repeatingTaskId);
    await _taskManager.loadTasks(); // Refresh display
  }
}
