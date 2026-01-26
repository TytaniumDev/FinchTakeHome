import 'package:hive_ce/hive.dart';
import '../entities/repeating_task.dart';
import '../entities/task.dart';

/// Service layer for RepeatingTask persistence operations.
///
/// This service provides CRUD operations for RepeatingTask templates.
/// Per architecture guidelines, this is a thin data access layer - business
/// logic belongs in RepeatingTaskManager.
class RepeatingTaskService {
  static const String boxName = 'repeatingTasks';

  static bool _testMode = false;
  static Box<RepeatingTask>? _testBox;

  static void enableTestMode(Box<RepeatingTask> testBox) {
    _testMode = true;
    _testBox = testBox;
  }

  static void disableTestMode() {
    _testMode = false;
    _testBox = null;
  }

  static Box<RepeatingTask> _getBox() {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box<RepeatingTask>(boxName);
  }

  /// Creates and persists a new RepeatingTask template.
  static Future<RepeatingTask> createRepeatingTask({
    required String title,
    required int energyReward,
    required TaskCategory category,
    required List<int> repeatDayIndices,
  }) async {
    final task = RepeatingTask.create(
      title: title,
      energyReward: energyReward,
      category: category,
      repeatDayIndices: repeatDayIndices,
    );

    await saveRepeatingTask(task);
    return task;
  }

  /// Saves a RepeatingTask template to the database.
  static Future<void> saveRepeatingTask(RepeatingTask task) async {
    final box = _getBox();
    await box.put(task.id, task);
  }

  /// Retrieves a RepeatingTask template by ID.
  static Future<RepeatingTask?> getRepeatingTask(String id) async {
    final box = _getBox();
    return box.get(id);
  }

  /// Returns all active RepeatingTask templates.
  static Future<List<RepeatingTask>> getAllActiveRepeatingTasks() async {
    final box = _getBox();
    // Convert to list first to ensure we get all values, then filter
    final allTasks = box.values.toList();
    return allTasks.where((task) => task.isActive).toList();
  }

  /// Returns all RepeatingTask templates (active and inactive).
  static Future<List<RepeatingTask>> getAllRepeatingTasks() async {
    final box = _getBox();
    return box.values.toList();
  }

  /// Deletes a RepeatingTask template permanently.
  static Future<void> deleteRepeatingTask(String id) async {
    final box = _getBox();
    await box.delete(id);
  }

  /// Updates an existing RepeatingTask template.
  static Future<void> updateRepeatingTask(RepeatingTask task) async {
    final box = _getBox();
    await box.put(task.id, task);
  }

  /// Deactivates a RepeatingTask template (soft delete).
  ///
  /// The template remains in the database but won't generate new task instances.
  static Future<void> deactivateRepeatingTask(String id) async {
    final task = await getRepeatingTask(id);
    if (task != null) {
      task.isActive = false;
      await updateRepeatingTask(task);
    }
  }

  /// Activates a previously deactivated RepeatingTask template.
  static Future<void> activateRepeatingTask(String id) async {
    final task = await getRepeatingTask(id);
    if (task != null) {
      task.isActive = true;
      await updateRepeatingTask(task);
    }
  }
}
