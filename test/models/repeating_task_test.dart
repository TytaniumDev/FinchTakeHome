import 'package:flutter_test/flutter_test.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/entities/task.dart';

void main() {
  group('RepeatingTask Model Tests', () {
    late RepeatingTask repeatingTask;

    setUp(() {
      repeatingTask = RepeatingTask(
        id: 'test-repeating-id',
        title: 'Daily Exercise',
        energyReward: 10,
        category: TaskCategory.exercise,
        repeatDayIndices: [DateTime.monday, DateTime.wednesday, DateTime.friday],
        createdDate: DateTime(2023, 1, 1),
        isActive: true,
      );
    });

    test('RepeatingTask constructor initializes with correct values', () {
      expect(repeatingTask.id, equals('test-repeating-id'));
      expect(repeatingTask.title, equals('Daily Exercise'));
      expect(repeatingTask.energyReward, equals(10));
      expect(repeatingTask.category, equals(TaskCategory.exercise));
      expect(repeatingTask.repeatDayIndices, equals([DateTime.monday, DateTime.wednesday, DateTime.friday]));
      expect(repeatingTask.createdDate, equals(DateTime(2023, 1, 1)));
      expect(repeatingTask.isActive, isTrue);
    });

    test('RepeatingTask.create factory creates task with correct initial values', () {
      final now = DateTime.now();
      final task = RepeatingTask.create(
        title: 'Morning Meditation',
        energyReward: 5,
        category: TaskCategory.mindfulness,
        repeatDayIndices: [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday],
      );

      expect(task.title, equals('Morning Meditation'));
      expect(task.energyReward, equals(5));
      expect(task.category, equals(TaskCategory.mindfulness));
      expect(task.repeatDayIndices, hasLength(5));
      expect(task.isActive, isTrue);

      // ID should be based on timestamp with 'repeat_' prefix (e.g., "repeat_1234567890_0")
      expect(task.id, isNotEmpty);
      expect(task.id, startsWith('repeat_'));
      // Extract timestamp part and verify format is "timestamp_counter"
      final idPart = task.id.substring('repeat_'.length);
      expect(idPart.contains('_'), isTrue);
      final parts = idPart.split('_');
      expect(parts.length, equals(2));
      expect(int.tryParse(parts[0]), isNotNull); // timestamp part
      expect(int.tryParse(parts[1]), isNotNull); // counter part

      // Created date should be close to now
      final difference = now.difference(task.createdDate).inSeconds.abs();
      expect(difference, lessThan(5));
    });

    test('RepeatingTask can be deactivated and activated', () {
      expect(repeatingTask.isActive, isTrue);

      repeatingTask.isActive = false;
      expect(repeatingTask.isActive, isFalse);

      repeatingTask.isActive = true;
      expect(repeatingTask.isActive, isTrue);
    });

    test('RepeatingTask fields can be updated', () {
      repeatingTask.title = 'Updated Exercise';
      repeatingTask.energyReward = 15;
      repeatingTask.category = TaskCategory.selfCare;
      repeatingTask.repeatDayIndices = [DateTime.sunday];

      expect(repeatingTask.title, equals('Updated Exercise'));
      expect(repeatingTask.energyReward, equals(15));
      expect(repeatingTask.category, equals(TaskCategory.selfCare));
      expect(repeatingTask.repeatDayIndices, equals([DateTime.sunday]));
    });

    test('RepeatingTask supports all days of week', () {
      final allDaysTask = RepeatingTask.create(
        title: 'Daily Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ],
      );

      expect(allDaysTask.repeatDayIndices, hasLength(7));
      expect(allDaysTask.repeatDayIndices, containsAll([1, 2, 3, 4, 5, 6, 7]));
    });

    test('RepeatingTask supports single day', () {
      final mondayTask = RepeatingTask.create(
        title: 'Monday Task',
        energyReward: 5,
        category: TaskCategory.productivity,
        repeatDayIndices: [DateTime.monday],
      );

      expect(mondayTask.repeatDayIndices, hasLength(1));
      expect(mondayTask.repeatDayIndices, contains(DateTime.monday));
    });
  });
}
