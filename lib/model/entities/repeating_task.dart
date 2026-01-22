import 'package:hive_ce/hive.dart';
import 'task.dart';
import 'task_base.dart';

part 'repeating_task.g.dart';

@HiveType(typeId: 9)
class RepeatingTask extends TaskBase with HiveObjectMixin {
  /// Counter to ensure unique IDs even when created within the same microsecond
  static int _idCounter = 0;
  @HiveField(0)
  final String id;

  @HiveField(1)
  @override
  String title;

  @HiveField(2)
  @override
  int energyReward;

  @HiveField(3)
  @override
  TaskCategory category;

  @HiveField(4)
  List<int> repeatDayIndices;

  @HiveField(5)
  final DateTime createdDate;

  @HiveField(6)
  bool isActive;

  RepeatingTask({
    required this.id,
    required this.title,
    required this.energyReward,
    required this.category,
    required this.repeatDayIndices,
    DateTime? createdDate,
    this.isActive = true,
  }) : createdDate = createdDate ?? DateTime.now();

  factory RepeatingTask.create({
    required String title,
    required int energyReward,
    required TaskCategory category,
    required List<int> repeatDayIndices,
  }) {
    final now = DateTime.now();
    final uniqueId = 'repeat_${now.microsecondsSinceEpoch}_${_idCounter++}';
    return RepeatingTask(
      id: uniqueId,
      title: title,
      energyReward: energyReward,
      category: category,
      repeatDayIndices: repeatDayIndices,
      createdDate: now,
    );
  }
}
