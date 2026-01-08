// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayAdapter extends TypeAdapter<Day> {
  @override
  final int typeId = 6;

  @override
  Day read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Day(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      checkedIn: fields[2] == null ? false : fields[2] as bool,
      energy: fields[3] == null ? 0 : (fields[3] as num).toInt(),
      completedTaskIds: (fields[4] as List?)?.cast<String>(),
      dailyTasks: (fields[5] as List?)?.cast<Task>(),
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
      ..write(obj.dailyTasks)
      ..writeByte(7)
      ..write(obj.rainbowStonesEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
