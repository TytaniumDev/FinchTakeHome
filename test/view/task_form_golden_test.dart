import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/task_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../helpers/service_locator_test_helper.dart';

void main() {
  setUpAll(() async {
    await ServiceLocatorTestHelper.initialize();
  });

  Widget buildTestWidget({
    TaskManager? taskManager,
    TaskController? taskController,
  }) {
    // Create managers with mock DateTimeService for visual testing
    // No need to initialize them - we just need them to exist for the widget
    final mockTaskManager =
        taskManager ??
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
    final mockTaskController =
        taskController ??
        TaskController(
          taskManager: mockTaskManager,
          dayManager: mockDayManager,
          petManager: mockPetManager,
          rainbowStonesManager: mockRainbowStonesManager,
        );

    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Use available width from constraints (from viewport size)
            // If no constraint, default to 400 for other tests
            final width = constraints.maxWidth != double.infinity
                ? constraints.maxWidth
                : 400.0;
            return Center(
              child: SizedBox(
                width: width,
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider<TaskManager>.value(
                      value: mockTaskManager,
                    ),
                    Provider<TaskController>.value(value: mockTaskController),
                  ],
                  child: const TaskForm(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  group('TaskForm Golden Tests', () {
    testWidgets('task form with day selector - all days selected', (
      tester,
    ) async {
      // Build the widget tree - no initialization needed for visual test
      await tester.pumpWidget(buildTestWidget());

      await tester.pumpAndSettle();

      // Select weekly repeat option to show day selector
      final weeklyFinder = find.text('Weekly');
      if (weeklyFinder.evaluate().isNotEmpty) {
        await tester.tap(weeklyFinder);
        await tester.pumpAndSettle();
      }

      // Select all days
      for (final dayLabel in [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ]) {
        final dayFinder = find.text(dayLabel);
        if (dayFinder.evaluate().isNotEmpty) {
          await tester.tap(dayFinder);
          await tester.pumpAndSettle();
        }
      }

      // Wait for any animations to complete
      await tester.pump(const Duration(seconds: 1));

      // Compare with golden file
      await expectLater(
        find.byType(TaskForm),
        matchesGoldenFile('task_form_all_days_selected.png'),
      );
    });

    testWidgets('task form with day selector - no days selected', (
      tester,
    ) async {
      // Build the widget tree - no initialization needed for visual test
      await tester.pumpWidget(buildTestWidget());

      await tester.pumpAndSettle();

      // Select weekly repeat option to show day selector
      final weeklyFinder = find.text('Weekly');
      if (weeklyFinder.evaluate().isNotEmpty) {
        await tester.tap(weeklyFinder);
        await tester.pumpAndSettle();
      }

      // Wait for any animations to complete
      await tester.pump(const Duration(seconds: 1));

      // Compare with golden file
      await expectLater(
        find.byType(TaskForm),
        matchesGoldenFile('task_form_no_days_selected.png'),
      );
    });

    testWidgets('task form with day selector - some days selected', (
      tester,
    ) async {
      // Build the widget tree - no initialization needed for visual test
      await tester.pumpWidget(buildTestWidget());

      await tester.pumpAndSettle();

      // Select weekly repeat option and some days
      final weeklyFinder = find.text('Weekly');
      if (weeklyFinder.evaluate().isNotEmpty) {
        await tester.tap(weeklyFinder);
        await tester.pumpAndSettle();
      }

      // Tap some day buttons (e.g., Mon, Wed, Fri)
      final monFinder = find.text('Mon');
      final wedFinder = find.text('Wed');
      final friFinder = find.text('Fri');

      if (monFinder.evaluate().isNotEmpty) {
        await tester.tap(monFinder);
        await tester.pumpAndSettle();
      }
      if (wedFinder.evaluate().isNotEmpty) {
        await tester.tap(wedFinder);
        await tester.pumpAndSettle();
      }
      if (friFinder.evaluate().isNotEmpty) {
        await tester.tap(friFinder);
        await tester.pumpAndSettle();
      }

      // Wait for any animations to complete
      await tester.pump(const Duration(seconds: 1));

      // Compare with golden file
      await expectLater(
        find.byType(TaskForm),
        matchesGoldenFile('task_form_some_days_selected.png'),
      );
    });

    testWidgets(
      'task form with day selector - iPhone 13 width all days selected',
      (tester) async {
        // iPhone 13 screen width is 390 logical pixels (portrait)
        // Dialog padding is AppTheme.spacing.large (24.0) on each side
        // Content width = 390 - (24 * 2) = 342
        // Set the viewport size at the tester level to the content width
        const contentWidth = 342.0;
        const contentHeight = 844.0;
        await tester.binding.setSurfaceSize(
          const Size(contentWidth, contentHeight),
        );
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // Build the widget tree - it will use the viewport size from MediaQuery
        await tester.pumpWidget(buildTestWidget());

        await tester.pumpAndSettle();

        // Select weekly repeat option to show day selector
        final weeklyFinder = find.text('Weekly');
        if (weeklyFinder.evaluate().isNotEmpty) {
          await tester.tap(weeklyFinder);
          await tester.pumpAndSettle();
        }

        // Select all days
        for (final dayLabel in [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ]) {
          final dayFinder = find.text(dayLabel);
          if (dayFinder.evaluate().isNotEmpty) {
            await tester.tap(dayFinder);
            await tester.pumpAndSettle();
          }
        }

        // Wait for any animations to complete
        await tester.pump(const Duration(seconds: 1));

        // Compare with golden file
        await expectLater(
          find.byType(TaskForm),
          matchesGoldenFile('task_form_iphone13_all_days_selected.png'),
        );
      },
    );
  });
}
