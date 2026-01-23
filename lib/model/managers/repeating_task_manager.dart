import '../entities/repeating_task.dart';
import '../entities/task.dart';
import '../services/repeating_task_service.dart';
import 'base_manager.dart';

/// Manager for RepeatingTask state and operations.
///
/// Handles business logic for recurring task templates, following the
/// architecture pattern where Managers coordinate operations and Services
/// handle data persistence.
class RepeatingTaskManager extends BaseManager {
  List<RepeatingTask> _repeatingTasks = [];

  List<RepeatingTask> get repeatingTasks => List.unmodifiable(_repeatingTasks);

  @override
  Future<void> onInitialize() async {
    await loadRepeatingTasks();
  }

  Future<void> loadRepeatingTasks() async {
    _repeatingTasks = await RepeatingTaskService.getAllRepeatingTasks();
    notifyListeners();
  }

  Future<RepeatingTask?> getRepeatingTask(String id) async {
    return RepeatingTaskService.getRepeatingTask(id);
  }

  Future<void> createRepeatingTask({
    required String title,
    required int energyReward,
    required TaskCategory category,
    required List<int> repeatDayIndices,
  }) async {
    final task = await RepeatingTaskService.createRepeatingTask(
      title: title,
      energyReward: energyReward,
      category: category,
      repeatDayIndices: repeatDayIndices,
    );

    _repeatingTasks.add(task);
    notifyListeners();
  }

  Future<void> deleteRepeatingTask(String id) async {
    await RepeatingTaskService.deleteRepeatingTask(id);
    _repeatingTasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> updateRepeatingTask(RepeatingTask task) async {
    await RepeatingTaskService.updateRepeatingTask(task);
    await loadRepeatingTasks();
  }

  Future<void> deactivateRepeatingTask(String id) async {
    await RepeatingTaskService.deactivateRepeatingTask(id);
    await loadRepeatingTasks();
  }

  Future<void> activateRepeatingTask(String id) async {
    await RepeatingTaskService.activateRepeatingTask(id);
    await loadRepeatingTasks();
  }
}
