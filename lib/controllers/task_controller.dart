import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/core/constants/rewards.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/repeating_task_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:flutter/foundation.dart';

/// Controller for coordinating task-related operations across multiple managers.
///
/// This controller handles the orchestration of loading tasks for a day,
/// including injecting recurring task instances from templates. It coordinates
/// between TaskManager, DayManager, and RepeatingTaskManager.
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

  /// Complete a task and add energy to the pet and day.
  Future<void> completeTask(String taskId, {DateTime? date}) async {
    try {
      // Get the task to determine energy reward
      final task = await _taskManager.getTask(taskId);
      if (task == null) {
        debugPrint('TaskController: Task not found: $taskId');
        return;
      }

      // Complete the task
      await _taskManager.completeTask(taskId);

      // Add energy to the pet
      await _petManager.addEnergy(task.energyReward.toDouble());

      // Update day record
      await _dayManager.addEnergyToDay(task.energyReward);

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

  /// Un-complete a task (mark as incomplete).
  Future<void> uncompleteTask(String taskId, {DateTime? date}) async {
    try {
      // Get the task to determine energy reward
      final task = await _taskManager.getTask(taskId);
      if (task == null) {
        debugPrint('TaskController: Task not found: $taskId');
        return;
      }
      await _taskManager.resetTask(taskId);

      // Remove energy from the pet
      await _petManager.removeEnergy(task.energyReward.toDouble());

      // Update day record
      await _dayManager.removeEnergyFromDay(task.energyReward);

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
      debugPrint('TaskController: Error uncompleting task: $e');
    }
  }

  /// Reset a task (mark as incomplete).
  Future<void> resetTask(String taskId, {DateTime? date}) async {
    await _taskManager.resetTask(taskId);
  }

  /// Create a new one-time task and associate it with a day.
  Future<void> createTask(
    String title,
    int energyReward,
    TaskCategory category, {
    DateTime? date,
  }) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint('TaskController: Creating task: $title for ${ServiceLocator.dateTimeService.generateDayId(targetDate)}');

    try {
      // Create the task
      final task = await _taskManager.createTask(
        title: title,
        energyReward: energyReward,
        category: category,
      );

      // Associate task with the day
      await _dayManager.addTaskToDayForDate(targetDate, task.id);

      // Add task to local list
      _taskManager.addTaskToList(task);

      debugPrint('TaskController: Created task: ${task.title} (${task.id})');
    } catch (e) {
      debugPrint('TaskController: Error creating task: $e');
    }
  }

  /// Create a new recurring task template.
  /// If today matches the repeat schedule, also creates a task instance for today.
  Future<void> createRepeatingTask(
    String title,
    int energyReward,
    TaskCategory category,
    List<int> repeatDayIndices,
  ) async {
    final currentDate = ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint('TaskController: Creating repeating task: $title');

    try {
      // Create the template and get it back
      final template = await _repeatingTaskManager.createRepeatingTask(
        title: title,
        energyReward: energyReward,
        category: category,
        repeatDayIndices: repeatDayIndices,
      );

      // Check if today matches the repeat schedule
      final currentWeekday = currentDate.weekday;
      if (repeatDayIndices.contains(currentWeekday)) {
        debugPrint('TaskController: Today matches repeat schedule, creating task instance');

        // Create a task instance from the template
        final task = await _taskManager.createTaskFromTemplate(template);

        // Add the task to the current day
        await _dayManager.addTaskToDayForDate(currentDate, task.id);

        // Add task to the UI list
        _taskManager.addTaskToList(task);
      }
    } catch (e) {
      debugPrint('TaskController: Error creating repeating task: $e');
    }
  }

  /// Update an existing task instance (disconnects from template if it was linked).
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
    );
  }

  /// Update a recurring task template (affects all future instances).
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
  }

  /// Delete a task instance.
  Future<void> deleteTask(String taskId, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint('TaskController: Deleting task: $taskId from ${ServiceLocator.dateTimeService.generateDayId(targetDate)}');

    try {
      // Remove task from day
      await _dayManager.removeTaskFromDay(targetDate, taskId);

      // Delete the task
      await _taskManager.deleteTask(taskId);

      debugPrint('TaskController: Task deleted: $taskId');
    } catch (e) {
      debugPrint('TaskController: Error deleting task: $e');
    }
  }

  /// Delete a recurring task template (stops creating new instances).
  Future<void> deleteRepeatingTask(String repeatingTaskId) async {
    await _repeatingTaskManager.deleteRepeatingTask(repeatingTaskId);
  }
}
