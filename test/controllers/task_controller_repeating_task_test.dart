// Tests for TaskController.createRepeatingTask behavior when creating
// recurring tasks and adding task instances to the current day.

import 'dart:io';

import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/pet_energy.dart';
import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/entities/user.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/repeating_task_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/model/services/day_service.dart';
import 'package:birdo/model/services/pet_service.dart';
import 'package:birdo/model/services/rainbow_stones_service.dart';
import 'package:birdo/model/services/repeating_task_service.dart';
import 'package:birdo/model/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/service_locator_test_helper.dart';

void main() {
  late Box<Task> taskBox;
  late Box<Day> dayBox;
  late Box<Pet> petBox;
  late Box<RainbowStones> rainbowStonesBox;
  late Box<RepeatingTask> repeatingTaskBox;

  late TaskManager taskManager;
  late DayManager dayManager;
  late PetManager petManager;
  late RainbowStonesManager rainbowStonesManager;
  late RepeatingTaskManager repeatingTaskManager;
  late TaskController taskController;

  late Directory tempDir;

  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();

    // Create a unique temporary directory for Hive
    tempDir = await Directory.systemTemp.createTemp('hive_repeating_task_test_');
    Hive.init(tempDir.path);

    // Register all required adapters
    final taskAdapter = TaskAdapter();
    final taskCategoryAdapter = TaskCategoryAdapter();
    final petAdapter = PetAdapter();
    final petGrowthStageAdapter = PetGrowthStageAdapter();
    final genderAdapter = GenderAdapter();
    final petEnergyAdapter = PetEnergyAdapter();
    final dayAdapter = DayAdapter();
    final rainbowStonesAdapter = RainbowStonesAdapter();
    final userAdapter = UserAdapter();
    final repeatingTaskAdapter = RepeatingTaskAdapter();

    if (!Hive.isAdapterRegistered(taskAdapter.typeId)) {
      Hive.registerAdapter(taskAdapter);
    }
    if (!Hive.isAdapterRegistered(taskCategoryAdapter.typeId)) {
      Hive.registerAdapter(taskCategoryAdapter);
    }
    if (!Hive.isAdapterRegistered(petAdapter.typeId)) {
      Hive.registerAdapter(petAdapter);
    }
    if (!Hive.isAdapterRegistered(petGrowthStageAdapter.typeId)) {
      Hive.registerAdapter(petGrowthStageAdapter);
    }
    if (!Hive.isAdapterRegistered(genderAdapter.typeId)) {
      Hive.registerAdapter(genderAdapter);
    }
    if (!Hive.isAdapterRegistered(petEnergyAdapter.typeId)) {
      Hive.registerAdapter(petEnergyAdapter);
    }
    if (!Hive.isAdapterRegistered(dayAdapter.typeId)) {
      Hive.registerAdapter(dayAdapter);
    }
    if (!Hive.isAdapterRegistered(rainbowStonesAdapter.typeId)) {
      Hive.registerAdapter(rainbowStonesAdapter);
    }
    if (!Hive.isAdapterRegistered(userAdapter.typeId)) {
      Hive.registerAdapter(userAdapter);
    }
    if (!Hive.isAdapterRegistered(repeatingTaskAdapter.typeId)) {
      Hive.registerAdapter(repeatingTaskAdapter);
    }

    // Open boxes ONCE in setUpAll
    taskBox = await Hive.openBox<Task>('tasks_repeating_test');
    dayBox = await Hive.openBox<Day>('days_repeating_test');
    petBox = await Hive.openBox<Pet>('pets_repeating_test');
    rainbowStonesBox = await Hive.openBox<RainbowStones>('rainbow_stones_repeating_test');
    repeatingTaskBox = await Hive.openBox<RepeatingTask>('repeatingTasks_repeating_test');

    // Enable test mode for services
    TaskService.enableTestMode(taskBox);
    DayService.enableTestMode(dayBox);
    PetService.enableTestMode(petBox);
    RainbowStonesService.enableTestMode(rainbowStonesBox);
    RepeatingTaskService.enableTestMode(repeatingTaskBox);
  });

  setUp(() async {
    // Clear boxes before each test
    await taskBox.clear();
    await dayBox.clear();
    await petBox.clear();
    await rainbowStonesBox.clear();
    await repeatingTaskBox.clear();

    // Create managers with mock DateTimeService
    taskManager = TaskManager(
      dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
    );
    dayManager = DayManager(
      dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
    );
    petManager = PetManager(
      dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
    );
    rainbowStonesManager = RainbowStonesManager();
    repeatingTaskManager = RepeatingTaskManager();

    // Create controller
    taskController = TaskController(
      taskManager: taskManager,
      dayManager: dayManager,
      petManager: petManager,
      rainbowStonesManager: rainbowStonesManager,
      repeatingTaskManager: repeatingTaskManager,
    );

    // Initialize managers
    await taskManager.initialize();
    await dayManager.initialize();
    await petManager.initialize();
    await rainbowStonesManager.initialize();
    await repeatingTaskManager.initialize();
  });

  tearDownAll(() async {
    // Disable test mode
    TaskService.disableTestMode();
    DayService.disableTestMode();
    PetService.disableTestMode();
    RainbowStonesService.disableTestMode();
    RepeatingTaskService.disableTestMode();

    // Close Hive
    await Hive.close();

    // Delete the temporary directory
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore errors if directory doesn't exist or can't be deleted
    }
  });

  group('TaskController.createRepeatingTask - Task Instance Creation', () {
    test('daily repeating task shows up on current day', () async {
      // Set date to Monday (weekday 1)
      ServiceLocatorTestHelper.mockDateTimeService.setCurrentDate(
        DateTime(2024, 1, 1), // This is a Monday
      );

      // Create a daily task (repeats every day)
      await taskController.createRepeatingTask(
        'Daily Task',
        5,
        TaskCategory.productivity,
        [1, 2, 3, 4, 5, 6, 7], // All days
      );

      // Verify task instance was created and added to task manager
      expect(taskManager.tasks.length, equals(1),
          reason: 'Daily task should create an instance for today');
      expect(taskManager.tasks.first.title, equals('Daily Task'));
      expect(taskManager.tasks.first.repeatingTaskId, isNotNull,
          reason: 'Task should be linked to the repeating task template');

      // Verify the repeating task template was also created
      expect(repeatingTaskManager.repeatingTasks.length, equals(1));
    });

    test('weekly task INCLUDING current day shows up', () async {
      // Set date to Wednesday (weekday 3)
      ServiceLocatorTestHelper.mockDateTimeService.setCurrentDate(
        DateTime(2024, 1, 3), // This is a Wednesday
      );

      // Create a task that repeats on Mon/Wed/Fri (1, 3, 5)
      await taskController.createRepeatingTask(
        'MWF Task',
        10,
        TaskCategory.exercise,
        [1, 3, 5], // Monday, Wednesday, Friday
      );

      // Verify task instance was created since today (Wednesday) is in the schedule
      expect(taskManager.tasks.length, equals(1),
          reason: 'Task should appear since Wednesday is in [Mon, Wed, Fri]');
      expect(taskManager.tasks.first.title, equals('MWF Task'));

      // Verify the repeating task template was created
      expect(repeatingTaskManager.repeatingTasks.length, equals(1));
      expect(repeatingTaskManager.repeatingTasks.first.repeatDayIndices,
          equals([1, 3, 5]));
    });

    test('weekly task NOT including current day does NOT show up', () async {
      // Set date to Thursday (weekday 4)
      ServiceLocatorTestHelper.mockDateTimeService.setCurrentDate(
        DateTime(2024, 1, 4), // This is a Thursday
      );

      // Create a task that repeats on Mon/Wed/Fri (1, 3, 5)
      await taskController.createRepeatingTask(
        'MWF Only Task',
        10,
        TaskCategory.selfCare,
        [1, 3, 5], // Monday, Wednesday, Friday
      );

      // Verify NO task instance was created since Thursday is NOT in the schedule
      expect(taskManager.tasks.length, equals(0),
          reason: 'Task should NOT appear since Thursday is not in [Mon, Wed, Fri]');

      // Verify the repeating task template WAS still created
      expect(repeatingTaskManager.repeatingTasks.length, equals(1),
          reason: 'The template should still be created even if no instance for today');
      expect(repeatingTaskManager.repeatingTasks.first.title, equals('MWF Only Task'));
    });
  });
}
