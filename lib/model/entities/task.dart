import 'package:hive_ce/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(3)
  int energyReward;

  @HiveField(4)
  @Deprecated('Use completion status from Day entity instead')
  bool isCompleted;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  TaskCategory category;

  @HiveField(7)
  final DateTime createdDate;

  @HiveField(8)
  List<int>? repeatDayIndices;

  Task({
    required this.id,
    required this.title,
    required this.energyReward,
    this.isCompleted = false,
    this.completedAt,
    required this.category,
    DateTime? createdDate,
    this.repeatDayIndices,
  }) : createdDate = createdDate ?? DateTime.now();

  factory Task.create({
    required String title,
    required int energyReward,
    required TaskCategory category,
    List<int>? repeatDayIndices,
  }) {
    final now = DateTime.now();
    return Task(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      energyReward: energyReward,
      category: category,
      createdDate: now,
      repeatDayIndices: repeatDayIndices,
    );
  }

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }

  void reset() {
    isCompleted = false;
    completedAt = null;
  }
}

@HiveType(typeId: 1)
enum TaskCategory {
  @HiveField(0)
  selfCare,
  @HiveField(1)
  productivity,
  @HiveField(2)
  exercise,
  @HiveField(3)
  mindfulness,
}
