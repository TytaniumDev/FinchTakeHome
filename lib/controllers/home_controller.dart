import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/repeating_task_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:flutter/foundation.dart';

/// This controller coordinates between multiple managers to handle
/// user actions on the home screen.
/// This is essentially the "DayController".
class HomeController extends BaseController {
  final PetManager _petManager;
  final TaskManager _taskManager;
  final DayManager _dayManager;
  final RainbowStonesManager _rainbowStonesManager;
  final RepeatingTaskManager _repeatingTaskManager;

  /// Constructor
  HomeController({
    required PetManager petManager,
    required TaskManager taskManager,
    required DayManager dayManager,
    required RainbowStonesManager rainbowStonesManager,
    required RepeatingTaskManager repeatingTaskManager,
  }) : _petManager = petManager,
       _taskManager = taskManager,
       _dayManager = dayManager,
       _rainbowStonesManager = rainbowStonesManager,
       _repeatingTaskManager = repeatingTaskManager;

  @override
  Future<void> onInitialize() async {}

  /// Load all data needed for the home screen
  Future<void> loadHomeScreenData() async {
    try {
      await _petManager.checkDayTransition();
      await _petManager.loadCurrentPet();
      await _dayManager.loadCurrentDay();
      await loadTasks();
      await _rainbowStonesManager.loadRainbowStones();

      debugPrint('HomeController: Home screen data loaded successfully');
    } catch (e) {
      debugPrint('HomeController: Error loading home screen data: $e');
    }
  }

  /// Load tasks for the current day.
  /// Orchestrates fetching stored tasks and injecting recurring task instances.
  Future<void> loadTasks() async {
    final currentDate = ServiceLocator.dateTimeService.getCurrentDate();
    await _loadTasksForDateInternal(currentDate, isTimeTravel: false);
  }

  /// Load tasks for a specific day (time travel mode).
  /// Orchestrates fetching stored tasks and injecting recurring task instances.
  Future<void> loadTasksForDay(DateTime date) async {
    await _loadTasksForDateInternal(date, isTimeTravel: true);
  }

  /// Internal method to orchestrate loading tasks for a date.
  ///
  /// This is the key orchestration method that coordinates:
  /// 1. Getting/creating the Day record
  /// 2. Fetching stored tasks by ID
  /// 3. Getting active repeating task templates
  /// 4. Creating missing task instances from templates
  /// 5. Updating the TaskManager's state
  Future<void> _loadTasksForDateInternal(DateTime date, {required bool isTimeTravel}) async {
    debugPrint('HomeController: Loading tasks for ${ServiceLocator.dateTimeService.generateDayId(date)}');
    try {
      // 1. Get or create the Day record
      final day = await _dayManager.getOrCreateDay(date);
      debugPrint('HomeController: Found day record: ${day.id}');
      debugPrint('HomeController: Stored task IDs in day: ${day.dailyTaskIds.length}');

      // 2. Fetch stored tasks by their IDs
      final storedTasks = await _taskManager.getTasksByIds(day.dailyTaskIds);

      // 2a. Clean up invalid task IDs (tasks that no longer exist)
      final invalidTaskIds = await _taskManager.getInvalidTaskIds(day.dailyTaskIds);
      if (invalidTaskIds.isNotEmpty) {
        debugPrint('HomeController: Removing ${invalidTaskIds.length} invalid task IDs');
        await _dayManager.removeInvalidTaskIds(day, invalidTaskIds);
      }

      // 3. Get active repeating task templates from RepeatingTaskManager
      final repeatingTasks = _repeatingTaskManager.repeatingTasks
          .where((rt) => rt.isActive)
          .toList();

      // 4. Find templates that should appear on this weekday
      final weekdayInt = date.weekday;
      debugPrint('HomeController: Finding recurring task templates for weekday $weekdayInt');

      final templatesForToday = repeatingTasks.where(
        (rt) => rt.repeatDayIndices.contains(weekdayInt)
      ).toList();

      // 4a. Check which templates already have instances for today
      final existingRepeatingTaskIds = storedTasks
          .where((t) => t.repeatingTaskId != null)
          .map((t) => t.repeatingTaskId!)
          .toSet();

      // 4b. Build the final task list
      final allTasks = <Task>[...storedTasks];

      // 4c. Create missing task instances from templates
      bool dayNeedsUpdate = false;
      for (var template in templatesForToday) {
        if (!existingRepeatingTaskIds.contains(template.id)) {
          debugPrint('HomeController: Creating task instance from template: ${template.title} (${template.id})');

          // Create new task instance from template
          final newTask = await _taskManager.createTaskFromTemplate(template);

          allTasks.add(newTask);

          // Add task ID to day for tracking
          day.dailyTaskIds.add(newTask.id);
          dayNeedsUpdate = true;
        }
      }

      // 4d. Save day if we added new recurring task IDs
      if (dayNeedsUpdate) {
        await _dayManager.updateDayRecord(day);
        debugPrint('HomeController: Updated day with new recurring task IDs');
      }

      // 5. Update TaskManager's state
      _taskManager.setTasks(allTasks, date, isTimeTravel: isTimeTravel);

      debugPrint('HomeController: Loaded ${allTasks.length} tasks (${storedTasks.length} stored, ${templatesForToday.length} templates applicable)');
    } catch (e) {
      debugPrint('HomeController: Error loading tasks: $e');
    }
  }

