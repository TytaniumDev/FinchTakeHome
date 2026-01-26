import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'task.dart';
import 'task_base.dart';

part 'repeating_task.g.dart';

const _uuid = Uuid();

@HiveType(typeId: 9)
class RepeatingTask extends TaskBase with HiveObjectMixin {
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
    return RepeatingTask(
      id: _uuid.v4(),
      title: title,
      energyReward: energyReward,
      category: category,
      repeatDayIndices: repeatDayIndices,
      createdDate: DateTime.now(),
    );
  }
}
