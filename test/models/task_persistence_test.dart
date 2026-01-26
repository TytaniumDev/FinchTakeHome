import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/services/task_service.dart';
import 'package:birdo/model/services/repeating_task_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/service_locator_test_helper.dart';
import '../helpers/test_helpers.dart';

/// Tests for Task entity persistence through TaskService.
/// Cross-domain operations (recurring task injection, day association)
/// are tested in TaskController tests.
void main() {
  group('Task Model Persistence Tests', () {
    late Box<Task> taskBox;
    late Box<RepeatingTask> repeatingTaskBox;
    late Task testTask;

    setUpAll(() async {
      await ServiceLocatorTestHelper.initialize();

      Hive.init('test_task');
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(TaskCategoryAdapter());
      Hive.registerAdapter(RepeatingTaskAdapter());

      taskBox = await Hive.openBox<Task>('tasks_test');
      repeatingTaskBox = await Hive.openBox<RepeatingTask>('repeatingTasks_test');

      TaskService.enableTestMode(taskBox);
      RepeatingTaskService.enableTestMode(repeatingTaskBox);
    });

    setUp(() async {
      testTask = TestFactory.createTestTask(
        id: 'test-task-id',
        title: 'Test Task',
        energyReward: 5,
      );
      await taskBox.put(testTask.id, testTask);
    });

    tearDown(() async {
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

    group('Task CRUD Operations', () {
      test('getTask returns task when it exists', () async {
        final result = await TaskService.getTask(testTask.id);

        expect(result, isNotNull);
        expect(result!.id, equals(testTask.id));
        expect(result.title, equals(testTask.title));
      });

      test('getTask returns null when task does not exist', () async {
        final result = await TaskService.getTask('non-existent-id');

        expect(result, isNull);
      });

      test('createTask saves task to database', () async {
        final newTask = await TaskService.createTask(
          title: 'New Task',
          energyReward: 10,
          category: TaskCategory.selfCare,
        );

        final savedTask = taskBox.get(newTask.id);
        expect(savedTask, isNotNull);
        expect(savedTask?.title, equals('New Task'));
        expect(savedTask?.energyReward, equals(10));
        expect(savedTask?.category, equals(TaskCategory.selfCare));
      });

      test('createTask with repeatingTaskId links to template', () async {
        final template = await RepeatingTaskService.createRepeatingTask(
          title: 'Template',
          energyReward: 5,
          category: TaskCategory.productivity,
          repeatDayIndices: [1],
        );

        final task = await TaskService.createTask(
          title: 'Linked Task',
          energyReward: 5,
          category: TaskCategory.productivity,
          repeatingTaskId: template.id,
        );

        expect(task.repeatingTaskId, equals(template.id));
      });

      test('createTaskFromTemplate creates task from RepeatingTask', () async {
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

        // Verify saved to database
        final savedTask = await TaskService.getTask(task.id);
        expect(savedTask, isNotNull);
      });

      test('updateTask updates task in database', () async {
        testTask.title = 'Updated Task';
        testTask.energyReward = 10;
        testTask.category = TaskCategory.selfCare;

        await TaskService.updateTask(testTask);

        final savedTask = taskBox.get(testTask.id);
        expect(savedTask?.title, equals('Updated Task'));
        expect(savedTask?.energyReward, equals(10));
        expect(savedTask?.category, equals(TaskCategory.selfCare));
      });

      test('deleteTask removes task from database', () async {
        // Verify task exists
        expect(taskBox.get(testTask.id), isNotNull);

        await TaskService.deleteTask(testTask.id);

        expect(taskBox.get(testTask.id), isNull);
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

        final tasks = await TaskService.getTasksByIds([task2.id, task1.id]);

        expect(tasks.length, equals(2));
        expect(tasks[0].id, equals(task2.id));
        expect(tasks[1].id, equals(task1.id));
      });

      test('getTasksByIds skips non-existent IDs', () async {
        final tasks = await TaskService.getTasksByIds([
          testTask.id,
          'non-existent-id',
        ]);

        expect(tasks.length, equals(1));
        expect(tasks[0].id, equals(testTask.id));
      });

      test('getInvalidTaskIds returns IDs not in database', () async {
        final invalidIds = await TaskService.getInvalidTaskIds([
          testTask.id,
          'invalid-1',
          'invalid-2',
        ]);

        expect(invalidIds.length, equals(2));
        expect(invalidIds.contains('invalid-1'), isTrue);
        expect(invalidIds.contains('invalid-2'), isTrue);
        expect(invalidIds.contains(testTask.id), isFalse);
      });
    });

    group('Task Completion/Reset', () {
      test('completeTask marks task as completed', () async {
        expect(testTask.isCompleted, isFalse);
        expect(testTask.completedAt, isNull);

        await TaskService.completeTask(testTask);

        final updatedTask = taskBox.get(testTask.id);
        expect(updatedTask?.isCompleted, isTrue);
        expect(updatedTask?.completedAt, isNotNull);
      });

      test('resetTask clears completion status', () async {
        final completedTask = TestFactory.createTestTask(
          id: 'completed-task-id',
          title: 'Completed Task',
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        await taskBox.put(completedTask.id, completedTask);

        await TaskService.resetTask(completedTask);

        final updatedTask = taskBox.get(completedTask.id);
        expect(updatedTask?.isCompleted, isFalse);
        expect(updatedTask?.completedAt, isNull);
      });

      test('completeTask can be called multiple times', () async {
        await TaskService.completeTask(testTask);
        expect(taskBox.get(testTask.id)?.isCompleted, isTrue);
        expect(taskBox.get(testTask.id)?.completedAt, isNotNull);

        await TaskService.completeTask(testTask);

        // Task should still be completed
        expect(taskBox.get(testTask.id)?.isCompleted, isTrue);
        expect(taskBox.get(testTask.id)?.completedAt, isNotNull);
      });

      test('resetTask is idempotent', () async {
        // Task starts incomplete
        expect(testTask.isCompleted, isFalse);

        // Reset should work even on incomplete task
        await TaskService.resetTask(testTask);

        final updatedTask = taskBox.get(testTask.id);
        expect(updatedTask?.isCompleted, isFalse);
        expect(updatedTask?.completedAt, isNull);
      });
    });

    group('Task Properties', () {
      test('task preserves all properties through save/load cycle', () async {
        final task = await TaskService.createTask(
          title: 'Full Task',
          energyReward: 15,
          category: TaskCategory.exercise,
          repeatingTaskId: 'template-123',
        );

        // Complete the task
        await TaskService.completeTask(task);

        // Retrieve from database
        final loaded = await TaskService.getTask(task.id);

        expect(loaded, isNotNull);
        expect(loaded!.title, equals('Full Task'));
        expect(loaded.energyReward, equals(15));
        expect(loaded.category, equals(TaskCategory.exercise));
        expect(loaded.repeatingTaskId, equals('template-123'));
        expect(loaded.isCompleted, isTrue);
        expect(loaded.completedAt, isNotNull);
      });

      test('task categories are preserved', () async {
        for (final category in TaskCategory.values) {
          final task = await TaskService.createTask(
            title: 'Category Test',
            energyReward: 1,
            category: category,
          );

          final loaded = await TaskService.getTask(task.id);
          expect(loaded?.category, equals(category));
        }
      });
    });
  });
}
