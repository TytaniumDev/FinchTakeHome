import 'package:flutter_test/flutter_test.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/services/repeating_task_service.dart';
import 'package:hive_ce/hive.dart';
import '../helpers/service_locator_test_helper.dart';

void main() {
  late Box<RepeatingTask> testBox;

  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();

    // Initialize Hive for testing
    Hive.init('test_repeating_task_service');

    // Register adapters
    Hive.registerAdapter(RepeatingTaskAdapter());
    Hive.registerAdapter(TaskCategoryAdapter());

    // Open test box
    testBox = await Hive.openBox<RepeatingTask>('repeatingTasks_test');

    // Enable test mode
    RepeatingTaskService.enableTestMode(testBox);
  });

  setUp(() async {
    // Clear the box before each test
    await testBox.clear();
  });

  tearDownAll(() async {
    // Disable test mode
    RepeatingTaskService.disableTestMode();

    // Close Hive and clean up
    await Hive.close();
    await Hive.deleteBoxFromDisk('repeatingTasks_test');
  });

  group('RepeatingTaskService Tests', () {
    test('createRepeatingTask creates and saves a new template', () async {
      final template = await RepeatingTaskService.createRepeatingTask(
        title: 'Test Recurring Task',
        energyReward: 10,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.monday, DateTime.wednesday],
      );

      expect(template.id, isNotEmpty);
      expect(template.title, equals('Test Recurring Task'));
      expect(template.energyReward, equals(10));
      expect(template.category, equals(TaskCategory.productivity));
      expect(template.repeatDayIndices, equals([DateTime.monday, DateTime.wednesday]));
      expect(template.isActive, isTrue);

      // Verify it was saved
      final retrieved = await RepeatingTaskService.getRepeatingTask(template.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Test Recurring Task'));
    });

    test('getRepeatingTask retrieves existing template', () async {
      final created = await RepeatingTaskService.createRepeatingTask(
        title: 'Retrieve Test',
        energyReward: 5,
        category: TaskCategory.exercise,
        repeatDayIndices: [DateTime.tuesday],
      );

      final retrieved = await RepeatingTaskService.getRepeatingTask(created.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(created.id));
      expect(retrieved.title, equals('Retrieve Test'));
    });

    test('getRepeatingTask returns null for non-existent template', () async {
      final retrieved = await RepeatingTaskService.getRepeatingTask('non-existent-id');
      expect(retrieved, isNull);
    });

    test('getAllActiveRepeatingTasks returns only active templates', () async {
      final active1 = await RepeatingTaskService.createRepeatingTask(
        title: 'Active 1',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.monday],
      );

      final active2 = await RepeatingTaskService.createRepeatingTask(
        title: 'Active 2',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.tuesday],
      );

      final inactive = await RepeatingTaskService.createRepeatingTask(
        title: 'Inactive',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.wednesday],
      );

      // Verify all three were created
      expect(await RepeatingTaskService.getRepeatingTask(active1.id), isNotNull);
      expect(await RepeatingTaskService.getRepeatingTask(active2.id), isNotNull);
      expect(await RepeatingTaskService.getRepeatingTask(inactive.id), isNotNull);

      await RepeatingTaskService.deactivateRepeatingTask(inactive.id);

      final active = await RepeatingTaskService.getAllActiveRepeatingTasks();
      expect(active, hasLength(2));
      expect(active.every((t) => t.isActive), isTrue);
      expect(active.any((t) => t.title == 'Inactive'), isFalse);
    });

    test('updateRepeatingTask persists changes', () async {
      final template = await RepeatingTaskService.createRepeatingTask(
        title: 'Original Title',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.monday],
      );

      template.title = 'Updated Title';
      template.energyReward = 10;
      template.repeatDayIndices = [DateTime.monday, DateTime.friday];

      await RepeatingTaskService.updateRepeatingTask(template);

      final retrieved = await RepeatingTaskService.getRepeatingTask(template.id);
      expect(retrieved!.title, equals('Updated Title'));
      expect(retrieved.energyReward, equals(10));
      expect(retrieved.repeatDayIndices, equals([DateTime.monday, DateTime.friday]));
    });

    test('deactivateRepeatingTask sets isActive to false', () async {
      final template = await RepeatingTaskService.createRepeatingTask(
        title: 'To Deactivate',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.monday],
      );

      expect(template.isActive, isTrue);

      await RepeatingTaskService.deactivateRepeatingTask(template.id);

      final retrieved = await RepeatingTaskService.getRepeatingTask(template.id);
      expect(retrieved!.isActive, isFalse);
    });

    test('activateRepeatingTask sets isActive to true', () async {
      final template = await RepeatingTaskService.createRepeatingTask(
        title: 'To Activate',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.monday],
      );

      await RepeatingTaskService.deactivateRepeatingTask(template.id);
      expect((await RepeatingTaskService.getRepeatingTask(template.id))!.isActive, isFalse);

      await RepeatingTaskService.activateRepeatingTask(template.id);

      final retrieved = await RepeatingTaskService.getRepeatingTask(template.id);
      expect(retrieved!.isActive, isTrue);
    });

    test('deleteRepeatingTask removes template from storage', () async {
      final template = await RepeatingTaskService.createRepeatingTask(
        title: 'To Delete',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.monday],
      );

      expect(await RepeatingTaskService.getRepeatingTask(template.id), isNotNull);

      await RepeatingTaskService.deleteRepeatingTask(template.id);

      expect(await RepeatingTaskService.getRepeatingTask(template.id), isNull);
    });
  });
}
