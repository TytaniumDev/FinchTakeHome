import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:hive_ce/hive.dart';

part 'pet_energy.g.dart';

@HiveType(typeId: 5)
class PetEnergy {
  @HiveField(0)
  double maxEnergy;

  @HiveField(1)
  double currentEnergy;

  @HiveField(2)
  DateTime lastUpdatedTime;

  @HiveField(3)
  double totalEnergyEarned;

  @HiveField(4)
  int fullEnergyDays;

  final DateTimeService _dateTimeService;

  PetEnergy({
    required this.maxEnergy,
    required this.currentEnergy,
    required this.lastUpdatedTime,
    required this.totalEnergyEarned,
    required this.fullEnergyDays,
    DateTimeService? dateTimeService,
  }) : _dateTimeService = dateTimeService ?? ServiceLocator.dateTimeService;

  factory PetEnergy.create({DateTimeService? dateTimeService}) {
    final dts = dateTimeService ?? ServiceLocator.dateTimeService;
    return PetEnergy(
      maxEnergy: 15.0,
      currentEnergy: 0.0,
      lastUpdatedTime: dts.getCurrentDate(),
      totalEnergyEarned: 0.0,
      fullEnergyDays: 0,
      dateTimeService: dts,
    );
  }

  int getCurrentEnergy() => currentEnergy.round();

  int getMaxEnergy() => maxEnergy.round();

  bool isFullEnergy() => currentEnergy >= maxEnergy;

  double getEnergyPercentage() => currentEnergy / maxEnergy;

  void addEnergy(double amount) {
    currentEnergy = (currentEnergy + amount).clamp(0.0, maxEnergy);
    totalEnergyEarned += amount;
    lastUpdatedTime = _dateTimeService.getCurrentDate();
  }

  void increaseMaxEnergy(double amount) {
    maxEnergy += amount;
    lastUpdatedTime = _dateTimeService.getCurrentDate();
  }

  void markFullEnergyDay() {
    if (isFullEnergy()) {
      fullEnergyDays++;
      lastUpdatedTime = _dateTimeService.getCurrentDate();
    }
  }

  void setCurrentEnergy(int energy) {
    currentEnergy = energy.toDouble().clamp(0.0, maxEnergy);
    lastUpdatedTime = _dateTimeService.getCurrentDate();
  }

  void resetForNewDay() {
    currentEnergy = 0.0;
    lastUpdatedTime = _dateTimeService.getCurrentDate();
  }

  void setMaxEnergyForGrowthStage(PetGrowthStage stage) {
    switch (stage) {
      case PetGrowthStage.egg:
        maxEnergy = 15.0;
        break;
      case PetGrowthStage.baby:
        maxEnergy = 20.0;
        break;
      case PetGrowthStage.toddler:
        maxEnergy = 25.0;
        break;
      case PetGrowthStage.child:
        maxEnergy = 30.0;
        break;
      case PetGrowthStage.teenager:
        maxEnergy = 40.0;
        break;
      case PetGrowthStage.adult:
        maxEnergy = 50.0;
        break;
    }
    lastUpdatedTime = _dateTimeService.getCurrentDate();
  }
}
