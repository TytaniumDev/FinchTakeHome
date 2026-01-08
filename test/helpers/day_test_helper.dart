import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:hive_ce/hive.dart';

class TestDay extends Day {
  final DateTimeService dateTimeService;

  TestDay({
    required super.id,
    required super.date,
    super.checkedIn = false,
    super.energy = 0,
    super.completedTaskIds,
    super.dailyTasks,
    super.rainbowStonesEarned = 0,
    required this.dateTimeService,
  });

  // Factory method to create a TestDay with the given date and dateTimeService
  static TestDay create(DateTime date, DateTimeService dateTimeService) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final id = dateTimeService.generateDayId(normalizedDate);

    return TestDay(
      id: id,
      date: normalizedDate,
      checkedIn: false,
      energy: 0,
      completedTaskIds: [],
      dailyTasks: [],
      rainbowStonesEarned: 0,
      dateTimeService: dateTimeService,
    );
  }

  // Override methods that use ServiceLocator
  @override
  bool isToday() {
    final currentDate = dateTimeService.getCurrentDate();
    return date.year == currentDate.year &&
        date.month == currentDate.month &&
        date.day == currentDate.day;
  }

  @override
  bool isYesterday() {
    final currentDate = dateTimeService.getCurrentDate();
    final yesterday = currentDate.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}

/// A mock implementation of DayService for testing
class MockDayService {
  static Box<Day>? _dayBox;

  /// Set the test box to be used by the mock service
  static void setDayBox(Box<Day> box) {
    _dayBox = box;
  }

  /// Mock implementation of DayService.getOrCreate
  static Future<Day> getOrCreate(DateTime date) async {
    if (_dayBox == null) {
      throw Exception('Day box not initialized for testing');
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dayId =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    var day = _dayBox!.get(dayId);
    if (day == null) {
      day = Day(
        id: dayId,
        date: normalizedDate,
        checkedIn: false,
        energy: 0,
        completedTaskIds: [],
        dailyTasks: [],
      );
      await _dayBox!.put(day.id, day);
    }

    return day;
  }

  /// Mock implementation of DayService.getDayRecord
  static Future<Day?> getDayRecord(DateTime date) async {
    if (_dayBox == null) {
      throw Exception('Day box not initialized for testing');
    }

    final dayId =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return _dayBox!.get(dayId);
  }
}
