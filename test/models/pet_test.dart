import 'package:flutter_test/flutter_test.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/pet_energy.dart';
import '../helpers/service_locator_test_helper.dart';

void main() {
  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });
  
  group('Pet Model Tests', () {
    late Pet pet;
    
    setUp(() {
      // Create a pet for each test
      pet = Pet(
        id: 'test-id',
        name: 'Test Pet',
        birthDate: DateTime(2023, 1, 1),
        energy: PetEnergy.create(),
        growthStage: PetGrowthStage.egg,
        gender: Gender.male,
      );
    });
    
    test('Pet.create factory creates pet with correct initial values', () {
      final newPet = Pet.create(name: 'New Pet', gender: Gender.female);
      
      expect(newPet.name, equals('New Pet'));
      expect(newPet.gender, equals(Gender.female));
      expect(newPet.growthStage, equals(PetGrowthStage.egg));
      expect(newPet.energy.getCurrentEnergy(), equals(0));
      expect(newPet.energy.getMaxEnergy(), equals(15));
    });
    
    test('isReadyToEvolve returns correct values for different growth stages', () {
      // Egg stage
      pet.growthStage = PetGrowthStage.egg;
      pet.energy.fullEnergyDays = 0;
      expect(pet.isReadyToEvolve(), isFalse);
      
      pet.energy.fullEnergyDays = 1;
      expect(pet.isReadyToEvolve(), isTrue);
      
      // Baby stage
      pet.growthStage = PetGrowthStage.baby;
      pet.energy.fullEnergyDays = 4;
      expect(pet.isReadyToEvolve(), isFalse);
      
      pet.energy.fullEnergyDays = 5;
      expect(pet.isReadyToEvolve(), isTrue);
      
      // Toddler stage
      pet.growthStage = PetGrowthStage.toddler;
      pet.energy.fullEnergyDays = 9;
      expect(pet.isReadyToEvolve(), isFalse);
      
      pet.energy.fullEnergyDays = 10;
      expect(pet.isReadyToEvolve(), isTrue);
      
      // Child stage
      pet.growthStage = PetGrowthStage.child;
      pet.energy.fullEnergyDays = 14;
      expect(pet.isReadyToEvolve(), isFalse);
      
      pet.energy.fullEnergyDays = 15;
      expect(pet.isReadyToEvolve(), isTrue);
      
      // Teenager stage
      pet.growthStage = PetGrowthStage.teenager;
      pet.energy.fullEnergyDays = 24;
      expect(pet.isReadyToEvolve(), isFalse);
      
      pet.energy.fullEnergyDays = 25;
      expect(pet.isReadyToEvolve(), isTrue);
      
      // Adult stage
      pet.growthStage = PetGrowthStage.adult;
      pet.energy.fullEnergyDays = 100;
      expect(pet.isReadyToEvolve(), isFalse);
    });
    
    test('getRequiredFullEnergyDaysForEvolution returns correct values', () {
      pet.growthStage = PetGrowthStage.egg;
      expect(pet.getRequiredFullEnergyDaysForEvolution(), equals(1));
      
      pet.growthStage = PetGrowthStage.baby;
      expect(pet.getRequiredFullEnergyDaysForEvolution(), equals(5));
      
      pet.growthStage = PetGrowthStage.toddler;
      expect(pet.getRequiredFullEnergyDaysForEvolution(), equals(10));
      
      pet.growthStage = PetGrowthStage.child;
      expect(pet.getRequiredFullEnergyDaysForEvolution(), equals(15));
      
      pet.growthStage = PetGrowthStage.teenager;
      expect(pet.getRequiredFullEnergyDaysForEvolution(), equals(25));
      
      pet.growthStage = PetGrowthStage.adult;
      expect(pet.getRequiredFullEnergyDaysForEvolution(), equals(0));
    });
    
    test('evolve method correctly transitions between growth stages', () {
      // Egg to Baby
      pet.growthStage = PetGrowthStage.egg;
      pet.energy.fullEnergyDays = 1;
      pet.evolve();
      expect(pet.growthStage, equals(PetGrowthStage.baby));
      
      // Baby to Toddler
      pet.energy.fullEnergyDays = 5;
      pet.evolve();
      expect(pet.growthStage, equals(PetGrowthStage.toddler));
      
      // Toddler to Child
      pet.energy.fullEnergyDays = 10;
      pet.evolve();
      expect(pet.growthStage, equals(PetGrowthStage.child));
      
      // Child to Teenager
      pet.energy.fullEnergyDays = 15;
      pet.evolve();
      expect(pet.growthStage, equals(PetGrowthStage.teenager));
      
      // Teenager to Adult
      pet.energy.fullEnergyDays = 25;
      pet.evolve();
      expect(pet.growthStage, equals(PetGrowthStage.adult));
      
      // Adult stays Adult
      pet.energy.fullEnergyDays = 100;
      pet.evolve();
      expect(pet.growthStage, equals(PetGrowthStage.adult));
      
      // Not ready to evolve
      pet.growthStage = PetGrowthStage.toddler;
      pet.energy.fullEnergyDays = 0;
      pet.evolve();
      expect(pet.growthStage, equals(PetGrowthStage.toddler));
    });
    
    test('getEnergyPercentage returns correct value', () {
      pet.energy.currentEnergy = 5.0;
      pet.energy.maxEnergy = 10.0;
      expect(pet.getEnergyPercentage(), equals(0.5));
      
      pet.energy.currentEnergy = 0.0;
      expect(pet.getEnergyPercentage(), equals(0.0));
      
      pet.energy.currentEnergy = 10.0;
      expect(pet.getEnergyPercentage(), equals(1.0));
    });
    
    test('checkIn updates lastCheckInTime to current time', () {
      final before = pet.lastCheckInTime;
      pet.checkIn();
      final after = pet.lastCheckInTime;
      
      expect(after.isAfter(before), isTrue);
    });
    
    test('hasCheckedInToday correctly identifies if pet has checked in today', () {
      final now = DateTime.now();
      
      // Checked in today
      pet.lastCheckInTime = DateTime(now.year, now.month, now.day, 10, 0);
      expect(pet.hasCheckedInToday(), isTrue);
      
      // Checked in yesterday
      pet.lastCheckInTime = DateTime(now.year, now.month, now.day - 1, 10, 0);
      expect(pet.hasCheckedInToday(), isFalse);
      
      // Checked in tomorrow (edge case)
      pet.lastCheckInTime = DateTime(now.year, now.month, now.day + 1, 10, 0);
      expect(pet.hasCheckedInToday(), isFalse);
    });
  });
}