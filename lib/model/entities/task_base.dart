import 'task.dart';

/// Base class for task properties shared between Task and RepeatingTask.
///
/// This abstract class ensures compile-time safety by forcing both Task
/// and RepeatingTask to implement the same core properties. If a new field
/// is added here, the compiler will require both entities to implement it,
/// preventing accidental drift between the two models.
abstract class TaskBase {
  String get title;
  set title(String value);

  int get energyReward;
  set energyReward(int value);

  TaskCategory get category;
  set category(TaskCategory value);
}
