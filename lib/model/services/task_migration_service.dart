import 'package:birdo/core/constants/hive_boxes.dart' as boxes;
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/services/repeating_task_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Service for migrating existing tasks with repeatDayIndices to the new RepeatingTask system
class TaskMigrationService {
  /// Migrate all existing tasks with repeatDayIndices to RepeatingTask templates
  static Future<void> migrateRecurringTasks() async {
    debugPrint('TaskMigrationService: Starting migration of recurring tasks...');

    try {
      final taskBox = Hive.box<Task>(boxes.taskBox);
      final tasks = taskBox.values.toList();

      int migratedCount = 0;

      for (var task in tasks) {
        // Find tasks with old repeatDayIndices field
        if (task.repeatDayIndices != null && task.repeatDayIndices!.isNotEmpty) {
          debugPrint('TaskMigrationService: Found task with repeatDayIndices: ${task.title}');

          // Create RepeatingTask template
          final repeatingTask = await RepeatingTaskService.createRepeatingTask(
            title: task.title,
            energyReward: task.energyReward,
            category: task.category,
            repeatDayIndices: task.repeatDayIndices!,
          );

          debugPrint('TaskMigrationService: Created RepeatingTask template: ${repeatingTask.id}');

          // Update existing task to link to template
          task.repeatingTaskId = repeatingTask.id;
          task.repeatDayIndices = null; // Clear old field
          await task.save();

          migratedCount++;
          debugPrint('TaskMigrationService: Migrated task: ${task.title}');
        }
      }

      debugPrint('TaskMigrationService: Migration complete. Migrated $migratedCount tasks.');
    } catch (e) {
      debugPrint('TaskMigrationService: Error during migration: $e');
    }
  }
}
