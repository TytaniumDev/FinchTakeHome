import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/repeating_task_manager.dart';
import 'package:birdo/view/screens/recurring_tasks_screen.dart';
import 'package:birdo/view/widgets/task_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../helpers/service_locator_test_helper.dart';

/// A mock RepeatingTaskManager that's pre-initialized for testing.
/// This avoids the need to set up Hive boxes for golden tests.
class MockRepeatingTaskManager extends RepeatingTaskManager {
  final List<RepeatingTask> _mockTasks;

  MockRepeatingTaskManager({List<RepeatingTask>? tasks})
      : _mockTasks = tasks ?? [];

  @override
  bool get isInitialized => true;

  @override
  List<RepeatingTask> get repeatingTasks => List.unmodifiable(_mockTasks);
}

void main() {
  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });

  Widget buildRecurringTasksScreen({
    List<RepeatingTask>? tasks,
  }) {
    final mockManager = MockRepeatingTaskManager(tasks: tasks);

    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: ChangeNotifierProvider<RepeatingTaskManager>.value(
        value: mockManager,
        child: const RecurringTasksScreen(),
      ),
    );
  }

  Widget buildTaskOptionsDialog(Task task) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  showTaskOptionsDialog(context, task);
                },
                child: const Text('Show Dialog'),
              ),
            );
          },
        ),
      ),
    );
  }

  group('Recurring Tasks Screen Golden Tests', () {
    testWidgets('recurring tasks screen - empty state', (tester) async {
      await tester.pumpWidget(buildRecurringTasksScreen());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RecurringTasksScreen),
        matchesGoldenFile('goldens/recurring_tasks_screen_empty.png'),
      );
    });
  });

  group('Task Options Dialog Golden Tests', () {
    testWidgets('task options dialog - regular task', (tester) async {
      final task = Task.create(
        title: 'Regular Task',
        energyReward: 5,
        category: TaskCategory.productivity,
      );

      await tester.pumpWidget(buildTaskOptionsDialog(task));
      await tester.pumpAndSettle();

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TaskOptionsDialog),
        matchesGoldenFile('goldens/task_options_dialog_regular.png'),
      );
    });

    testWidgets('task options dialog - recurring task', (tester) async {
      final task = Task.create(
        title: 'Recurring Task',
        energyReward: 10,
        category: TaskCategory.exercise,
        repeatingTaskId: 'template-123',
      );

      await tester.pumpWidget(buildTaskOptionsDialog(task));
      await tester.pumpAndSettle();

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TaskOptionsDialog),
        matchesGoldenFile('goldens/task_options_dialog_recurring.png'),
      );
    });
  });

  group('Recurring Task Card Golden Tests', () {
    testWidgets('recurring task card - daily task', (tester) async {
      final task = RepeatingTask.create(
        title: 'Daily Exercise',
        energyReward: 10,
        category: TaskCategory.exercise,
        repeatDayIndices: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            backgroundColor: AppTheme.colors.background,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RecurringTaskCard(task: task),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RecurringTaskCard),
        matchesGoldenFile('goldens/recurring_task_card_daily.png'),
      );
    });

    testWidgets('recurring task card - weekday task', (tester) async {
      final task = RepeatingTask.create(
        title: 'Weekday Meditation',
        energyReward: 5,
        category: TaskCategory.mindfulness,
        repeatDayIndices: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            backgroundColor: AppTheme.colors.background,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RecurringTaskCard(task: task),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RecurringTaskCard),
        matchesGoldenFile('goldens/recurring_task_card_weekday.png'),
      );
    });

    testWidgets('recurring task card - specific days', (tester) async {
      final task = RepeatingTask.create(
        title: 'MWF Workout',
        energyReward: 15,
        category: TaskCategory.exercise,
        repeatDayIndices: [
          DateTime.monday,
          DateTime.wednesday,
          DateTime.friday,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            backgroundColor: AppTheme.colors.background,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RecurringTaskCard(task: task),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RecurringTaskCard),
        matchesGoldenFile('goldens/recurring_task_card_specific_days.png'),
      );
    });
  });
}
