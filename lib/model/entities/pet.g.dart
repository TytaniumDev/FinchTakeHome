// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 2;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pet(
      id: fields[0] as String?,
      name: fields[1] as String,
      birthDate: fields[2] as DateTime,
      energy: fields[4] as PetEnergy,
      growthStage: fields[5] as PetGrowthStage,
      gender: fields[6] as Gender,
      lastCheckInTime: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthDate)
      ..writeByte(3)
      ..write(obj.lastCheckInTime)
      ..writeByte(4)
      ..write(obj.energy)
      ..writeByte(5)
      ..write(obj.growthStage)
      ..writeByte(6)
      ..write(obj.gender);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PetGrowthStageAdapter extends TypeAdapter<PetGrowthStage> {
  @override
  final int typeId = 3;

  @override
  PetGrowthStage read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PetGrowthStage.egg;
      case 1:
        return PetGrowthStage.baby;
      case 2:
        return PetGrowthStage.toddler;
      case 3:
        return PetGrowthStage.child;
      case 4:
        return PetGrowthStage.teenager;
      case 5:
        return PetGrowthStage.adult;
      default:
        return PetGrowthStage.egg;
    }
  }

  @override
  void write(BinaryWriter writer, PetGrowthStage obj) {
    switch (obj) {
      case PetGrowthStage.egg:
        writer.writeByte(0);
      case PetGrowthStage.baby:
        writer.writeByte(1);
      case PetGrowthStage.toddler:
        writer.writeByte(2);
      case PetGrowthStage.child:
        writer.writeByte(3);
      case PetGrowthStage.teenager:
        writer.writeByte(4);
      case PetGrowthStage.adult:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetGrowthStageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 4;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      case 2:
        return Gender.other;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
      case Gender.female:
        writer.writeByte(1);
      case Gender.other:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
