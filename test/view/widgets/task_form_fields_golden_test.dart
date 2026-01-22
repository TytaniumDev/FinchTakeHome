import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/view/widgets/task_form.dart';
import 'package:birdo/view/widgets/task_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task Form Field Golden Tests', () {
    testWidgets('TaskTitleField - empty state', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 100,
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.surface,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TextFormField),
        matchesGoldenFile('goldens/task_title_field_empty.png'),
      );
    });

    testWidgets('TaskTitleField - filled state', (tester) async {
      final controller = TextEditingController(text: 'My Task');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 100,
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.surface,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TextFormField),
        matchesGoldenFile('goldens/task_title_field_filled.png'),
      );
    });

    testWidgets('TaskTitleField - error state', (tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 120,
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                      ),
                      filled: true,
                      fillColor: AppTheme.colors.surface,
                      errorText: 'Please enter a task title',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TextFormField),
        matchesGoldenFile('goldens/task_title_field_error.png'),
      );
    });

    testWidgets('TaskCategoryField - default state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 100,
                child: DropdownButtonFormField<TaskCategory>(
                  value: TaskCategory.productivity,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                    ),
                    filled: true,
                    fillColor: AppTheme.colors.surface,
                  ),
                  items: TaskCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryName(category)),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DropdownButtonFormField<TaskCategory>),
        matchesGoldenFile('goldens/task_category_field_default.png'),
      );
    });

    testWidgets('DaySelector - no days selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: CustomDaySelector(
                  selectedDayIndices: const [],
                  weekdayLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CustomDaySelector),
        matchesGoldenFile('goldens/day_selector_empty.png'),
      );
    });

    testWidgets('DaySelector - some days selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: CustomDaySelector(
                  selectedDayIndices: const [1, 3, 5], // Mon, Wed, Fri
                  weekdayLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CustomDaySelector),
        matchesGoldenFile('goldens/day_selector_partial.png'),
      );
    });

    testWidgets('DaySelector - all days selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: CustomDaySelector(
                  selectedDayIndices: const [1, 2, 3, 4, 5, 6, 7],
                  weekdayLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CustomDaySelector),
        matchesGoldenFile('goldens/day_selector_all.png'),
      );
    });

    testWidgets('RepeatSelector - none selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: CustomRepeatSelector(
                  value: RepeatOption.none,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CustomRepeatSelector),
        matchesGoldenFile('goldens/repeat_selector_none.png'),
      );
    });

    testWidgets('RepeatSelector - daily selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: CustomRepeatSelector(
                  value: RepeatOption.daily,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CustomRepeatSelector),
        matchesGoldenFile('goldens/repeat_selector_daily.png'),
      );
    });

    testWidgets('RepeatSelector - weekly selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 60,
                child: CustomRepeatSelector(
                  value: RepeatOption.weekly,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CustomRepeatSelector),
        matchesGoldenFile('goldens/repeat_selector_weekly.png'),
      );
    });
  });
}

String _getCategoryName(TaskCategory category) {
  switch (category) {
    case TaskCategory.selfCare:
      return 'Self Care';
    case TaskCategory.productivity:
      return 'Productivity';
    case TaskCategory.exercise:
      return 'Exercise';
    case TaskCategory.mindfulness:
      return 'Mindfulness';
  }
}
