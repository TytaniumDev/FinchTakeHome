import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/model/entities/pet_energy.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'pet.g.dart';

@HiveType(typeId: 2)
class Pet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime birthDate;

  @HiveField(3)
  DateTime lastCheckInTime;

  @HiveField(4)
  PetEnergy energy;

  @HiveField(5)
  PetGrowthStage growthStage;

  @HiveField(6)
  Gender gender;

  Pet({
    String? id,
    required this.name,
    required this.birthDate,
    required this.energy,
    required this.growthStage,
    required this.gender,
    DateTime? lastCheckInTime,
  }) : id = id ?? const Uuid().v4(),
       lastCheckInTime = lastCheckInTime ?? DateTime.now();

  factory Pet.create({
    required String name,
    required Gender gender,
    DateTimeService? dateTimeService,
  }) {
    final now = DateTime.now();
    return Pet(
      name: name,
      birthDate: now,
      energy: PetEnergy.create(dateTimeService: dateTimeService),
      growthStage: PetGrowthStage.egg,
      gender: gender,
    );
  }

  double getEnergyPercentage() => energy.getEnergyPercentage();

  bool isReadyToEvolve() {
    switch (growthStage) {
      case PetGrowthStage.egg:
        return energy.fullEnergyDays >= 1;

      case PetGrowthStage.baby:
        return energy.fullEnergyDays >= 5;

      case PetGrowthStage.toddler:
        return energy.fullEnergyDays >= 10;

      case PetGrowthStage.child:
        return energy.fullEnergyDays >= 15;

      case PetGrowthStage.teenager:
        return energy.fullEnergyDays >= 25;

      case PetGrowthStage.adult:
        return false;
    }
  }

  int getRequiredFullEnergyDaysForEvolution() {
    switch (growthStage) {
      case PetGrowthStage.egg:
        return 1;
      case PetGrowthStage.baby:
        return 5;
      case PetGrowthStage.toddler:
        return 10;
      case PetGrowthStage.child:
        return 15;
      case PetGrowthStage.teenager:
        return 25;
      case PetGrowthStage.adult:
        return 0;
    }
  }

  void checkIn() {
    lastCheckInTime = DateTime.now();
  }

  bool hasCheckedInToday() {
    final now = DateTime.now();
    return lastCheckInTime.year == now.year &&
        lastCheckInTime.month == now.month &&
        lastCheckInTime.day == now.day;
  }

  void evolve() {
    if (!isReadyToEvolve()) {
      return;
    }

    switch (growthStage) {
      case PetGrowthStage.egg:
        growthStage = PetGrowthStage.baby;
        energy.setMaxEnergyForGrowthStage(PetGrowthStage.baby);
        break;
      case PetGrowthStage.baby:
        growthStage = PetGrowthStage.toddler;
        energy.setMaxEnergyForGrowthStage(PetGrowthStage.toddler);
        break;
      case PetGrowthStage.toddler:
        growthStage = PetGrowthStage.child;
        energy.setMaxEnergyForGrowthStage(PetGrowthStage.child);
        break;
      case PetGrowthStage.child:
        growthStage = PetGrowthStage.teenager;
        energy.setMaxEnergyForGrowthStage(PetGrowthStage.teenager);
        break;
      case PetGrowthStage.teenager:
        growthStage = PetGrowthStage.adult;
        energy.setMaxEnergyForGrowthStage(PetGrowthStage.adult);
        break;
      case PetGrowthStage.adult:
        break;
    }
  }
}

@HiveType(typeId: 3)
enum PetGrowthStage {
  @HiveField(0)
  egg,
  @HiveField(1)
  baby,
  @HiveField(2)
  toddler,
  @HiveField(3)
  child,
  @HiveField(4)
  teenager,
  @HiveField(5)
  adult,
}

@HiveType(typeId: 4)
enum Gender {
  @HiveField(0)
  male,
  @HiveField(1)
  female,
  @HiveField(2)
  other,
}
