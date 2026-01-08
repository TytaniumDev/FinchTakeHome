import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class DateTimeService {
  static const String _dayOffsetKey = 'day_offset';
  int _dayOffset = 0;

  Future<void> initialize() async {
    await _loadDayOffset();
  }

  DateTime getCurrentDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + _dayOffset);
  }

  Future<void> setDayOffset(int offset) async {
    _dayOffset = offset;
    final settings = await Hive.openBox(settingsBox);
    await settings.put(_dayOffsetKey, _dayOffset);
  }

  Future<int> getDayOffset() async {
    await _loadDayOffset();
    return _dayOffset;
  }

  Future<void> resetDayOffset() async {
    await setDayOffset(0);
  }

  Future<void> incrementDayOffset(int amount) async {
    await setDayOffset(_dayOffset + amount);
  }

  Future<void> _loadDayOffset() async {
    try {
      final settings = await Hive.openBox(settingsBox);
      final savedOffset = settings.get(_dayOffsetKey);
      if (savedOffset != null) {
        _dayOffset = savedOffset;
      }
    } catch (e) {
      print('Error loading day offset: $e');
    }
  }

  String generateDayId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isToday(DateTime date) {
    final currentDate = getCurrentDate();
    return isSameDay(date, currentDate);
  }

  bool isYesterday(DateTime date) {
    final yesterday = getCurrentDate().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}
