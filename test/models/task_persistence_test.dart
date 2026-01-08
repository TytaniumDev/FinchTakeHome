import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/services/day_service.dart';
import 'package:birdo/model/services/task_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/service_locator_test_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Task Model Persistence Tests', () {
    late Box<Task> taskBox;
    late Box<Day> dayBox;
    late DateTimeService dateTimeService;
    late Task testTask;
    late Day testDay;

    setUpAll(() async {
      await ServiceLocatorTestHelper.initialize();

      Hive.init('test_task');
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(DayAdapter());
      Hive.registerAdapter(TaskCategoryAdapter());

      taskBox = await Hive.openBox<Task>('tasks_test');
      dayBox = await Hive.openBox<Day>('days_test');

      DayService.enableTestMode(dayBox);
      TaskService.enableTestMode(taskBox);
    });

    setUp(() {
      dateTimeService = ServiceLocatorTestHelper.mockDateTimeService;

      testTask = TestFactory.createTestTask(
        id: 'test-task-id',
        title: 'Test Task',
        energyReward: 5,
      );

      testDay = TestFactory.createTestDay(
        id: '2023-01-01',
        date: DateTime(2023, 1, 1),
        dailyTasks: [testTask],
      );
    });

    tearDown(() async {
      await taskBox.clear();
      await dayBox.clear();
    });

    tearDownAll(() async {
      // Disable test mode
      DayService.disableTestMode();
      TaskService.disableTestMode();

      await Hive.close();
      await Hive.deleteBoxFromDisk('tasks_test');
      await Hive.deleteBoxFromDisk('days_test');
    });

    test('getTasksForDay returns tasks for existing day', () async {
      await dayBox.put(testDay.id, testDay);

      final result = await TaskService.getTasksForDay(testDay.date);

      expect(result.length, equals(1));
      expect(result[0].id, equals(testTask.id));
      expect(result[0].title, equals(testTask.title));
    });

    test('getTasksForDay returns empty list for day with no tasks', () async {
      final emptyDay = TestFactory.createTestDay(
        id: '2023-01-02',
        date: DateTime(2023, 1, 2),
      );
      await dayBox.put(emptyDay.id, emptyDay);

      final result = await TaskService.getTasksForDay(emptyDay.date);

      expect(result, isEmpty);
    });

    test('getTasksForDay creates new day when it does not exist', () async {
      final newDate = DateTime(2023, 1, 3);
      final dayId = '2023-01-03';

      final result = await TaskService.getTasksForDay(newDate);

      expect(result, isEmpty);

      final createdDay = dayBox.get(dayId);
      expect(createdDay, isNotNull);
      expect(createdDay?.id, equals(dayId));
      expect(createdDay?.date, equals(newDate));
      expect(createdDay?.dailyTasks, isEmpty);
    });

    test('getCurrentDayTasks returns tasks for current day', () async {
      final currentDate = DateTime(2023, 1, 1);
      (dateTimeService as MockDateTimeService).setCurrentDate(currentDate);

      await dayBox.put(testDay.id, testDay);

      final result = await TaskService.getCurrentDayTasks();

      expect(result.length, equals(1));
      expect(result[0].id, equals(testTask.id));
    });

    test('completeTask marks task as completed and updates day', () async {
      await dayBox.put(testDay.id, testDay);
      await taskBox.put(testTask.id, testTask);

      await TaskService.completeTask(testTask, date: testDay.date);

      final updatedTask = taskBox.get(testTask.id);
      expect(updatedTask?.isCompleted, isTrue);
      expect(updatedTask?.completedAt, isNotNull);

      final updatedDay = dayBox.get(testDay.id);
      expect(updatedDay?.completedTaskIds, contains(testTask.id));
    });

    test('resetTask resets task completion status', () async {
      final completedTask = TestFactory.createTestTask(
        id: 'completed-task-id',
        title: 'Completed Task',
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      final dayWithCompletedTask = TestFactory.createTestDay(
        id: '2023-01-01',
        date: DateTime(2023, 1, 1),
        dailyTasks: [completedTask],
        completedTaskIds: [completedTask.id],
      );
      await dayBox.put(dayWithCompletedTask.id, dayWithCompletedTask);
      await taskBox.put(completedTask.id, completedTask);

      await TaskService.resetTask(
        completedTask,
        date: dayWithCompletedTask.date,
      );

      final updatedTask = taskBox.get(completedTask.id);
      expect(updatedTask?.isCompleted, isFalse);
      expect(updatedTask?.completedAt, isNull);

      final updatedDay = dayBox.get(dayWithCompletedTask.id);
      expect(updatedDay?.completedTaskIds, isEmpty);
    });

    test('createTask adds task to day and task box', () async {
      final newTask = await TaskService.createTask(
        title: 'New Task',
        energyReward: 10,
        category: TaskCategory.selfCare,
        date: testDay.date,
      );

      final savedTask = taskBox.get(newTask.id);
      expect(savedTask, isNotNull);
      expect(savedTask?.title, equals('New Task'));

      final updatedDay = dayBox.get(testDay.id);
      expect(updatedDay?.dailyTasks.length, equals(1));
      expect(updatedDay?.dailyTasks[0].id, equals(newTask.id));
    });

    test('updateTask updates task in both boxes', () async {
      // Add initial task and day to boxes
      await taskBox.put(testTask.id, testTask);
      await dayBox.put(testDay.id, testDay);

      testTask.title = 'Updated Task';
      testTask.energyReward = 10;
      testTask.category = TaskCategory.selfCare;

      await TaskService.updateTask(testTask, date: testDay.date);

      final savedTask = taskBox.get(testTask.id);
      expect(savedTask?.title, equals('Updated Task'));
      expect(savedTask?.energyReward, equals(10));

      final updatedDay = dayBox.get(testDay.id);
      expect(updatedDay?.dailyTasks[0].title, equals('Updated Task'));
    });

    test('deleteTask removes task from both boxes', () async {
      // Add initial task and day to boxes
      await taskBox.put(testTask.id, testTask);
      await dayBox.put(testDay.id, testDay);

      await TaskService.deleteTask(testTask, date: testDay.date);

      final deletedTask = taskBox.get(testTask.id);
      expect(deletedTask, isNull);

      final updatedDay = dayBox.get(testDay.id);
      expect(updatedDay?.dailyTasks, isEmpty);
    });

    test('getTask returns task when it exists', () async {
      // Add task to box
      await taskBox.put(testTask.id, testTask);

      final result = await TaskService.getTask(testTask.id);

      expect(result, equals(testTask));
    });

    test('getTask returns null when task does not exist', () async {
      final result = await TaskService.getTask('non-existent-id');

      expect(result, isNull);
    });
  });
}
