import 'package:birdo/core/services/date_time_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mockito/mockito.dart';

class MockBox extends Mock implements Box {}

void main() {
  group('DateTimeService Tests', () {
    late DateTimeService dateTimeService;

    setUp(() {
      MockBox();

      dateTimeService = DateTimeService();
    });

    test('getCurrentDate returns current date with offset', () {
      final now = DateTime.now();
      final currentDate = dateTimeService.getCurrentDate();

      expect(currentDate.year, equals(now.year));
      expect(currentDate.month, equals(now.month));
      expect(currentDate.day, equals(now.day));
      expect(currentDate.hour, equals(0));
      expect(currentDate.minute, equals(0));
      expect(currentDate.second, equals(0));
      expect(currentDate.millisecond, equals(0));
    });

    test('generateDayId generates correct ID format', () {
      final date = DateTime(2023, 5, 15);
      final id = dateTimeService.generateDayId(date);
      expect(id, equals('2023-05-15'));

      final date2 = DateTime(2023, 12, 1);
      final id2 = dateTimeService.generateDayId(date2);
      expect(id2, equals('2023-12-01'));
    });

    test('isSameDay correctly identifies same day', () {
      final date1 = DateTime(2023, 5, 15, 10, 30);
      final date2 = DateTime(2023, 5, 15, 15, 45);
      final date3 = DateTime(2023, 5, 16, 10, 30);

      expect(dateTimeService.isSameDay(date1, date2), isTrue);
      expect(dateTimeService.isSameDay(date1, date3), isFalse);
      expect(dateTimeService.isSameDay(date2, date3), isFalse);
    });

    test('isToday correctly identifies today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 30);
      final yesterday = DateTime(now.year, now.month, now.day - 1, 10, 30);
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 30);

      expect(dateTimeService.isToday(today), isTrue);
      expect(dateTimeService.isToday(yesterday), isFalse);
      expect(dateTimeService.isToday(tomorrow), isFalse);
    });

    test('isYesterday correctly identifies yesterday', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 30);
      final yesterday = DateTime(now.year, now.month, now.day - 1, 10, 30);
      final twoDaysAgo = DateTime(now.year, now.month, now.day - 2, 10, 30);

      expect(dateTimeService.isYesterday(yesterday), isTrue);
      expect(dateTimeService.isYesterday(today), isFalse);
      expect(dateTimeService.isYesterday(twoDaysAgo), isFalse);
    });
  });
}
