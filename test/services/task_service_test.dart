import 'package:flutter_test/flutter_test.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/services/task_service.dart';
import 'package:birdo/model/services/day_service.dart';
import 'package:birdo/model/services/repeating_task_service.dart';
import 'package:hive_ce/hive.dart';
import '../helpers/service_locator_test_helper.dart';

void main() {
  late Box<Task> taskBox;
  late Box<Day> dayBox;
  late Box<RepeatingTask> repeatingTaskBox;

  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();

    // Initialize Hive for testing
    Hive.init('test_task_service');

    // Register required adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DayAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(RepeatingTaskAdapter());
    }

    // Open test boxes with fixed names
    taskBox = await Hive.openBox<Task>('tasks_test');
    dayBox = await Hive.openBox<Day>('days_test');
    repeatingTaskBox = await Hive.openBox<RepeatingTask>('repeatingTasks_test');

    TaskService.enableTestMode(taskBox);
    DayService.enableTestMode(dayBox);
    RepeatingTaskService.enableTestMode(repeatingTaskBox);
  });

  setUp(() async {
    // Clear boxes before each test
    await taskBox.clear();
    await dayBox.clear();
    await repeatingTaskBox.clear();
  });

  tearDownAll(() async {
    TaskService.disableTestMode();
    DayService.disableTestMode();
    RepeatingTaskService.disableTestMode();

    await Hive.close();
    await Hive.deleteBoxFromDisk('tasks_test');
    await Hive.deleteBoxFromDisk('days_test');
    await Hive.deleteBoxFromDisk('repeatingTasks_test');
  });

  group('TaskService - Recurring Task Injection Tests', () {
    test('getTasksForDay injects recurring tasks that match the weekday', () async {
      // Create a Monday (weekday = 1)
      final monday = DateTime(2024, 1, 1); // 2024-01-01 is a Monday

      // Create a RepeatingTask template for Monday
      final repeatingTask = await RepeatingTaskService.createRepeatingTask(
        title: 'Monday Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [1], // Monday only
      );

      // Create a non-recurring task for the day
      final regularTask = await TaskService.createTask(
        title: 'Regular Task',
        energyReward: 3,
        category: TaskCategory.selfCare,
        date: monday,
      );

      // Get tasks for Monday - should inject recurring + include regular
      final tasks = await TaskService.getTasksForDay(monday);

      // Should have both tasks
      expect(tasks.length, equals(2));
      expect(tasks.any((t) => t.repeatingTaskId == repeatingTask.id), isTrue);
      expect(tasks.any((t) => t.id == regularTask.id), isTrue);
    });

    test('getTasksForDay does not inject recurring tasks for wrong weekday', () async {
      // Create a Monday (weekday = 1)
      final monday = DateTime(2024, 1, 1); // 2024-01-01 is a Monday

      // Create a RepeatingTask template for Tuesday
      await RepeatingTaskService.createRepeatingTask(
        title: 'Tuesday Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [2], // Tuesday only
      );

      // Get tasks for Monday - should NOT include Tuesday task
      final tasks = await TaskService.getTasksForDay(monday);

      // Should not include the Tuesday task
      expect(tasks.any((t) => t.title == 'Tuesday Task'), isFalse);
    });

    test('getTasksForDay does not duplicate recurring tasks already in day', () async {
      // Create a Monday
      final monday = DateTime(2024, 1, 1);

      // Create a RepeatingTask template
      final repeatingTask = await RepeatingTaskService.createRepeatingTask(
        title: 'Monday Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [1], // Monday
      );

      // First call - task instance should be created
      final firstCall = await TaskService.getTasksForDay(monday);
      expect(firstCall.length, equals(1));
      expect(firstCall[0].repeatingTaskId, equals(repeatingTask.id));

      // Second call - should NOT create duplicate
      final secondCall = await TaskService.getTasksForDay(monday);
      expect(secondCall.length, equals(1));
      expect(secondCall[0].id, equals(firstCall[0].id)); // Same task instance
    });

    test('getTasksForDay handles multiple recurring tasks for same day', () async {
      // Create a Wednesday (weekday = 3)
      final wednesday = DateTime(2024, 1, 3); // 2024-01-03 is a Wednesday

      // Create multiple RepeatingTask templates for Wednesday
      // Note: Add small delays between creates to ensure unique IDs
      // (IDs are based on millisecondsSinceEpoch)
      final rt1 = await RepeatingTaskService.createRepeatingTask(
        title: 'Wednesday Task 1',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [3],
      );
      await Future.delayed(const Duration(milliseconds: 2));
      final rt2 = await RepeatingTaskService.createRepeatingTask(
        title: 'Wednesday Task 2',
        energyReward: 3,
        category: TaskCategory.exercise,
        repeatDayIndices: [3],
      );
      await Future.delayed(const Duration(milliseconds: 2));
      final rt3 = await RepeatingTaskService.createRepeatingTask(
        title: 'Daily Task',
        energyReward: 2,
        category: TaskCategory.selfCare,
        repeatDayIndices: [1, 2, 3, 4, 5, 6, 7], // All days
      );

      // Get tasks for Wednesday
      final tasks = await TaskService.getTasksForDay(wednesday);

      // Should have all three tasks
      expect(tasks.length, equals(3));
      expect(tasks.any((t) => t.repeatingTaskId == rt1.id), isTrue);
      expect(tasks.any((t) => t.repeatingTaskId == rt2.id), isTrue);
      expect(tasks.any((t) => t.repeatingTaskId == rt3.id), isTrue);
    });

    test('getTasksForDay cleans up invalid task IDs', () async {
      // Create a day with an invalid task ID
      final monday = DateTime(2024, 1, 1);
      final day = Day.create(monday);
      day.dailyTaskIds.add('invalid-task-id');
      await DayService.saveDay(day);

      // Get tasks - should remove the invalid ID
      final tasks = await TaskService.getTasksForDay(monday);

      // Verify the invalid ID was removed
      final updatedDay = await DayService.getDayRecord(monday);
      expect(updatedDay!.dailyTaskIds.contains('invalid-task-id'), isFalse);
      expect(tasks.isEmpty, isTrue);
    });
  });

  group('TaskService - Task Reset/Uncomplete Tests', () {
    test('resetTask removes completedAt timestamp', () async {
      final today = DateTime(2024, 1, 1);

      // Create a task
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        date: today,
      );

      // Complete the task
      await TaskService.completeTask(task, date: today);
      final completedTask = await TaskService.getTask(task.id);
      expect(completedTask!.completedAt, isNotNull);

      // Reset the task
      await TaskService.resetTask(task, date: today);

      // Verify task completedAt is cleared
      final retrievedTask = await TaskService.getTask(task.id);
      expect(retrievedTask!.completedAt, isNull);
    });

    test('resetTask clears isCompleted on task', () async {
      final today = DateTime(2024, 1, 1);

      // Create a task
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        date: today,
      );

      // Complete the task
      await TaskService.completeTask(task, date: today);

      // Verify task is completed
      final completedTask = await TaskService.getTask(task.id);
      expect(completedTask!.isCompleted, isTrue);

      // Reset the task
      await TaskService.resetTask(task, date: today);

      // Verify task is no longer completed
      final resetTask = await TaskService.getTask(task.id);
      expect(resetTask!.isCompleted, isFalse);
    });

    test('completeTask sets completedAt and isCompleted on task', () async {
      final today = DateTime(2024, 1, 1);

      // Create a task
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        date: today,
      );

      // Complete the task
      await TaskService.completeTask(task, date: today);

      // Verify task has completedAt timestamp and isCompleted flag
      final retrievedTask = await TaskService.getTask(task.id);
      expect(retrievedTask!.completedAt, isNotNull);
      expect(retrievedTask.isCompleted, isTrue);
    });
  });

  group('TaskService - Task CRUD Operations', () {
    test('createTask creates task with correct properties', () async {
      final today = DateTime(2024, 1, 1);

      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 10,
        category: TaskCategory.productivity,
        date: today,
      );

      expect(task.title, equals('Test Task'));
      expect(task.energyReward, equals(10));
      expect(task.category, equals(TaskCategory.productivity));

      // Verify task is in database
      final retrieved = await TaskService.getTask(task.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(task.id));
    });

    test('updateTask modifies existing task', () async {
      final today = DateTime(2024, 1, 1);

      // Create a task
      final task = await TaskService.createTask(
        title: 'Original Title',
        energyReward: 5,
        category: TaskCategory.selfCare,
        date: today,
      );

      // Update the task
      task.title = 'Updated Title';
      task.energyReward = 10;
      task.category = TaskCategory.productivity;
      await TaskService.updateTask(task, date: today);

      // Verify changes were saved
      final retrieved = await TaskService.getTask(task.id);
      expect(retrieved!.title, equals('Updated Title'));
      expect(retrieved.energyReward, equals(10));
      expect(retrieved.category, equals(TaskCategory.productivity));
    });

    test('deleteTask removes task from database and day', () async {
      final today = DateTime(2024, 1, 1);

      // Create a task
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        date: today,
      );

      // Delete the task
      await TaskService.deleteTask(task, date: today);

      // Verify task is removed from database
      final retrieved = await TaskService.getTask(task.id);
      expect(retrieved, isNull);

      // Verify task is removed from day
      final day = await DayService.getDayRecord(today);
      expect(day!.dailyTaskIds.contains(task.id), isFalse);
    });
  });

}
