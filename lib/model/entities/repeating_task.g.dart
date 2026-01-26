// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repeating_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepeatingTaskAdapter extends TypeAdapter<RepeatingTask> {
  @override
  final typeId = 9;

  @override
  RepeatingTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepeatingTask(
      id: fields[0] as String,
      title: fields[1] as String,
      energyReward: (fields[2] as num).toInt(),
      category: fields[3] as TaskCategory,
      repeatDayIndices: (fields[4] as List).cast<int>(),
      createdDate: fields[5] as DateTime?,
      isActive: fields[6] == null ? true : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RepeatingTask obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.energyReward)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.repeatDayIndices)
      ..writeByte(5)
      ..write(obj.createdDate)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatingTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
