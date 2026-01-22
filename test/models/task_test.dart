import 'package:flutter_test/flutter_test.dart';
import 'package:birdo/model/entities/task.dart';
import '../helpers/service_locator_test_helper.dart';

void main() {
  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });
  
  group('Task Model Tests', () {
    late Task task;
    
    setUp(() {
      // Create a task for each test
      task = Task(
        id: 'test-id',
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        createdDate: DateTime(2023, 1, 1),
      );
    });
    
    test('Task constructor initializes with correct values', () {
      expect(task.id, equals('test-id'));
      expect(task.title, equals('Test Task'));
      expect(task.energyReward, equals(5));
      expect(task.isCompleted, isFalse);
      expect(task.completedAt, isNull);
      expect(task.category, equals(TaskCategory.productivity));
      expect(task.createdDate, equals(DateTime(2023, 1, 1)));
    });
    
    test('Task.create factory creates task with correct initial values', () {
      final now = DateTime.now();
      final task = Task.create(
        title: 'New Task',
        energyReward: 10,
        category: TaskCategory.selfCare,
      );
      
      expect(task.title, equals('New Task'));
      expect(task.energyReward, equals(10));
      expect(task.isCompleted, isFalse);
      expect(task.completedAt, isNull);
      expect(task.category, equals(TaskCategory.selfCare));
      
      // ID should be based on timestamp with counter suffix (e.g., "1234567890_0")
      expect(task.id, isNotEmpty);
      expect(task.id.contains('_'), isTrue);
      final parts = task.id.split('_');
      expect(parts.length, equals(2));
      expect(int.tryParse(parts[0]), isNotNull); // timestamp part
      expect(int.tryParse(parts[1]), isNotNull); // counter part
      
      // Created date should be close to now
      final difference = now.difference(task.createdDate).inSeconds.abs();
      expect(difference, lessThan(5)); // Allow 5 seconds difference for test execution
    });
    
    test('complete method correctly marks task as completed', () {
      final before = DateTime.now();

      task.complete();

      expect(task.isCompleted, isTrue);
      expect(task.completedAt, isNotNull);

      if (task.completedAt != null) {
        expect(task.completedAt!.compareTo(before), isNonNegative);
        
        // Completed time should be close to now
        final now = DateTime.now();
        final difference = now.difference(task.completedAt!).inSeconds.abs();
        expect(difference, lessThan(5)); // Allow 5 seconds difference for test execution
      }
    });
    
    test('reset method correctly resets task completion status', () {
      // First complete the task
      task.complete();
      expect(task.isCompleted, isTrue);
      expect(task.completedAt, isNotNull);
      
      // Then reset it
      task.reset();
      
      expect(task.isCompleted, isFalse);
      expect(task.completedAt, isNull);
    });
    
    test('Task categories are correctly defined', () {
      expect(TaskCategory.values.length, equals(4));
      expect(TaskCategory.values, contains(TaskCategory.selfCare));
      expect(TaskCategory.values, contains(TaskCategory.productivity));
      expect(TaskCategory.values, contains(TaskCategory.exercise));
      expect(TaskCategory.values, contains(TaskCategory.mindfulness));
    });
  });
}