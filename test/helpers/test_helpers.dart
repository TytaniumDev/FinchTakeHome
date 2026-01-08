import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/pet_energy.dart';
import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:hive_ce/hive.dart';
import 'package:mockito/mockito.dart';

import 'service_locator_test_helper.dart';

// Mock Hive Boxes
class MockBox<T> extends Mock implements Box<T> {}

// Mock Services
class MockDateTimeService extends Mock implements DateTimeService {
  DateTime? _currentDate;

  @override
  DateTime getCurrentDate() {
    // Return current time for tests that check if a timestamp is updated
    return _currentDate ?? DateTime.now();
  }

  void setCurrentDate(DateTime date) {
    _currentDate = date;
  }

  @override
  String generateDayId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  bool isToday(DateTime date) {
    return isSameDay(date, getCurrentDate());
  }

  @override
  bool isYesterday(DateTime date) {
    final yesterday = getCurrentDate().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}

// Factory methods for creating test models
class TestFactory {
  // Create a test pet
  static Pet createTestPet({
    String? id,
    String name = 'Test Pet',
    PetGrowthStage growthStage = PetGrowthStage.egg,
    Gender gender = Gender.male,
    DateTime? birthDate,
    DateTime? lastCheckInTime,
    PetEnergy? energy,
  }) {
    return Pet(
      id: id ?? 'test-pet-id',
      name: name,
      birthDate: birthDate ?? DateTime(2023, 1, 1),
      lastCheckInTime: lastCheckInTime ?? DateTime(2023, 1, 1),
      energy: energy ?? createTestPetEnergy(),
      growthStage: growthStage,
      gender: gender,
    );
  }

  // Create a test pet using the factory method
  static Pet createTestPetWithFactory({
    String name = 'Test Pet',
    Gender gender = Gender.male,
  }) {
    return Pet.create(
      name: name,
      gender: gender,
      dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
    );
  }

  // Create a test task
  static Task createTestTask({
    String? id,
    String title = 'Test Task',
    int energyReward = 5,
    bool isCompleted = false,
    DateTime? completedAt,
    TaskCategory category = TaskCategory.productivity,
    DateTime? createdDate,
  }) {
    return Task(
      id: id ?? 'test-task-id',
      title: title,
      energyReward: energyReward,
      isCompleted: isCompleted,
      completedAt: completedAt,
      category: category,
      createdDate: createdDate ?? DateTime(2023, 1, 1),
    );
  }

  // Create a test day
  static Day createTestDay({
    String? id,
    DateTime? date,
    bool checkedIn = false,
    int energy = 0,
    List<String>? completedTaskIds,
    List<Task>? dailyTasks,
    int rainbowStonesEarned = 0,
  }) {
    return Day(
      id: id ?? '2023-01-01',
      date: date ?? DateTime(2023, 1, 1),
      checkedIn: checkedIn,
      energy: energy,
      completedTaskIds: completedTaskIds,
      dailyTasks: dailyTasks,
      rainbowStonesEarned: rainbowStonesEarned,
    );
  }

  // Create test rainbow stones
  static RainbowStones createTestRainbowStones({
    int currentAmount = 0,
    int totalEarned = 0,
    DateTime? lastUpdated,
  }) {
    return RainbowStones(
      currentAmount: currentAmount,
      totalEarned: totalEarned,
      lastUpdated: lastUpdated ?? DateTime(2023, 1, 1),
      dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
    );
  }

  // Create a test pet energy
  static PetEnergy createTestPetEnergy({
    double maxEnergy = 15.0,
    double currentEnergy = 0.0,
    DateTime? lastUpdatedTime,
    double totalEnergyEarned = 0.0,
    int fullEnergyDays = 0,
  }) {
    return PetEnergy(
      maxEnergy: maxEnergy,
      currentEnergy: currentEnergy,
      lastUpdatedTime: lastUpdatedTime ?? DateTime(2023, 1, 1),
      totalEnergyEarned: totalEnergyEarned,
      fullEnergyDays: fullEnergyDays,
      dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
    );
  }
}
