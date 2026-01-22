import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/repeating_task_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/task_form.dart';
import 'package:birdo/view/widgets/task_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../helpers/service_locator_test_helper.dart';

void main() {
  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });

  Widget buildTestApp({
    required Widget child,
    TaskManager? taskManager,
    TaskController? taskController,
  }) {
    final mockTaskManager = taskManager ??
        TaskManager(
          dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
        );
    final mockDayManager = DayManager(
      dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
    );
    final mockPetManager = PetManager(
      dateTimeService: ServiceLocatorTestHelper.mockDateTimeService,
    );
    final mockRainbowStonesManager = RainbowStonesManager();
    final mockRepeatingTaskManager = RepeatingTaskManager();
    final mockTaskController = taskController ??
        TaskController(
          taskManager: mockTaskManager,
          dayManager: mockDayManager,
          petManager: mockPetManager,
          rainbowStonesManager: mockRainbowStonesManager,
          repeatingTaskManager: mockRepeatingTaskManager,
        );

    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<TaskManager>.value(value: mockTaskManager),
            ChangeNotifierProvider<DayManager>.value(value: mockDayManager),
            ChangeNotifierProvider<PetManager>.value(value: mockPetManager),
            ChangeNotifierProvider<RainbowStonesManager>.value(
              value: mockRainbowStonesManager,
            ),
            ChangeNotifierProvider<RepeatingTaskManager>.value(
              value: mockRepeatingTaskManager,
            ),
            Provider<TaskController>.value(value: mockTaskController),
          ],
          child: child,
        ),
      ),
    );
  }

  group('TaskForm Dialog Tests', () {
    testWidgets('displays title field with validation', (tester) async {
      await tester.pumpWidget(buildTestApp(child: const TaskForm()));
      await tester.pumpAndSettle();

      // Find the title field
      final titleField = find.byType(TextFormField).first;
      expect(titleField, findsOneWidget);

      // Try to submit empty form
      final createButton = find.text('Create Task');
      expect(createButton, findsOneWidget);
      await tester.tap(createButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a task title'), findsOneWidget);
    });

    testWidgets('displays all category options', (tester) async {
      await tester.pumpWidget(buildTestApp(child: const TaskForm()));
      await tester.pumpAndSettle();

      // Find and tap category dropdown
      final categoryDropdown =
          find.byType(DropdownButtonFormField<TaskCategory>);
      expect(categoryDropdown, findsOneWidget);

      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();

      // Verify all categories are present
      expect(find.text('Productivity'), findsNWidgets(2)); // One in dropdown, one in expanded menu
      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Self Care'), findsOneWidget);
      expect(find.text('Mindfulness'), findsOneWidget);
    });

    testWidgets('shows day selector when Weekly is selected', (tester) async {
      await tester.pumpWidget(buildTestApp(child: const TaskForm()));
      await tester.pumpAndSettle();

      // Initially day selector should not be visible (opacity 0)
      final monFinder = find.text('Mon');
      expect(monFinder, findsNothing); // Not visible initially

      // Select Weekly repeat option
      final weeklyFinder = find.text('Weekly');
      expect(weeklyFinder, findsOneWidget);
      await tester.tap(weeklyFinder);
      await tester.pumpAndSettle();

      // Day selector should now be visible
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
    });

    testWidgets('validates day selection for weekly repeat', (tester) async {
      await tester.pumpWidget(buildTestApp(child: const TaskForm()));
      await tester.pumpAndSettle();

      // Fill in title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'Test Task');
      await tester.pump();

      // Select Weekly repeat option
      final weeklyFinder = find.text('Weekly');
      await tester.tap(weeklyFinder);
      await tester.pumpAndSettle();

      // Try to submit without selecting any days
      final createButton = find.text('Create Task');
      await tester.tap(createButton);
      await tester.pump();

      // Should show validation error for days
      expect(find.text('Please select at least one day'), findsOneWidget);
    });
  });

  group('Edit Task Dialog Tests', () {
    testWidgets('shows task options dialog with correct buttons', (tester) async {
      // Create a test task
      final testTask = Task.create(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.exercise,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: TaskOptionsDialog(task: testTask),
        ),
      );

      await tester.pumpAndSettle();

      // The dialog should show the task title
      expect(find.text('Test Task'), findsOneWidget);

      // The dialog should show action buttons
      expect(find.text('Edit Task'), findsOneWidget);
      expect(find.text('Delete Task'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('can tap Edit Task button', (tester) async {
      final testTask = Task.create(
        title: 'Test Task',
        energyReward: 5,
        category: TaskCategory.exercise,
      );

      await tester.pumpWidget(
        buildTestApp(
          child: TaskOptionsDialog(task: testTask),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the Edit Task button
      final editButton = find.text('Edit Task');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // After tapping edit, the edit dialog should appear
      // We can verify this by checking for the presence of form fields
      // Note: The exact assertions depend on the _EditTaskDialog implementation
    });
  });
}