  /// Handle daily check-in
  Future<void> performDailyCheckIn() async {
    try {
      // Check if already checked in
      if (_dayManager.hasCheckedInToday) {
        debugPrint('HomeController: Already checked in today');
        return;
      }

      // Perform check-in
      await _dayManager.checkIn();
      await _petManager.checkIn();

      // Award rainbow stones for check-in
      const int dailyCheckInReward = 5;
      await _rainbowStonesManager.awardDailyStones(dailyCheckInReward);
      await _dayManager.addRainbowStones(dailyCheckInReward);

      debugPrint('HomeController: Daily check-in completed successfully');
    } catch (e) {
      debugPrint('HomeController: Error performing daily check-in: $e');
    }
  }

  /// Evolve the pet if it's ready
  Future<void> evolvePet() async {
    try {
      if (!_petManager.isReadyToEvolve) {
        debugPrint('HomeController: Pet is not ready to evolve');
        return;
      }

      // Get the current growth stage before evolution
      final previousStage = _petManager.growthStage;

      // Evolve the pet
      await _petManager.evolvePet();

      // Award rainbow stones for evolution
      const int evolutionReward = 20;
      await _rainbowStonesManager.awardPetEvolutionStones(evolutionReward);
      await _dayManager.addRainbowStones(evolutionReward);

      debugPrint(
        'HomeController: Pet evolved from $previousStage to ${_petManager.growthStage}',
      );
    } catch (e) {
      debugPrint('HomeController: Error evolving pet: $e');
    }
  }

  PetGrowthStage? get petGrowthStage => _petManager.growthStage;

  double get energyPercentage => _petManager.energyPercentage;

  int get currentEnergy => _petManager.currentEnergy;

  int get maxEnergy => _petManager.maxEnergy;

  bool get isEnergyFull => _petManager.isEnergyFull;

  bool get isReadyToEvolve => _petManager.isReadyToEvolve;

  int get fullEnergyDays => _petManager.fullEnergyDays;

  int get rainbowStonesBalance => _rainbowStonesManager.currentBalance;

  List<Task> get tasks => _taskManager.tasks;

  bool isTaskCompleted(String taskId) => _taskManager.isTaskCompleted(taskId);

  bool get hasCheckedInToday => _dayManager.hasCheckedInToday;

  /// Force a complete app restart by reinitializing all managers
  /// This is used when clearing all data to ensure a clean state
  Future<void> forceAppRestart() async {
    try {
      // Reinitialize all managers
      await _petManager.initialize();
      await _taskManager.initialize();
      await _dayManager.initialize();
      await _rainbowStonesManager.initialize();

      // Reinitialize this controller
      await initialize();

      debugPrint('HomeController: App restarted successfully');
    } catch (e) {
      debugPrint('HomeController: Error restarting app: $e');
    }
  }
}
