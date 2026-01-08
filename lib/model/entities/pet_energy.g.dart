// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_energy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetEnergyAdapter extends TypeAdapter<PetEnergy> {
  @override
  final int typeId = 5;

  @override
  PetEnergy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetEnergy(
      maxEnergy: (fields[0] as num).toDouble(),
      currentEnergy: (fields[1] as num).toDouble(),
      lastUpdatedTime: fields[2] as DateTime,
      totalEnergyEarned: (fields[3] as num).toDouble(),
      fullEnergyDays: (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, PetEnergy obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.maxEnergy)
      ..writeByte(1)
      ..write(obj.currentEnergy)
      ..writeByte(2)
      ..write(obj.lastUpdatedTime)
      ..writeByte(3)
      ..write(obj.totalEnergyEarned)
      ..writeByte(4)
      ..write(obj.fullEnergyDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetEnergyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
