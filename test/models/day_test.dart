import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/service_locator_test_helper.dart';

import '../helpers/day_test_helper.dart';

class TestDateTimeService implements DateTimeService {
  DateTime _currentDate = DateTime(2023, 1, 1);
  int _dayOffset = 0;

  void setCurrentDate(DateTime date) {
    _currentDate = date;
  }

  @override
  DateTime getCurrentDate() {
    return _currentDate;
  }

  @override
  String generateDayId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> setDayOffset(int offset) async {
    _dayOffset = offset;
  }

  @override
  Future<int> getDayOffset() async {
    return _dayOffset;
  }

  @override
  Future<void> resetDayOffset() async {
    _dayOffset = 0;
  }

  @override
  Future<void> incrementDayOffset(int amount) async {
    _dayOffset += amount;
  }

  @override
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  bool isToday(DateTime date) {
    final currentDate = getCurrentDate();
    return isSameDay(date, currentDate);
  }

  @override
  bool isYesterday(DateTime date) {
    final yesterday = getCurrentDate().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}

void main() {
  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });
  
  group('Day Model Tests', () {
    late Day testDay;
    late TestDateTimeService testDateTimeService;

    setUp(() {
      testDateTimeService = TestDateTimeService();

      // Create a day for each test
      testDay = Day(
        id: '2023-01-01',
        date: DateTime(2023, 1, 1),
        checkedIn: false,
        energy: 0,
        completedTaskIds: [],
        dailyTasks: [],
        rainbowStonesEarned: 0,
      );
    });

    test('Day constructor initializes with correct values', () {
      expect(testDay.id, equals('2023-01-01'));
      expect(testDay.date, equals(DateTime(2023, 1, 1)));
      expect(testDay.checkedIn, isFalse);
      expect(testDay.energy, equals(0));
      expect(testDay.completedTaskIds, isEmpty);
      expect(testDay.dailyTasks, isEmpty);
      expect(testDay.rainbowStonesEarned, equals(0));
    });

    test('Day.create factory creates day with correct initial values', () {
      final date = DateTime(2023, 1, 1);
      final day = TestDay.create(date, testDateTimeService);

      expect(day.id, equals('2023-01-01'));
      expect(day.date, equals(DateTime(2023, 1, 1)));
      expect(day.checkedIn, isFalse);
      expect(day.energy, equals(0));
      expect(day.completedTaskIds, isEmpty);
      expect(day.dailyTasks, isEmpty);
      expect(day.rainbowStonesEarned, equals(0));
    });

    test('hasCheckedIn returns correct value', () {
      testDay.checkedIn = false;
      expect(testDay.hasCheckedIn(), isFalse);

      testDay.checkedIn = true;
      expect(testDay.hasCheckedIn(), isTrue);
    });

    test('getTotalEnergy returns correct value', () {
      testDay.energy = 0;
      expect(testDay.getTotalEnergy(), equals(0));

      testDay.energy = 10;
      expect(testDay.getTotalEnergy(), equals(10));
    });

    test('addEnergy correctly adds energy', () {
      testDay.energy = 5;
      testDay.addEnergy(10);
      expect(testDay.energy, equals(15));

      testDay.addEnergy(-5); // Edge case: negative energy
      expect(testDay.energy, equals(10));
    });

    test('completeTask correctly adds task ID to completed tasks', () {
      expect(testDay.completedTaskIds, isEmpty);

      testDay.completeTask('task-1');
      expect(testDay.completedTaskIds, contains('task-1'));
      expect(testDay.completedTaskIds.length, equals(1));

      // Adding the same task again should not duplicate
      testDay.completeTask('task-1');
      expect(testDay.completedTaskIds.length, equals(1));

      testDay.completeTask('task-2');
      expect(testDay.completedTaskIds, contains('task-2'));
      expect(testDay.completedTaskIds.length, equals(2));
    });

    test('isTaskCompleted correctly identifies if task is completed', () {
      testDay.completedTaskIds = ['task-1', 'task-2'];

      expect(testDay.isTaskCompleted('task-1'), isTrue);
      expect(testDay.isTaskCompleted('task-2'), isTrue);
      expect(testDay.isTaskCompleted('task-3'), isFalse);
    });

    test('checkIn correctly marks day as checked in', () {
      testDay.checkedIn = false;
      testDay.checkIn();
      expect(testDay.checkedIn, isTrue);
    });

    test('addRainbowStones correctly adds stones', () {
      testDay.rainbowStonesEarned = 5;
      testDay.addRainbowStones(10);
      expect(testDay.rainbowStonesEarned, equals(15));

      testDay.addRainbowStones(-5); // Edge case: negative stones
      expect(testDay.rainbowStonesEarned, equals(10));
    });

    test('isToday correctly identifies if day is today', () {
      // Set the current date
      testDateTimeService.setCurrentDate(DateTime(2023, 1, 1));

      // Same day
      final todayDay = TestDay(
        id: '2023-01-01',
        date: DateTime(2023, 1, 1),
        checkedIn: false,
        energy: 0,
        dateTimeService: testDateTimeService,
      );
      expect(todayDay.isToday(), isTrue);

      // Different day
      final differentDay = TestDay(
        id: '2023-01-02',
        date: DateTime(2023, 1, 2),
        checkedIn: false,
        energy: 0,
        dateTimeService: testDateTimeService,
      );
      expect(differentDay.isToday(), isFalse);
    });

    test('isYesterday correctly identifies if day is yesterday', () {
      // Set the current date
      testDateTimeService.setCurrentDate(DateTime(2023, 1, 2));

      // Yesterday
      final yesterdayDay = TestDay(
        id: '2023-01-01',
        date: DateTime(2023, 1, 1),
        checkedIn: false,
        energy: 0,
        dateTimeService: testDateTimeService,
      );
      expect(yesterdayDay.isYesterday(), isTrue);

      // Today
      final todayDay = TestDay(
        id: '2023-01-02',
        date: DateTime(2023, 1, 2),
        checkedIn: false,
        energy: 0,
        dateTimeService: testDateTimeService,
      );
      expect(todayDay.isYesterday(), isFalse);

      // Day before yesterday
      final twoDaysAgoDay = TestDay(
        id: '2022-12-31',
        date: DateTime(2022, 12, 31),
        checkedIn: false,
        energy: 0,
        dateTimeService: testDateTimeService,
      );
      expect(twoDaysAgoDay.isYesterday(), isFalse);
    });

    test('getDateString returns correct formatted date string', () {
      final day1 = Day(
        id: '2023-01-01',
        date: DateTime(2023, 1, 1),
        checkedIn: false,
        energy: 0,
      );
      expect(day1.getDateString(), equals('2023-01-01'));

      final day2 = Day(
        id: '2023-12-31',
        date: DateTime(2023, 12, 31),
        checkedIn: false,
        energy: 0,
      );
      expect(day2.getDateString(), equals('2023-12-31'));

      final day3 = Day(
        id: '2023-05-07',
        date: DateTime(2023, 5, 7),
        checkedIn: false,
        energy: 0,
      );
      expect(day3.getDateString(), equals('2023-05-07'));
    });

    test('dailyTasks can be added and accessed', () {
      expect(testDay.dailyTasks, isEmpty);

      final task1 = Task.create(
        title: 'Task 1',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      final task2 = Task.create(
        title: 'Task 2',
        energyReward: 10,
        category: TaskCategory.selfCare,
      );

      testDay.dailyTasks.add(task1);
      testDay.dailyTasks.add(task2);

      expect(testDay.dailyTasks.length, equals(2));
      expect(testDay.dailyTasks[0].title, equals('Task 1'));
      expect(testDay.dailyTasks[1].title, equals('Task 2'));
    });
  });
}
