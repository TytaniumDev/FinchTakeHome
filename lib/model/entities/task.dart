import 'package:hive_ce/hive.dart';
import 'task_base.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends TaskBase with HiveObjectMixin {
  /// Counter to ensure unique IDs even when created within the same microsecond
  static int _idCounter = 0;

  @HiveField(0)
  final String id;

  @HiveField(1)
  @override
  String title;

  @HiveField(3)
  @override
  int energyReward;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  @override
  TaskCategory category;

  @HiveField(7)
  final DateTime createdDate;

  @HiveField(8)
  @Deprecated('Use repeatingTaskId to link to RepeatingTask template instead')
  List<int>? repeatDayIndices;

  @HiveField(9)
  String? repeatingTaskId;

  Task({
    required this.id,
    required this.title,
    required this.energyReward,
    this.isCompleted = false,
    this.completedAt,
    required this.category,
    DateTime? createdDate,
    this.repeatDayIndices,
    this.repeatingTaskId,
  }) : createdDate = createdDate ?? DateTime.now();

  factory Task.create({
    required String title,
    required int energyReward,
    required TaskCategory category,
    List<int>? repeatDayIndices,
    String? repeatingTaskId,
  }) {
    final now = DateTime.now();
    final uniqueId = '${now.microsecondsSinceEpoch}_${_idCounter++}';
    return Task(
      id: uniqueId,
      title: title,
      energyReward: energyReward,
      category: category,
      createdDate: now,
      repeatDayIndices: repeatDayIndices,
      repeatingTaskId: repeatingTaskId,
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
