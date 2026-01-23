import 'package:flutter_test/flutter_test.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/services/task_service.dart';
import 'package:birdo/model/services/repeating_task_service.dart';
import 'package:hive_ce/hive.dart';
import '../helpers/service_locator_test_helper.dart';

/// Tests for TaskService - Pure CRUD operations only.
/// Cross-domain orchestration (recurring task injection, day association)
/// is tested in TaskController tests.
void main() {
  late Box<Task> taskBox;
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
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(RepeatingTaskAdapter());
    }

    // Open test boxes with fixed names
    taskBox = await Hive.openBox<Task>('tasks_test');
    repeatingTaskBox = await Hive.openBox<RepeatingTask>('repeatingTasks_test');

    TaskService.enableTestMode(taskBox);
    RepeatingTaskService.enableTestMode(repeatingTaskBox);
  });

  setUp(() async {
    // Clear boxes before each test
    await taskBox.clear();
    await repeatingTaskBox.clear();
  });

  tearDownAll(() async {
    TaskService.disableTestMode();
    RepeatingTaskService.disableTestMode();

    await Hive.close();
    await Hive.deleteBoxFromDisk('tasks_test');
    await Hive.deleteBoxFromDisk('repeatingTasks_test');
  });

  group('TaskService - Task CRUD Operations', () {
    test('createTask creates task with correct properties', () async {
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 10,
        category: TaskCategory.productivity,
      );

      expect(task.title, equals('Test Task'));
      expect(task.energyReward, equals(10));
      expect(task.category, equals(TaskCategory.productivity));

      // Verify task is in database
      final retrieved = await TaskService.getTask(task.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(task.id));
    });

    test('createTask with repeatingTaskId links to template', () async {
      // Create a repeating task template
      final template = await RepeatingTaskService.createRepeatingTask(
        title: 'Monday Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [1],
      );

      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatingTaskId: template.id,
      );

      expect(task.repeatingTaskId, equals(template.id));
    });

    test('createTaskFromTemplate creates task from RepeatingTask', () async {
      // Create a repeating task template
      final template = await RepeatingTaskService.createRepeatingTask(
        title: 'Template Task',
        energyReward: 7,
        category: TaskCategory.exercise,
        repeatDayIndices: [1, 3, 5],
      );

      final task = await TaskService.createTaskFromTemplate(template: template);

      expect(task.title, equals('Template Task'));
      expect(task.energyReward, equals(7));
      expect(task.category, equals(TaskCategory.exercise));
      expect(task.repeatingTaskId, equals(template.id));
    });

    test('getTask returns null for non-existent task', () async {
      final retrieved = await TaskService.getTask('non-existent-id');
      expect(retrieved, isNull);
    });

    test('getTasksByIds returns tasks in order', () async {
      final task1 = await TaskService.createTask(
        title: 'Task 1',
        energyReward: 1,
        category: TaskCategory.productivity,
      );
      final task2 = await TaskService.createTask(
        title: 'Task 2',
        energyReward: 2,
        category: TaskCategory.selfCare,
      );
      final task3 = await TaskService.createTask(
        title: 'Task 3',
        energyReward: 3,
        category: TaskCategory.exercise,
      );

      final tasks = await TaskService.getTasksByIds([task1.id, task3.id]);

      expect(tasks.length, equals(2));
      expect(tasks[0].id, equals(task1.id));
      expect(tasks[1].id, equals(task3.id));
    });

    test('getTasksByIds skips non-existent tasks', () async {
      final task = await TaskService.createTask(
        title: 'Real Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      final tasks = await TaskService.getTasksByIds([task.id, 'non-existent']);

      expect(tasks.length, equals(1));
      expect(tasks[0].id, equals(task.id));
    });

    test('getInvalidTaskIds returns IDs not in database', () async {
      final task = await TaskService.createTask(
        title: 'Real Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      final invalidIds = await TaskService.getInvalidTaskIds([
        task.id,
        'invalid-1',
        'invalid-2',
      ]);

      expect(invalidIds.length, equals(2));
      expect(invalidIds.contains('invalid-1'), isTrue);
      expect(invalidIds.contains('invalid-2'), isTrue);
      expect(invalidIds.contains(task.id), isFalse);
    });

    test('updateTask modifies existing task', () async {
      // Create a task
      final task = await TaskService.createTask(
        title: 'Original Title',
        energyReward: 5,
        category: TaskCategory.selfCare,
      );

      // Update the task
      task.title = 'Updated Title';
      task.energyReward = 10;
      task.category = TaskCategory.productivity;
      await TaskService.updateTask(task);

      // Verify changes were saved
      final retrieved = await TaskService.getTask(task.id);
      expect(retrieved!.title, equals('Updated Title'));
      expect(retrieved.energyReward, equals(10));
      expect(retrieved.category, equals(TaskCategory.productivity));
    });

    test('deleteTask removes task from database', () async {
      // Create a task
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      // Verify task exists
      expect(await TaskService.getTask(task.id), isNotNull);

      // Delete the task
      await TaskService.deleteTask(task.id);

      // Verify task is removed from database
      final retrieved = await TaskService.getTask(task.id);
      expect(retrieved, isNull);
    });
  });

  group('TaskService - Task Completion/Reset', () {
    test('completeTask sets completedAt and isCompleted', () async {
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      // Task should start incomplete
      expect(task.isCompleted, isFalse);
      expect(task.completedAt, isNull);

      // Complete the task
      await TaskService.completeTask(task);

      // Verify task has completedAt timestamp and isCompleted flag
      final retrieved = await TaskService.getTask(task.id);
      expect(retrieved!.completedAt, isNotNull);
      expect(retrieved.isCompleted, isTrue);
    });

    test('resetTask clears completedAt and isCompleted', () async {
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      // Complete the task
      await TaskService.completeTask(task);
      expect((await TaskService.getTask(task.id))!.isCompleted, isTrue);

      // Reset the task
      await TaskService.resetTask(task);

      // Verify task is no longer completed
      final resetTask = await TaskService.getTask(task.id);
      expect(resetTask!.isCompleted, isFalse);
      expect(resetTask.completedAt, isNull);
    });

    test('completeTask can be called multiple times', () async {
      final task = await TaskService.createTask(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      // Complete twice
      await TaskService.completeTask(task);
      expect((await TaskService.getTask(task.id))!.isCompleted, isTrue);
      expect((await TaskService.getTask(task.id))!.completedAt, isNotNull);

      await TaskService.completeTask(task);

      // Task should still be completed
      expect((await TaskService.getTask(task.id))!.isCompleted, isTrue);
      expect((await TaskService.getTask(task.id))!.completedAt, isNotNull);
    });
  });
}
