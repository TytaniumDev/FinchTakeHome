import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

/// Custom adapter for Day that handles migration from List<Task> to List<String>
/// for the dailyTaskIds field (field 5).
///
/// This adapter ensures backwards compatibility when reading old Day records
/// that have List<Task> in field 5, converting them to List<String> of task IDs.
class DayAdapterMigration extends TypeAdapter<Day> {
  @override
  final typeId = 6;

  @override
  Day read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Handle migration for field 5: List<Task> -> List<String>
    List<String> dailyTaskIds;
    final field5 = fields[5];
    
    if (field5 == null) {
      dailyTaskIds = [];
    } else if (field5 is List) {
      if (field5.isEmpty) {
        // Empty list - use as-is
        dailyTaskIds = [];
      } else if (field5.first is Task) {
        // Old format: List<Task> - migrate to List<String>
        debugPrint(
          'DayAdapterMigration: Migrating field 5 from List<Task> to List<String>',
        );
        dailyTaskIds = (field5 as List<Task>).map((task) => task.id).toList();
        debugPrint(
          'DayAdapterMigration: Migrated ${dailyTaskIds.length} task IDs',
        );
      } else {
        // New format: List<String> - use as-is
        try {
          dailyTaskIds = field5.cast<String>();
        } catch (e) {
          // Fallback: if cast fails, try to extract IDs if they're Tasks
          debugPrint(
            'DayAdapterMigration: Error casting field 5, attempting migration: $e',
          );
          dailyTaskIds = field5
              .where((item) => item is Task)
              .map((item) => (item as Task).id)
              .toList();
          if (dailyTaskIds.isEmpty && field5.every((item) => item is String)) {
            // Last resort: try direct cast again
            dailyTaskIds = List<String>.from(field5);
          }
        }
      }
    } else {
      // Unexpected type - default to empty list
      debugPrint(
        'DayAdapterMigration: Unexpected type for field 5: ${field5.runtimeType}, defaulting to empty list',
      );
      dailyTaskIds = [];
    }

    return Day(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      checkedIn: fields[2] == null ? false : fields[2] as bool,
      energy: fields[3] == null ? 0 : (fields[3] as num).toInt(),
      completedTaskIds: (fields[4] as List?)?.cast<String>() ?? [],
      dailyTaskIds: dailyTaskIds,
      rainbowStonesEarned: fields[7] == null ? 0 : (fields[7] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Day obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.checkedIn)
      ..writeByte(3)
      ..write(obj.energy)
      ..writeByte(4)
      ..write(obj.completedTaskIds)
      ..writeByte(5)
      ..write(obj.dailyTaskIds)
      ..writeByte(7)
      ..write(obj.rainbowStonesEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayAdapterMigration &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
