import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/repeating_task_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/common/task_list.dart';
import 'package:birdo/view/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/service_locator_test_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  late MockTaskManager mockTaskManager;
  late MockDayManager mockDayManager;
  late MockTaskController mockTaskController;

  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });

  setUp(() {
    mockTaskManager = MockTaskManager();
    mockDayManager = MockDayManager();
    mockTaskController = MockTaskController();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<TaskManager>.value(value: mockTaskManager),
            ChangeNotifierProvider<DayManager>.value(value: mockDayManager),
            Provider<TaskController>.value(value: mockTaskController),
          ],
          child: const TaskList(),
        ),
      ),
    );
  }

  group('TaskList widget tests', () {
    testWidgets('displays tasks when initialized', (tester) async {
      final testTask = TestFactory.createTestTask(
        id: 'task-1',
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      mockTaskManager.setTasks([testTask]);
      mockTaskManager.setInitialized(true);
      mockTaskManager.setTasksCompleted([]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('task appears at full scale and opacity when uncompleted',
        (tester) async {
      final testTask = TestFactory.createTestTask(
        id: 'task-1',
        title: 'Uncompleted Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      mockTaskManager.setTasks([testTask]);
      mockTaskManager.setInitialized(true);
      mockTaskManager.setTasksCompleted([]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the AnimatedTaskCard
      final animatedTaskCard = tester.widget<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );

      // Verify the task is not marked as completed
      expect(animatedTaskCard.isCompleted, isFalse);

      // Find the Transform and Opacity widgets in the AnimatedTaskCard
      final transformFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsWidgets);

      final opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsWidgets);

      // Get the Opacity widget and check its value
      final opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0));
    });

    testWidgets('task appears shrunken and transparent when completed',
        (tester) async {
      final testTask = TestFactory.createTestTask(
        id: 'task-1',
        title: 'Completed Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      mockTaskManager.setTasks([testTask]);
      mockTaskManager.setInitialized(true);
      mockTaskManager.setTasksCompleted(['task-1']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the AnimatedTaskCard
      final animatedTaskCard = tester.widget<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );

      // Verify the task is marked as completed
      expect(animatedTaskCard.isCompleted, isTrue);

      // Find the Opacity widget in the AnimatedTaskCard
      final opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );

      // Get the Opacity widget and check its value (should be 0.6 for completed)
      final opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(0.6));
    });

    testWidgets(
        'uncompleting a task restores UI to uncompleted state (full scale and opacity)',
        (tester) async {
      final testTask = TestFactory.createTestTask(
        id: 'task-1',
        title: 'Task to Uncomplete',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      mockTaskManager.setTasks([testTask]);
      mockTaskManager.setInitialized(true);
      // Start with the task completed
      mockTaskManager.setTasksCompleted(['task-1']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify initial state is completed (shrunken and transparent)
      var opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      var opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(0.6),
          reason: 'Task should start as completed with 0.6 opacity');

      // Find the check_circle icon (completed state button) and tap it to uncomplete
      final checkCircleFinder = find.byIcon(Icons.check_circle);
      expect(checkCircleFinder, findsOneWidget,
          reason: 'Should find the check_circle icon for completed task');

      await tester.tap(checkCircleFinder);
      await tester.pump();

      // Simulate the DayManager updating completedTaskIds (removing the task)
      mockTaskManager.setTasksCompleted([]);

      // Rebuild the widget to reflect the state change
      await tester.pumpWidget(buildTestWidget());

      // Allow animations to complete
      await tester.pumpAndSettle();

      // Verify the task is now showing as uncompleted
      final animatedTaskCard = tester.widget<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );
      expect(animatedTaskCard.isCompleted, isFalse,
          reason: 'Task should now be marked as uncompleted');

      // Verify the opacity is restored to 1.0 (full opacity)
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason:
              'Uncompleted task should have full opacity (1.0), but got ${opacityWidget.opacity}');
    });

    testWidgets(
        'completing then uncompleting a task restores original visual state',
        (tester) async {
      final testTask = TestFactory.createTestTask(
        id: 'task-1',
        title: 'Toggle Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      mockTaskManager.setTasks([testTask]);
      mockTaskManager.setInitialized(true);
      mockTaskManager.setTasksCompleted([]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify initial uncompleted state
      var opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      var opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason: 'Task should start uncompleted with full opacity');

      // Find and tap the check button to complete the task
      final checkButtonFinder = find.byIcon(Icons.check);
      expect(checkButtonFinder, findsOneWidget);
      await tester.tap(checkButtonFinder);
      await tester.pump();

      // Simulate completion
      mockTaskManager.setTasksCompleted(['task-1']);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify completed state
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(0.6),
          reason: 'Completed task should have 0.6 opacity');

      // Find and tap the check_circle icon to uncomplete
      final checkCircleFinder = find.byIcon(Icons.check_circle);
      expect(checkCircleFinder, findsOneWidget);
      await tester.tap(checkCircleFinder);
      await tester.pump();

      // Simulate uncompletion
      mockTaskManager.setTasksCompleted([]);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify restored uncompleted state
      opacityFinder = find.descendant(
        of: find.byType(AnimatedTaskCard),
        matching: find.byType(Opacity),
      );
      opacityWidget = tester.widget<Opacity>(opacityFinder.first);
      expect(opacityWidget.opacity, equals(1.0),
          reason:
              'Uncompleted task should be restored to full opacity (1.0), but got ${opacityWidget.opacity}');

      // Also verify the AnimatedTaskCard's isCompleted property
      final animatedTaskCard = tester.widget<AnimatedTaskCard>(
        find.byType(AnimatedTaskCard),
      );
      expect(animatedTaskCard.isCompleted, isFalse,
          reason:
              'AnimatedTaskCard.isCompleted should be false after uncompleting');
    });

    testWidgets('uncomplete callback is called when tapping check_circle icon',
        (tester) async {
      final testTask = TestFactory.createTestTask(
        id: 'task-1',
        title: 'Callback Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      mockTaskManager.setTasks([testTask]);
      mockTaskManager.setInitialized(true);
      mockTaskManager.setTasksCompleted(['task-1']);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the check_circle icon
      final checkCircleFinder = find.byIcon(Icons.check_circle);
      await tester.tap(checkCircleFinder);
      await tester.pump();

      // Verify the controller's uncompleteTask was called
      expect(mockTaskController.uncompleteTaskCalled, isTrue);
      expect(mockTaskController.lastUncompletedTaskId, equals('task-1'));
    });

    testWidgets('complete callback is called when tapping check icon',
        (tester) async {
      final testTask = TestFactory.createTestTask(
        id: 'task-1',
        title: 'Complete Callback Test Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      mockTaskManager.setTasks([testTask]);
      mockTaskManager.setInitialized(true);
      mockTaskManager.setTasksCompleted([]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the check icon
      final checkFinder = find.byIcon(Icons.check);
      await tester.tap(checkFinder);
      await tester.pump();

      // Verify the controller's completeTask was called
      expect(mockTaskController.completeTaskCalled, isTrue);
      expect(mockTaskController.lastCompletedTaskId, equals('task-1'));
    });

    testWidgets('shows loading indicator when not initialized', (tester) async {
      mockTaskManager.setInitialized(false);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when no tasks', (tester) async {
      mockTaskManager.setTasks([]);
      mockTaskManager.setInitialized(true);
      mockTaskManager.setTasksCompleted([]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No tasks yet'), findsOneWidget);
    });
  });
}

/// Mock TaskManager for testing
class MockTaskManager extends ChangeNotifier implements TaskManager {
  List<Task> _tasks = [];
  bool _isInitialized = false;
  final DateTime _currentDay = DateTime.now();
  final bool _isTimeTravel = false;

  void setTasks(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners();
  }

  void setInitialized(bool initialized) {
    _isInitialized = initialized;
    notifyListeners();
  }

  /// Sets the completion state of a task by ID
  void setTaskCompleted(String taskId, bool completed) {
    final task = _tasks.firstWhere((t) => t.id == taskId, orElse: () => throw StateError('Task not found'));
    if (completed) {
      task.complete();
    } else {
      task.reset();
    }
    notifyListeners();
  }

  /// Sets completion state for multiple tasks
  void setTasksCompleted(List<String> completedTaskIds) {
    for (var task in _tasks) {
      if (completedTaskIds.contains(task.id)) {
        task.complete();
      } else {
        task.reset();
      }
    }
    notifyListeners();
  }

  @override
  List<Task> get completedTasks => List<Task>.from(_tasks.where((t) => t.isCompleted));

  @override
  int get completedTaskCount => _tasks.where((t) => t.isCompleted).length;

  @override
  bool isTaskCompleted(String taskId) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      return task.isCompleted;
    } catch (e) {
      return false;
    }
  }

  @override
  List<Task> get tasks => _tasks;

  @override
  bool get isInitialized => _isInitialized;

  @override
  DateTime get currentDay => _currentDay;

  @override
  bool get isTimeTravel => _isTimeTravel;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  @override
  Future<void> onInitialize() async {}

  @override
  Future<void> loadTasks() async {}

  @override
  Future<void> loadTasksForDay(DateTime date) async {}

  @override
  Future<void> completeTask(String taskId, {DateTime? date}) async {}

  @override
  Future<void> resetTask(String taskId, {DateTime? date}) async {}

  @override
  Future<void> createTask(String title, int energyReward, TaskCategory category,
      {DateTime? date}) async {}

  @override
  Future<void> updateTask(
      String taskId, String title, int energyReward, TaskCategory category,
      {DateTime? date}) async {}

  @override
  Future<Task?> getTask(String taskId) async {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteTask(String taskId, {DateTime? date}) async {}

  @override
  void notifyStateChanged() {
    notifyListeners();
  }
}

/// Mock DayManager for testing
class MockDayManager extends ChangeNotifier implements DayManager {
  @override
  bool get isInitialized => true;

  @override
  Day? get currentDay => null;

  @override
  List<Day> get historicalDays => [];

  @override
  bool get hasCheckedInToday => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> onInitialize() async {}

  @override
  Future<void> loadCurrentDay() async {}

  @override
  Future<void> loadHistoricalDays({int limit = 7}) async {}

  @override
  Future<void> checkIn() async {}

  @override
  Future<void> addRainbowStones(int amount) async {}

  @override
  Future<Day?> getDayRecord(DateTime date) async => null;

  @override
  Future<void> updateDayRecord(Day day) async {}

  @override
  Future<void> addTaskToDay(String taskId) async {}

  @override
  Future<void> completeTask(String taskId, {int? energyReward}) async {}

  @override
  Future<void> uncompleteTask(String taskId, {int? energyReward}) async {}

  @override
  int getTotalEnergy() => 0;

  @override
  int getRainbowStonesEarned() => 0;

  @override
  void notifyStateChanged() {
    notifyListeners();
  }
}

/// Mock PetManager for testing
class MockPetManager extends ChangeNotifier implements PetManager {
  @override
  bool get isInitialized => true;

  @override
  Pet? get currentPet => null;

  @override
  double get energyPercentage => 0.0;

  @override
  int get currentEnergy => 0;

  @override
  int get maxEnergy => 15;

  @override
  bool get isEnergyFull => false;

  @override
  PetGrowthStage? get growthStage => null;

  @override
  bool get isReadyToEvolve => false;

  @override
  int get requiredFullEnergyDaysForEvolution => 0;

  @override
  int get fullEnergyDays => 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> onInitialize() async {}

  @override
  Future<void> loadCurrentPet() async {}

  @override
  Future<void> createPet({required String name, required Gender gender}) async {}

  @override
  Future<void> updatePet({String? name, Gender? gender}) async {}

  @override
  Future<void> evolvePet() async {}

  @override
  Future<void> addEnergy(double amount) async {}

  @override
  Future<void> removeEnergy(double amount) async {}

  @override
  bool hasCheckedInToday() => false;

  @override
  Future<void> checkIn() async {}

  @override
  Future<void> checkDayTransition() async {}

  @override
  void notifyStateChanged() {
    notifyListeners();
  }
}

/// Mock RainbowStonesManager for testing
class MockRainbowStonesManager extends ChangeNotifier
    implements RainbowStonesManager {
  @override
  bool get isInitialized => true;

  @override
  RainbowStones? get rainbowStones => null;

  @override
  int get currentBalance => 0;

  @override
  int get totalEarned => 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> onInitialize() async {}

  @override
  Future<void> loadRainbowStones() async {}

  @override
  Future<void> addStones(int amount) async {}

  @override
  Future<void> removeStones(int amount) async {}

  @override
  Future<bool> spendStones(int amount) async => true;

  @override
  bool hasEnoughStones(int amount) => true;

  @override
  Future<void> awardDailyStones(int amount) async {}

  @override
  Future<void> awardTaskCompletionStones(int amount) async {}

  @override
  Future<void> removeTaskCompletionStones(int amount) async {}

  @override
  Future<void> awardPetEvolutionStones(int amount) async {}

  @override
  void notifyStateChanged() {
    notifyListeners();
  }
}

/// Mock RepeatingTaskManager for testing
class MockRepeatingTaskManager extends ChangeNotifier
    implements RepeatingTaskManager {
  @override
  List<RepeatingTask> get repeatingTasks => [];

  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> loadRepeatingTasks() async {}

  @override
  Future<RepeatingTask?> getRepeatingTask(String id) async => null;

  @override
  Future<void> createRepeatingTask({
    required String title,
    required int energyReward,
    required TaskCategory category,
    required List<int> repeatDayIndices,
  }) async {}

  @override
  Future<void> deleteRepeatingTask(String id) async {}

  @override
  Future<void> updateRepeatingTask(RepeatingTask task) async {}

  @override
  Future<void> deactivateRepeatingTask(String id) async {}

  @override
  Future<void> activateRepeatingTask(String id) async {}
}

/// Mock TaskController for testing
class MockTaskController implements TaskController {
  bool completeTaskCalled = false;
  bool uncompleteTaskCalled = false;
  String? lastCompletedTaskId;
  String? lastUncompletedTaskId;

  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> onInitialize() async {}

  @override
  Future<void> loadTasks() async {}

  @override
  Future<void> loadTasksForDay(DateTime date) async {}

  @override
  Future<void> completeTask(String taskId, {DateTime? date}) async {
    completeTaskCalled = true;
    lastCompletedTaskId = taskId;
  }

  @override
  Future<void> uncompleteTask(String taskId, {DateTime? date}) async {
    uncompleteTaskCalled = true;
    lastUncompletedTaskId = taskId;
  }

  @override
  Future<void> resetTask(String taskId, {DateTime? date}) async {}

  @override
  Future<void> createTask(String title, int energyReward, TaskCategory category,
      {DateTime? date}) async {}

  @override
  Future<void> createRepeatingTask(String title, int energyReward,
      TaskCategory category, List<int> repeatDayIndices) async {}

  @override
  Future<void> updateTask(
      String taskId, String title, int energyReward, TaskCategory category,
      {DateTime? date}) async {}

  @override
  Future<void> updateRepeatingTask(String repeatingTaskId, String title,
      int energyReward, TaskCategory category, List<int> repeatDayIndices) async {}

  @override
  Future<void> deleteTask(String taskId, {DateTime? date}) async {}

  @override
  Future<void> deleteRepeatingTask(String repeatingTaskId) async {}

  @override
  void log(String message) {}

  @override
  void dispose() {}
}
