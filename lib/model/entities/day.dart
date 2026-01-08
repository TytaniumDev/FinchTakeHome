import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:hive_ce/hive.dart';

part 'day.g.dart';

@HiveType(typeId: 6)
class Day extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  bool checkedIn;

  @HiveField(3)
  int energy;

  @HiveField(4)
  List<String> completedTaskIds;

  @HiveField(5)
  List<Task> dailyTasks;

  @HiveField(7)
  int rainbowStonesEarned;

  Day({
    required this.id,
    required this.date,
    this.checkedIn = false,
    this.energy = 0,
    List<String>? completedTaskIds,
    List<Task>? dailyTasks,
    this.rainbowStonesEarned = 0,
  }) : completedTaskIds = completedTaskIds ?? [],
       dailyTasks = dailyTasks ?? [];

  factory Day.create(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final id = ServiceLocator.dateTimeService.generateDayId(normalizedDate);

    return Day(
      id: id,
      date: normalizedDate,
      checkedIn: false,
      energy: 0,
      completedTaskIds: [],
      dailyTasks: [],
      rainbowStonesEarned: 0,
    );
  }

  bool hasCheckedIn() => checkedIn;

  int getTotalEnergy() => energy;

  void addEnergy(int amount) {
    energy += amount;
  }

  void completeTask(String taskId) {
    if (!completedTaskIds.contains(taskId)) {
      completedTaskIds.add(taskId);
    }
  }

  bool isTaskCompleted(String taskId) {
    return completedTaskIds.contains(taskId);
  }

  void checkIn() {
    checkedIn = true;
  }

  void addRainbowStones(int amount) {
    rainbowStonesEarned += amount;
  }

  bool isToday() {
    final currentDate = ServiceLocator.dateTimeService.getCurrentDate();
    return date.year == currentDate.year &&
        date.month == currentDate.month &&
        date.day == currentDate.day;
  }

  bool isYesterday() {
    final currentDate = ServiceLocator.dateTimeService.getCurrentDate();
    final yesterday = currentDate.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String getDateString() {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void printDebug() {
    print('Day Debug:');
    print('  ID: $id');
    print('  Date: ${date.toString()}');
    print('  Checked In: $checkedIn');
    print('  Energy: $energy');
    print('  Rainbow Stones: $rainbowStonesEarned');
    print('  Completed Task IDs: $completedTaskIds');
    print('  Daily Tasks: ${dailyTasks.length}');
    for (var task in dailyTasks) {
      print('    - ${task.title} (${task.id})');
    }
  }
}
