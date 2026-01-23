// Integration tests for the TaskList widget using real managers and services.

import 'dart:io';

import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/theme/app_theme.dart';
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
import 'package:birdo/view/widgets/common/task_list.dart';
import 'package:birdo/view/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';

import '../helpers/service_locator_test_helper.dart';

/// Integration tests for the TaskList widget using real managers and services.
/// These tests verify the full flow of task completion/uncompletion including
/// UI state updates, which helps catch bugs that only appear when using
/// real implementations.
void main() {
  late Box<Task> taskBox;
  late Box<Day> dayBox;
  late Box<Pet> petBox;
  late Box<RainbowStones> rainbowStonesBox;

  late TaskManager taskManager;
  late DayManager dayManager;
  late PetManager petManager;
  late RainbowStonesManager rainbowStonesManager;
  late RepeatingTaskManager repeatingTaskManager;
  late TaskController taskController;

  // Use a unique temporary directory for each test run to avoid lock file issues
  late Directory tempDir;
  late Box<RepeatingTask> repeatingTaskBox;

  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();

    // Create a unique temporary directory for Hive to avoid lock file conflicts
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    // Register all required adapters (check if already registered)
    // Using each adapter's typeId property instead of magic numbers
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

    // Open boxes ONCE in setUpAll (following the working pattern from task_service_test.dart)
    taskBox = await Hive.openBox<Task>('tasks_integration_test');
    dayBox = await Hive.openBox<Day>('days_integration_test');
    petBox = await Hive.openBox<Pet>('pets_integration_test');
    rainbowStonesBox = await Hive.openBox<RainbowStones>('rainbow_stones_integration_test');
    repeatingTaskBox = await Hive.openBox<RepeatingTask>('repeatingTasks_integration_test');

    // Enable test mode for services
    TaskService.enableTestMode(taskBox);
    DayService.enableTestMode(dayBox);
    PetService.enableTestMode(petBox);
    RainbowStonesService.enableTestMode(rainbowStonesBox);
    RepeatingTaskService.enableTestMode(repeatingTaskBox);
  });

  setUp(() async {
    // Clear boxes before each test (don't close and reopen!)
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

    // Create a pet (required for energy operations)
    await PetService.createNewPet(name: 'Test Pet', gender: Gender.male);

    // Initialize managers
    await taskManager.initialize();
    await dayManager.initialize();
    await petManager.initialize();
    await rainbowStonesManager.initialize();
  });

  tearDown(() async {
    // Nothing to do - boxes are cleared in setUp for the next test
    // Don't disable test mode here since we want to keep it for subsequent tests
  });

  tearDownAll(() async {
    // Disable test mode
    TaskService.disableTestMode();
    DayService.disableTestMode();
    PetService.disableTestMode();
    RainbowStonesService.disableTestMode();
    RepeatingTaskService.disableTestMode();

    // Close Hive (this closes all boxes)
    await Hive.close();

    // Delete the temporary directory and all its contents
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore errors if directory doesn't exist or can't be deleted
    }
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<TaskManager>.value(value: taskManager),
            ChangeNotifierProvider<DayManager>.value(value: dayManager),
            Provider<TaskController>.value(value: taskController),
          ],
          child: const TaskList(),
        ),
      ),
    );
  }

  group('TaskList Integration Tests - Task Completion/Uncompletion', () {
    testWidgets(
        'completing and uncompleting a task updates UI state correctly',
        (tester) async {
      // Create a task - use runAsync for I/O operations in widget tests
      await tester.runAsync(() async {
        await taskController.createTask(
          'Integration Test Task',
          5,
          TaskCategory.productivity,
        );
        await taskManager.loadTasks();
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify task is displayed
      expect(find.text('Integration Test Task'), findsOneWidget);

      // Verify initial uncompleted state (opacity should be 1.0)
      var opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      var opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason: 'Task should start with full opacity (uncompleted)');

      // Get the task ID
      final task = taskManager.tasks.first;

      // Complete the task via controller - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));

      // Pump to allow async operations and animation
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify completed state (opacity should be 0.6)
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(0.6),
          reason: 'Completed task should have 0.6 opacity');

      // Verify task is in completed list
      expect(taskManager.isTaskCompleted(task.id), isTrue,
          reason: 'Task should be marked as completed');

      // Uncomplete the task via controller - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));

      // Pump to allow async operations and animation
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify uncompleted state is restored (opacity should be 1.0)
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason:
              'Uncompleted task should have full opacity (1.0), but got ${opacityWidget.opacity}');

      // Verify task is removed from completed list
      expect(taskManager.isTaskCompleted(task.id), isFalse,
          reason: 'Task should be marked as not completed');
    });

    testWidgets('uncompleting a task via UI tap restores visual state',
        (tester) async {
      // Create a task - use runAsync for I/O operations
      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'UI Tap Test Task',
          5,
          TaskCategory.selfCare,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
        await taskController.completeTask(task.id);
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify initial completed state
      var animatedCard = tester.widget<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );
      expect(animatedCard.isCompleted, isTrue,
          reason: 'Task should start as completed');

      var opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      var opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(0.6),
          reason: 'Completed task should have 0.6 opacity');

      // Verify the check_circle icon exists (tap target)
      final checkCircleFinder = find.byIcon(Icons.check_circle);
      expect(checkCircleFinder, findsOneWidget,
          reason: 'Should find the check_circle icon for completed task');

      // Note: We call the controller directly instead of tapping because
      // tap-triggered async callbacks with Hive I/O don't work in widget tests.
      // The tap handler calls taskController.uncompleteTask, which we verify
      // by calling it directly and checking the UI updates.
      await tester.runAsync(() => taskController.uncompleteTask(task.id));

      // Pump to allow async operations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Verify the task is now uncompleted in the data layer
      expect(taskManager.isTaskCompleted(task.id), isFalse,
          reason: 'Task should be marked as not completed after tap');

      // Verify the AnimatedTaskCard's isCompleted property
      animatedCard = tester.widget<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );
      expect(animatedCard.isCompleted, isFalse,
          reason: 'AnimatedTaskCard.isCompleted should be false after uncompleting');

      // Verify the opacity is restored to 1.0
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason:
              'Uncompleted task should have full opacity (1.0), but got ${opacityWidget.opacity}');
    });

    testWidgets('Task completion state updates correctly on uncomplete',
        (tester) async {
      // Create a task - use runAsync for I/O operations
      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'Completion State Test',
          5,
          TaskCategory.exercise,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Initially, task should not be completed
      expect(taskManager.isTaskCompleted(task.id), isFalse);

      // Complete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Task should now be completed
      expect(taskManager.isTaskCompleted(task.id), isTrue,
          reason: 'Task should be completed after completeTask');

      // Uncomplete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Task should no longer be completed
      expect(taskManager.isTaskCompleted(task.id), isFalse,
          reason: 'Task should NOT be completed after uncompletion');

      // The UI should also reflect this
      final animatedCard = tester.widget<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );
      expect(animatedCard.isCompleted, isFalse);
    });

    testWidgets('rapid complete/uncomplete cycles work correctly',
        (tester) async {
      // This test checks for race conditions in rapid toggling
      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'Rapid Toggle Task',
          5,
          TaskCategory.mindfulness,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Rapid toggle 3 times - use runAsync for I/O
      for (int i = 0; i < 3; i++) {
        await tester.runAsync(() => taskController.completeTask(task.id));
        await tester.pump(const Duration(milliseconds: 50));

        await tester.runAsync(() => taskController.uncompleteTask(task.id));
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Final state should be uncompleted
      expect(taskManager.isTaskCompleted(task.id), isFalse);

      final animatedCard = tester.widget<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );
      expect(animatedCard.isCompleted, isFalse);

      var opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      var opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0));
    });

    testWidgets('multiple tasks can be completed and uncompleted independently',
        (tester) async {
      // Create two tasks - use runAsync for I/O
      late Task taskA;
      late Task taskB;
      await tester.runAsync(() async {
        await taskController.createTask('Task A', 5, TaskCategory.productivity);
        await taskController.createTask('Task B', 3, TaskCategory.selfCare);
        await taskManager.loadTasks();
        taskA = taskManager.tasks.firstWhere((t) => t.title == 'Task A');
        taskB = taskManager.tasks.firstWhere((t) => t.title == 'Task B');
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Complete both tasks - use runAsync for I/O
      await tester.runAsync(() async {
        await taskController.completeTask(taskA.id);
        await taskController.completeTask(taskB.id);
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(taskManager.isTaskCompleted(taskA.id), isTrue);
      expect(taskManager.isTaskCompleted(taskB.id), isTrue);

      // Uncomplete only Task A - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(taskA.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(taskManager.isTaskCompleted(taskA.id), isFalse,
          reason: 'Task A should be uncompleted');
      expect(taskManager.isTaskCompleted(taskB.id), isTrue,
          reason: 'Task B should still be completed');

      // Verify UI state for each card
      final cards = tester.widgetList<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );

      for (final card in cards) {
        if (card.task.id == taskA.id) {
          expect(card.isCompleted, isFalse,
              reason: 'Task A card should show uncompleted');
        } else if (card.task.id == taskB.id) {
          expect(card.isCompleted, isTrue,
              reason: 'Task B card should show completed');
        }
      }
    });
  });

  group('TaskList Integration Tests - Task Completion State', () {
    testWidgets(
        'TaskManager rebuilds widget when task completion changes',
        (tester) async {
      // This test verifies that the UI properly rebuilds when task completion
      // state changes via TaskManager.

      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'Completion State Test',
          5,
          TaskCategory.productivity,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      // Track rebuilds
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<TaskManager>.value(value: taskManager),
                ChangeNotifierProvider<DayManager>.value(value: dayManager),
                Provider<TaskController>.value(value: taskController),
              ],
              child: Consumer<TaskManager>(
                builder: (context, taskMgr, child) {
                  buildCount++;
                  final currentTask = taskMgr.tasks.firstWhere((t) => t.id == task.id);

                  return AnimatedTaskCard(
                    task: currentTask,
                    isCompleted: currentTask.isCompleted,
                    onCheckboxChanged: (value) {
                      if (value == true) {
                        taskController.completeTask(task.id);
                      } else {
                        taskController.uncompleteTask(task.id);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final initialBuildCount = buildCount;

      // Verify initial state
      var card = tester.widget<AnimatedTaskCard>(find.byType(AnimatedTaskCard));
      expect(card.isCompleted, isFalse, reason: 'Task should start uncompleted');

      // Complete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should have rebuilt
      expect(buildCount, greaterThan(initialBuildCount),
          reason: 'Widget should rebuild after completing task');

      card = tester.widget<AnimatedTaskCard>(find.byType(AnimatedTaskCard));
      expect(card.isCompleted, isTrue,
          reason: 'Task should be completed after completeTask');

      final buildCountAfterComplete = buildCount;

      // Uncomplete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should have rebuilt again
      expect(buildCount, greaterThan(buildCountAfterComplete),
          reason: 'Widget should rebuild after uncompleting task');

      card = tester.widget<AnimatedTaskCard>(find.byType(AnimatedTaskCard));
      expect(card.isCompleted, isFalse,
          reason: 'Task should be uncompleted after uncompleteTask');

      // Also check the animation state
      final opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      final opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason: 'Opacity should be 1.0 for uncompleted task');
    });

    testWidgets(
        'TaskManager.completedTasks returns new list instance each time',
        (tester) async {
      // This test verifies that TaskManager.completedTasks returns
      // a new List instance on each call via List<Task>.from(...).

      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'List Instance Test',
          5,
          TaskCategory.productivity,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Complete the task first - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Get list references before and after
      final listReferenceBefore = taskManager.completedTasks;

      expect(listReferenceBefore.any((t) => t.id == task.id), isTrue,
          reason: 'Task should be in completedTasks before uncomplete');

      // Uncomplete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Get the list reference AFTER uncompleting
      final listReferenceAfter = taskManager.completedTasks;

      // The content should be different
      expect(listReferenceAfter.any((t) => t.id == task.id), isFalse,
          reason: 'Task should not be in completedTasks after uncomplete');

      // The getter returns a new list instance each call
      final areSameReference = identical(listReferenceBefore, listReferenceAfter);
      expect(areSameReference, isFalse,
          reason: 'completedTasks should return a new List instance '
              'on each call');
    });
  });

  group('TaskList Integration Tests - AnimatedTaskCard State Bug', () {
    testWidgets(
        'AnimatedTaskCard animation controller reverses when uncompleting',
        (tester) async {
      // This test checks if the AnimatedTaskCard's animation controller
      // properly reverses when a task is uncompleted. The bug might be that
      // didUpdateWidget is called but the animation doesn't reverse.

      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'Animation Controller Test',
          5,
          TaskCategory.productivity,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Initial state - should be uncompleted (animation value = 0)
      var opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      var opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason: 'Initial opacity should be 1.0 (uncompleted)');

      // Complete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));

      // Pump frame by frame to observe animation
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(milliseconds: 150)); // Mid animation
      await tester.pump(const Duration(milliseconds: 150)); // End animation
      await tester.pump(const Duration(seconds: 1));

      // Should now be at completed state (animation value = 1, opacity = 0.6)
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(0.6),
          reason: 'Completed opacity should be 0.6');

      // Now uncomplete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));

      // Pump frame by frame to observe reverse animation
      await tester.pump(); // Start the reverse animation

      // Check mid-animation - opacity should be between 0.6 and 1.0
      await tester.pump(const Duration(milliseconds: 150));
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      debugPrint('Mid-reverse animation opacity: ${opacityWidget.opacity}');

      // Complete the animation
      await tester.pump(const Duration(seconds: 1));

      // Should now be back at uncompleted state (opacity = 1.0)
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason: 'After uncomplete, opacity should be back to 1.0, '
              'but got ${opacityWidget.opacity}. '
              'This indicates the animation did not reverse properly.');
    });

    testWidgets(
        'AnimatedTaskCard without key might not update when parent rebuilds',
        (tester) async {
      // This test simulates what happens in TaskList where AnimatedTaskCard
      // is created without a key. Without a key, Flutter might not properly
      // match the new widget with the old state.

      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'No Key Test',
          5,
          TaskCategory.productivity,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      // Use the actual TaskList widget which doesn't use keys
      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Complete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify completed state
      var card = tester.widget<AnimatedTaskCard>(find.byType(AnimatedTaskCard));
      expect(card.isCompleted, isTrue);

      var opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      var opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(0.6));

      // Uncomplete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));

      // Important: Don't use pumpAndSettle immediately.
      // First check if the widget received the update.
      await tester.pump();

      // Check if the AnimatedTaskCard widget received isCompleted=false
      card = tester.widget<AnimatedTaskCard>(find.byType(AnimatedTaskCard));
      expect(card.isCompleted, isFalse,
          reason: 'AnimatedTaskCard widget should receive isCompleted=false '
              'immediately after uncomplete. If this fails, the parent is not '
              'rebuilding and passing the new value.');

      // Now let the animation complete
      await tester.pump(const Duration(seconds: 1));

      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason: 'Final opacity should be 1.0 after uncomplete animation');
    });

    testWidgets(
        'TaskList rebuilds Consumer when TaskManager notifies listeners',
        (tester) async {
      // This test verifies that the Consumer inside TaskList rebuilds
      // when task completion state changes via TaskManager.

      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'Consumer Rebuild Test',
          5,
          TaskCategory.productivity,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      int consumerBuildCount = 0;

      // Create a custom widget that tracks Consumer rebuilds
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<TaskManager>.value(value: taskManager),
                ChangeNotifierProvider<DayManager>.value(value: dayManager),
                Provider<TaskController>.value(value: taskController),
              ],
              child: Consumer<TaskManager>(
                builder: (context, taskMgr, child) {
                  consumerBuildCount++;
                  final currentTask = taskMgr.tasks.firstWhere((t) => t.id == task.id);
                  final isCompleted = currentTask.isCompleted;
                  debugPrint('Consumer build #$consumerBuildCount: '
                      'isCompleted=$isCompleted');

                  return AnimatedTaskCard(
                    key: ValueKey(task.id),
                    task: currentTask,
                    isCompleted: isCompleted,
                    onCheckboxChanged: (value) {
                      if (value == true) {
                        taskController.completeTask(task.id);
                      } else {
                        taskController.uncompleteTask(task.id);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final initialBuildCount = consumerBuildCount;

      // Complete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(consumerBuildCount, greaterThan(initialBuildCount),
          reason: 'Consumer should rebuild after completing task');

      final buildCountAfterComplete = consumerBuildCount;

      // Uncomplete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(consumerBuildCount, greaterThan(buildCountAfterComplete),
          reason: 'Consumer should rebuild after uncompleting task. '
              'If this fails, TaskManager.notifyListeners() is not triggering '
              'a rebuild of Consumer<TaskManager>.');
    });
  });

  group('TaskList Integration Tests - TaskManager completedTasks', () {
    testWidgets(
        'TaskManager.completedTasks returns new list on each call',
        (tester) async {
      // This test verifies that TaskManager.completedTasks returns a new list
      // on each call, which allows reference comparison to detect changes.

      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'Root Cause Test',
          5,
          TaskCategory.productivity,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Complete the task first - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Get the completedTasks list BEFORE uncomplete
      final listBefore = taskManager.completedTasks;
      final listHashBefore = identityHashCode(listBefore);

      debugPrint('');
      debugPrint('=== FIX VERIFICATION ===');
      debugPrint('completedTasks list before: $listHashBefore');
      debugPrint('List contents before: ${listBefore.map((t) => t.id)}');

      // Now uncomplete the task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Get the completedTasks list AFTER uncomplete
      final listAfter = taskManager.completedTasks;
      final listHashAfter = identityHashCode(listAfter);

      debugPrint('completedTasks list after: $listHashAfter');
      debugPrint('List contents after: ${listAfter.map((t) => t.id)}');
      debugPrint('');

      final isSameListObject = identical(listBefore, listAfter);

      debugPrint('Same List object? $isSameListObject');
      debugPrint('');

      // Each call to completedTasks returns a new list
      expect(isSameListObject, isFalse,
          reason: 'TaskManager.completedTasks should return a new List '
              'on each call.');

      // Also verify the content is correct
      expect(listBefore.any((t) => t.id == task.id), isTrue,
          reason: 'List before uncomplete should contain the task');
      expect(listAfter.any((t) => t.id == task.id), isFalse,
          reason: 'List after uncomplete should not contain the task');
    });

    testWidgets(
        'Multiple calls to completedTasks getter return different list instances',
        (tester) async {
      // This test verifies that consecutive calls to the getter return
      // different list instances.

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final list1 = taskManager.completedTasks;
      final list2 = taskManager.completedTasks;

      expect(identical(list1, list2), isFalse,
          reason: 'Each call to completedTasks should return a new list instance');
    });
  });

  group('TaskList Integration Tests - Energy and Rainbow Stones', () {
    testWidgets('uncompleting task removes energy from pet', (tester) async {
      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'Energy Test Task',
          10,
          TaskCategory.productivity,
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final initialEnergy = petManager.currentEnergy;

      // Complete task - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final energyAfterComplete = petManager.currentEnergy;
      expect(energyAfterComplete, equals(initialEnergy + 10),
          reason: 'Energy should increase by task reward on completion');

      // Uncomplete task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final energyAfterUncomplete = petManager.currentEnergy;
      expect(energyAfterUncomplete, equals(initialEnergy),
          reason: 'Energy should return to initial value on uncompletion');
    });

    testWidgets('uncompleting productivity task removes rainbow stones',
        (tester) async {
      late Task task;
      await tester.runAsync(() async {
        await taskController.createTask(
          'Rainbow Stones Test',
          5,
          TaskCategory.productivity, // Productivity tasks give rainbow stones
        );
        await taskManager.loadTasks();
        task = taskManager.tasks.first;
      });

      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle to avoid hanging
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final initialStones = rainbowStonesManager.currentBalance;

      // Complete task - use runAsync for I/O
      await tester.runAsync(() => taskController.completeTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final stonesAfterComplete = rainbowStonesManager.currentBalance;
      expect(stonesAfterComplete, greaterThan(initialStones),
          reason:
              'Rainbow stones should increase on productivity task completion');

      // Uncomplete task - use runAsync for I/O
      await tester.runAsync(() => taskController.uncompleteTask(task.id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final stonesAfterUncomplete = rainbowStonesManager.currentBalance;
      expect(stonesAfterUncomplete, equals(initialStones),
          reason:
              'Rainbow stones should return to initial value on uncompletion');
    });
  });
}
