import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:flutter/foundation.dart';

/// This controller coordinates between multiple managers to handle
/// user actions on the home screen.
class HomeController extends BaseController {
  final PetManager _petManager;
  final TaskManager _taskManager;
  final DayManager _dayManager;
  final RainbowStonesManager _rainbowStonesManager;

  /// Constructor
  HomeController({
    required PetManager petManager,
    required TaskManager taskManager,
    required DayManager dayManager,
    required RainbowStonesManager rainbowStonesManager,
  }) : _petManager = petManager,
       _taskManager = taskManager,
       _dayManager = dayManager,
       _rainbowStonesManager = rainbowStonesManager;

  @override
  Future<void> onInitialize() async {}

  /// Load all data needed for the home screen
  Future<void> loadHomeScreenData() async {
    try {
      await _petManager.checkDayTransition();
      await _petManager.loadCurrentPet();
      await _dayManager.loadCurrentDay();
      await _taskManager.loadTasks();
      await _rainbowStonesManager.loadRainbowStones();

      debugPrint('HomeController: Home screen data loaded successfully');
    } catch (e) {
      debugPrint('HomeController: Error loading home screen data: $e');
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

  /// Complete a task from the home screen
  Future<void> completeTask(String taskId) async {
    try {
      // Get the task to determine energy reward
      final task = await _taskManager.getTask(taskId);
      if (task == null) {
        debugPrint('HomeController: Task not found: $taskId');
        return;
      }

      // Complete the task
      await _taskManager.completeTask(taskId);

      // Add energy to the pet
      await _petManager.addEnergy(task.energyReward.toDouble());

      // Update day record
      await _dayManager.completeTask(taskId);

      // Award rainbow stones for task completion (if applicable)
      if (task.category == TaskCategory.productivity) {
        const int goalCompletionReward = 10;
        await _rainbowStonesManager.awardTaskCompletionStones(
          goalCompletionReward,
        );
        await _dayManager.addRainbowStones(goalCompletionReward);
      }

      // Check if pet is ready to evolve
      if (_petManager.isReadyToEvolve) {
        debugPrint('HomeController: Pet is ready to evolve!');
      }

      debugPrint('HomeController: Task completed successfully: ${task.title}');
    } catch (e) {
      debugPrint('HomeController: Error completing task: $e');
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

  bool isTaskCompleted(String taskId) => _dayManager.isTaskCompleted(taskId);

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
