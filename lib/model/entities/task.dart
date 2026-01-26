import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'task_base.dart';

part 'task.g.dart';

const _uuid = Uuid();

@HiveType(typeId: 0)
class Task extends TaskBase with HiveObjectMixin {
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
    this.repeatingTaskId,
  }) : createdDate = createdDate ?? DateTime.now();

  factory Task.create({
    required String title,
    required int energyReward,
    required TaskCategory category,
    String? repeatingTaskId,
  }) {
    return Task(
      id: _uuid.v4(),
      title: title,
      energyReward: energyReward,
      category: category,
      createdDate: DateTime.now(),
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
