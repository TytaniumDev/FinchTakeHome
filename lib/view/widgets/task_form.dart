import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/constants/rewards.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

      // Use the task controller to create the task
      taskController.createTask(
        title,
        5, // Default energy reward
        _selectedCategory,
        date: targetDate,
        repeatDayIndices: switch (_selectedRepeatOption) {
          RepeatOption.none => null,
          RepeatOption.daily => [
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
            DateTime.saturday,
            DateTime.sunday,
          ],
          RepeatOption.weekly => _selectedRepeatDayIndices,
        },
      );

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

            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                ),
                filled: true,
                fillColor: AppTheme.colors.surface,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            SizedBox(height: AppTheme.spacing.medium),

            DropdownButtonFormField<TaskCategory>(
              initialValue: _selectedCategory,
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

enum RepeatOption { none, daily, weekly }

class RepeatSelectionFormField extends FormField<RepeatOption> {
  RepeatSelectionFormField({
    super.key,
    RepeatOption super.initialValue = RepeatOption.none,
    super.onSaved,
    required Function(RepeatOption) onChanged,
  }) : super(
         builder: (FormFieldState<RepeatOption> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
               Text(
                 'Repeat',
                 style: AppTheme.typography.subtitle1,
                 textAlign: TextAlign.left,
               ),
               RichText(
                 text: TextSpan(
                   text: '+$repeatedTaskCompletionReward ',
                   style: AppTheme.typography.subtitle2,
                   children: [
                     WidgetSpan(
                       child: SvgPicture.asset(
                         'lib/assets/icons/rainbow-stones.svg',
                         height: 16,
                         width: 16,
                         placeholderBuilder: (BuildContext context) => Icon(
                           Icons.stars,
                           size: 16,
                           color: Colors.purple.shade700,
                         ),
                       ),
                     ),
                     TextSpan(text: ' bonus for doing repeated tasks!'),
                   ],
                 ),
               ),
               SizedBox(height: AppTheme.spacing.small),
               CupertinoSlidingSegmentedControl(
                 onValueChanged: (RepeatOption? value) {
                   if (value != null) {
                     onChanged(value);
                     state.didChange(value);
                   }
                 },
                 groupValue: state.value,
                 isMomentary: false,
                 thumbColor: AppTheme.colors.primary,

                 children: const <RepeatOption, Widget>{
                   RepeatOption.none: Padding(
                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     child: Text('None'),
                   ),
                   RepeatOption.daily: Padding(
                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     child: Text('Daily'),
                   ),
                   RepeatOption.weekly: Padding(
                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     child: Text('Weekly'),
                   ),
                 },
               ),
             ],
           );
         },
       );
}

/// A custom form field for selecting repeat days of the week.
///
/// This one is a bit complicated, because it's using a ToggleButtons widget
/// which requires a list of booleans to indicate which days are selected.
///
/// There's a bit of logic to convert between the list of selected day indices
/// and the list of booleans used by the ToggleButtons.
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
           // Convert from a list of selected day indices to a list of booleans.
           final List<bool> selectedDays = List.generate(
             DateTime.daysPerWeek,
             (index) => state.value?.contains(index + 1) ?? false,
           );

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
             child: Center(
               child: ToggleButtons(
                 isSelected: selectedDays,
                 constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                 onPressed: (int index) {
                   // Toggle the day being selected.
                   selectedDays[index] = !selectedDays[index];
                   final selectedDayIndices = <int>[];

                   // Convert back to a list of selected day indices with the now
                   // correctly updated selectedDays list.
                   for (int i = 0; i < selectedDays.length; i++) {
                     if (selectedDays[i]) {
                       selectedDayIndices.add(i + 1);
                     }
                   }

                   onChanged(selectedDayIndices);
                   state.didChange(selectedDayIndices);
                 },
                 fillColor: AppTheme.colors.primary,
                 selectedColor: AppTheme.colors.onSurface,
                 renderBorder: true,
                 borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                 children: List.generate(
                   DateTime.daysPerWeek,
                   (index) => WeekdayButton(
                     label: weekdayLabels[index],
                     selected: selectedDays[index],
                   ),
                 ),
               ),
             ),
           );
         },
       );
}

class WeekdayButton extends StatelessWidget {
  final String label;
  final bool selected;

  const WeekdayButton({super.key, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(fontSize: 13));
  }
}
