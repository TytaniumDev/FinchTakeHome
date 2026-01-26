import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
import 'package:birdo/view/widgets/task_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskFormDialog extends StatelessWidget {
  const TaskFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<TaskManager>(
              builder: (context, taskManager, child) {
                String dateText = 'Today';

                final now = DateTime.now();
                final currentDay = taskManager.currentDay;
                if (currentDay.year != now.year ||
                    currentDay.month != now.month ||
                    currentDay.day != now.day) {
                  dateText =
                      '${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}';
                }

                return Text(
                  'Add Task for $dateText',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TaskForm(
              onTaskAdded: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TaskForm extends StatefulWidget {
  final VoidCallback? onTaskAdded;

  const TaskForm({super.key, this.onTaskAdded});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  TaskCategory _selectedCategory = TaskCategory.productivity;
  RepeatOption _selectedRepeatOption = RepeatOption.none;
  final List<int> _selectedRepeatDayIndices = [];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final taskController = Provider.of<TaskController>(
        context,
        listen: false,
      );
      final taskManager = Provider.of<TaskManager>(context, listen: false);

      // Get the current date from the task manager
      // This seems weird? I feel like we shouldn't need a controller and \
      // manager at the same time, and this lookup should come from somewhere else?
      final targetDate = taskManager.currentDay;

      // Route to the correct controller method based on repeat option
      switch (_selectedRepeatOption) {
        case RepeatOption.none:
          // One-time task
          taskController.createTask(
            title,
            5, // Default energy reward
            _selectedCategory,
            date: targetDate,
          );
          break;

        case RepeatOption.daily:
          // Recurring task with all days
          taskController.createRepeatingTask(
            title,
            5, // Default energy reward
            _selectedCategory,
            [
              DateTime.monday,
              DateTime.tuesday,
              DateTime.wednesday,
              DateTime.thursday,
              DateTime.friday,
              DateTime.saturday,
              DateTime.sunday,
            ],
          );
          break;

        case RepeatOption.weekly:
          // Recurring task with selected days
          taskController.createRepeatingTask(
            title,
            5, // Default energy reward
            _selectedCategory,
            _selectedRepeatDayIndices,
          );
          break;
      }

      _titleController.clear();

      if (widget.onTaskAdded != null) {
        widget.onTaskAdded!();
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final daySelectionVisible = _selectedRepeatOption == RepeatOption.weekly;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.spacing.medium),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<TaskManager>(
              builder: (context, taskManager, child) {
                String dateText = 'Today';

                final now = DateTime.now();
                final currentDay = taskManager.currentDay;
                if (currentDay.year != now.year ||
                    currentDay.month != now.month ||
                    currentDay.day != now.day) {
                  dateText =
                      '${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}';
                }

                return Text(
                  'Add Task for $dateText',
                  style: AppTheme.typography.h5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colors.primary,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
            SizedBox(height: AppTheme.spacing.large),

            TaskTitleField(
              controller: _titleController,
            ),
            SizedBox(height: AppTheme.spacing.medium),

            TaskCategoryField(
              initialValue: _selectedCategory,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            SizedBox(height: AppTheme.spacing.medium),

            RepeatSelectionFormField(
              initialValue: _selectedRepeatOption,
              onChanged: (value) {
                setState(() {
                  _selectedRepeatOption = value;
                });
              },
              onSaved: (value) {
                if (value != null) {
                  _selectedRepeatOption = value;
                }
              },
            ),
            SizedBox(height: AppTheme.spacing.small),

            AnimatedSlide(
              duration: AppTheme.animationDuration.medium,
              curve: Curves.easeInOut,
              offset: daySelectionVisible
                  ? Offset(0, 0)
                  : Offset(0, -0.2), // Slide up when not weekly
              child: IgnorePointer(
                // Ignore taps when we the day selector is invisible
                ignoring: !daySelectionVisible,
                child: AnimatedOpacity(
                  opacity: daySelectionVisible ? 1.0 : 0.0,
                  curve: Curves.easeInOut,
                  duration: AppTheme.animationDuration.medium,
                  child: DayRepeatFormField(
                    enabled: daySelectionVisible,
                    initialValue: _selectedRepeatDayIndices,
                    validator: (List<int>? value) {
                      if (daySelectionVisible) {
                        if (value == null || value.isEmpty) {
                          return 'Please select at least one day';
                        }
                      }
                      return null;
                    },
                    onChanged: (selectedDayIndices) {
                      _selectedRepeatDayIndices.clear();
                      _selectedRepeatDayIndices.addAll(selectedDayIndices);
                    },
                    onSaved: (selectedDayIndices) {
                      _selectedRepeatDayIndices.clear();
                      _selectedRepeatDayIndices.addAll(
                        selectedDayIndices ?? [],
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacing.large),

            ChunkyButton(
              text: 'Create Task',
              onPressed: _saveTask,
              type: ButtonType.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

}

void showTaskFormDialog(BuildContext context, {VoidCallback? onTaskAdded}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,

      insetPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing.large,
        vertical: AppTheme.spacing.xlarge,
      ),
      child: ChunkyCard(
        color: AppTheme.colors.surface,
        borderRadius: AppTheme.radius.large,

        child: TaskForm(onTaskAdded: onTaskAdded),
      ),
    ),
  );
}

