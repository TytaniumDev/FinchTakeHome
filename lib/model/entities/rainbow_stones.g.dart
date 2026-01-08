// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rainbow_stones.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RainbowStonesAdapter extends TypeAdapter<RainbowStones> {
  @override
  final int typeId = 7;

  @override
  RainbowStones read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RainbowStones(
      currentAmount: (fields[0] as num).toInt(),
      totalEarned: (fields[1] as num).toInt(),
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RainbowStones obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.currentAmount)
      ..writeByte(1)
      ..write(obj.totalEarned)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RainbowStonesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
