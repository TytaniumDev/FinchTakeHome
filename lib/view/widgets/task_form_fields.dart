import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:flutter/material.dart';

/// Reusable task title text field with validation
class TaskTitleField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TaskTitleField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Task Title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius.medium),
        ),
        filled: true,
        fillColor: AppTheme.colors.surface,
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a task title';
            }
            return null;
          },
    );
  }
}

/// Reusable category dropdown field
class TaskCategoryField extends StatelessWidget {
  final TaskCategory initialValue;
  final void Function(TaskCategory?) onChanged;

  const TaskCategoryField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TaskCategory>(
      initialValue: initialValue,
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
          child: Text(TaskCategoryHelper.getName(category)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

/// Helper class for task category operations
class TaskCategoryHelper {
  /// Get display name for a task category
  static String getName(TaskCategory category) {
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
}

/// A custom form field for selecting repeat days of the week.
class DayRepeatFormField extends FormField<List<int>> {
  static const weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  DayRepeatFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    super.enabled,
    super.validator,
    required Function(List<int>) onChanged,
  }) : super(
          builder: (FormFieldState<List<int>> state) {
            return InputDecorator(
              decoration: InputDecoration(
                errorText: state.errorText,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              child: CustomDaySelector(
                selectedDayIndices: state.value ?? [],
                weekdayLabels: weekdayLabels,
                onChanged: (selectedDayIndices) {
                  onChanged(selectedDayIndices);
                  state.didChange(selectedDayIndices);
                },
              ),
            );
          },
        );
}

/// Custom day selector widget that displays rounded rectangular buttons
/// matching the design in the reference image
class CustomDaySelector extends StatelessWidget {
  final List<int> selectedDayIndices;
  final List<String> weekdayLabels;
  final Function(List<int>) onChanged;

  const CustomDaySelector({
    super.key,
    required this.selectedDayIndices,
    required this.weekdayLabels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate button width (accounting for spacing between buttons)
        final totalSpacing =
            AppTheme.spacing.small * (DateTime.daysPerWeek - 1);
        final buttonWidth =
            (constraints.maxWidth - totalSpacing) / DateTime.daysPerWeek;
        final availableTextWidth =
            buttonWidth -
            (AppTheme.spacing.small * 2); // Subtract horizontal padding

        // Find the longest label to determine minimum font size
        final longestLabel = weekdayLabels.reduce(
          (a, b) => a.length > b.length ? a : b,
        );

        // Calculate font size that fits the longest label
        final baseFontSize = AppTheme.typography.subtitle2.fontSize ?? 14.0;
        final textPainter = TextPainter(
          text: TextSpan(
            text: longestLabel,
            style: AppTheme.typography.subtitle2,
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Scale down if needed, but use the same scale for all buttons
        double fontSize = baseFontSize;
        if (textPainter.width > availableTextWidth) {
          fontSize = baseFontSize * (availableTextWidth / textPainter.width);
        }

        return Row(
          children: [
            for (int index = 0; index < DateTime.daysPerWeek; index++) ...[
              Expanded(
                child: _buildDayButton(
                  index: index,
                  dayIndex: index + 1,
                  isSelected: selectedDayIndices.contains(index + 1),
                  fontSize: fontSize,
                  onTap: () {
                    final newSelection = List<int>.from(selectedDayIndices);
                    if (selectedDayIndices.contains(index + 1)) {
                      newSelection.remove(index + 1);
                    } else {
                      newSelection.add(index + 1);
                    }
                    onChanged(newSelection);
                  },
                ),
              ),
              if (index < DateTime.daysPerWeek - 1)
                SizedBox(width: AppTheme.spacing.small),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDayButton({
    required int index,
    required int dayIndex,
    required bool isSelected,
    required double fontSize,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: AppTheme.animationDuration.fast,
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(minHeight: 40),
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing.small,
            vertical: AppTheme.spacing.small,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.colors.primary
                : AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius.medium),
            border: Border.all(
              color: isSelected
                  ? AppTheme.colors.primary
                  : AppTheme.colors.outline.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Builder(
            builder: (context) {
              final inheritedStyle = DefaultTextStyle.of(context);
              return Center(
                child: AnimatedDefaultTextStyle(
                  duration: AppTheme.animationDuration.fast,
                  curve: Curves.easeInOut,
                  style: AppTheme.typography.subtitle2.copyWith(
                    fontSize: fontSize,
                    color: isSelected
                        ? AppTheme.colors.onPrimary
                        : AppTheme.colors.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    fontFamily: inheritedStyle.style.fontFamily,
                  ),
                  child: Text(
                    weekdayLabels[index],
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
