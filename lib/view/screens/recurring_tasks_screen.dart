import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/repeating_task.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/repeating_task_manager.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
import 'package:birdo/view/widgets/task_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecurringTasksScreen extends StatelessWidget {
  const RecurringTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Tasks'),
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: AppTheme.colors.onPrimary,
      ),
      body: Consumer<RepeatingTaskManager>(
        builder: (context, manager, child) {
          if (!manager.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = manager.repeatingTasks;

          if (tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing.large),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 64,
                      color: AppTheme.colors.onSurface.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: AppTheme.spacing.medium),
                    Text(
                      'No Recurring Tasks',
                      style: AppTheme.typography.h5.copyWith(
                        color: AppTheme.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing.small),
                    Text(
                      'Create recurring tasks from the task form to see them here.',
                      textAlign: TextAlign.center,
                      style: AppTheme.typography.body2.copyWith(
                        color: AppTheme.colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppTheme.spacing.medium),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacing.medium),
                child: RecurringTaskCard(task: task),
              );
            },
          );
        },
      ),
    );
  }
}

class RecurringTaskCard extends StatelessWidget {
  final RepeatingTask task;

  const RecurringTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(task.category);
    final daysText = _formatDays(task.repeatDayIndices);

    return Opacity(
      opacity: task.isActive ? 1.0 : 0.5,
      child: ChunkyCard(
        color: AppTheme.colors.surface,
        borderRadius: AppTheme.radius.large,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 60,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: AppTheme.spacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: AppTheme.typography.subtitle1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.colors.onSurface,
                              ),
                            ),
                          ),
                          if (!task.isActive) ...[
                            SizedBox(width: AppTheme.spacing.small),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing.small,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.colors.onSurface.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppTheme.radius.small),
                              ),
                              child: Text(
                                'Inactive',
                                style: AppTheme.typography.caption.copyWith(
                                  color: AppTheme.colors.onSurface.withValues(alpha: 0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing.small),
                      Row(
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 16,
                            color: AppTheme.colors.onSurface.withValues(alpha: 0.6),
                          ),
                          SizedBox(width: AppTheme.spacing.small),
                          Expanded(
                            child: Text(
                              daysText,
                              style: AppTheme.typography.caption.copyWith(
                                color: AppTheme.colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing.small),
                      Text(
                        '${task.energyReward} energy • ${_getCategoryName(task.category)}',
                        style: AppTheme.typography.caption.copyWith(
                          color: AppTheme.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showTaskOptions(context, task);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, RepeatingTask task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radius.large),
            topRight: Radius.circular(AppTheme.radius.large),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing.medium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  task.title,
                  style: AppTheme.typography.h6.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacing.large),
                ChunkyButton(
                  text: 'Edit',
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditDialog(context, task);
                  },
                  type: ButtonType.secondary,
                  isFullWidth: true,
                ),
                SizedBox(height: AppTheme.spacing.small),
                ChunkyButton(
                  text: task.isActive ? 'Deactivate' : 'Activate',
                  onPressed: () async {
                    final manager = Provider.of<RepeatingTaskManager>(
                      context,
                      listen: false,
                    );
                    if (task.isActive) {
                      await manager.deactivateRepeatingTask(task.id);
                    } else {
                      await manager.activateRepeatingTask(task.id);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  type: ButtonType.secondary,
                  isFullWidth: true,
                ),
                SizedBox(height: AppTheme.spacing.small),
                ChunkyButton(
                  text: 'Delete',
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteDialog(context, task);
                  },
                  type: ButtonType.accent,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, RepeatingTask task) {
    showDialog(
      context: context,
      builder: (context) => _EditRecurringTaskDialog(task: task),
    );
  }

  void _showDeleteDialog(BuildContext context, RepeatingTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Task'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This will stop creating new instances of this task.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final manager = Provider.of<RepeatingTaskManager>(
                context,
                listen: false,
              );
              await manager.deleteRepeatingTask(task.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDays(List<int> dayIndices) {
    if (dayIndices.length == 7) {
      return 'Every day';
    }

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedIndices = List<int>.from(dayIndices)..sort();
    final days = sortedIndices.map((i) => dayNames[i - 1]).toList();

    return days.join(', ');
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.selfCare:
        return Colors.green;
      case TaskCategory.productivity:
        return Colors.blue;
      case TaskCategory.exercise:
        return Colors.red;
      case TaskCategory.mindfulness:
        return Colors.purple;
    }
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

class _EditRecurringTaskDialog extends StatefulWidget {
  final RepeatingTask task;

  const _EditRecurringTaskDialog({required this.task});

  @override
  State<_EditRecurringTaskDialog> createState() => _EditRecurringTaskDialogState();
}

class _EditRecurringTaskDialogState extends State<_EditRecurringTaskDialog> {
  late TextEditingController _titleController;
  late TaskCategory _selectedCategory;
  late int _energyReward;
  late List<int> _selectedDays;
  late RepeatOption _selectedRepeatOption;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedCategory = widget.task.category;
    _energyReward = widget.task.energyReward;
    _selectedDays = List<int>.from(widget.task.repeatDayIndices);

    // Determine initial repeat option based on selected days
    if (_selectedDays.length == 7) {
      _selectedRepeatOption = RepeatOption.daily;
    } else {
      _selectedRepeatOption = RepeatOption.weekly;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing.large,
        vertical: AppTheme.spacing.xlarge,
      ),
      child: ChunkyCard(
        color: AppTheme.colors.surface,
        borderRadius: AppTheme.radius.large,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing.medium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Recurring Task',
                  style: AppTheme.typography.h5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colors.primary,
                  ),
                  textAlign: TextAlign.center,
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
                  showLabel: false,
                  showNoneOption: false,
                  onChanged: (value) {
                    setState(() {
                      _selectedRepeatOption = value;
                      // Auto-select all days for daily option
                      if (value == RepeatOption.daily) {
                        _selectedDays = [
                          DateTime.monday,
                          DateTime.tuesday,
                          DateTime.wednesday,
                          DateTime.thursday,
                          DateTime.friday,
                          DateTime.saturday,
                          DateTime.sunday,
                        ];
                      }
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
                  offset: _selectedRepeatOption == RepeatOption.weekly
                      ? Offset(0, 0)
                      : Offset(0, -0.2),
                  child: IgnorePointer(
                    ignoring: _selectedRepeatOption != RepeatOption.weekly,
                    child: AnimatedOpacity(
                      opacity: _selectedRepeatOption == RepeatOption.weekly ? 1.0 : 0.0,
                      curve: Curves.easeInOut,
                      duration: AppTheme.animationDuration.medium,
                      child: DayRepeatFormField(
                        initialValue: _selectedDays,
                        enabled: _selectedRepeatOption == RepeatOption.weekly,
                        validator: (value) {
                          if (_selectedRepeatOption == RepeatOption.weekly) {
                            if (value == null || value.isEmpty) {
                              return 'Please select at least one day';
                            }
                          }
                          return null;
                        },
                        onChanged: (days) {
                          setState(() {
                            _selectedDays = days;
                          });
                        },
                        onSaved: (days) {
                          setState(() {
                            _selectedDays = days ?? [];
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacing.large),
                ChunkyButton(
                  text: 'Save',
                  onPressed: () async {
                    if (_titleController.text.trim().isEmpty) {
                      return;
                    }
                    if (_selectedDays.isEmpty) {
                      return;
                    }

                    final manager = Provider.of<RepeatingTaskManager>(
                      context,
                      listen: false,
                    );

                    widget.task.title = _titleController.text.trim();
                    widget.task.category = _selectedCategory;
                    widget.task.energyReward = _energyReward;
                    widget.task.repeatDayIndices = _selectedDays;

                    await manager.updateRepeatingTask(widget.task);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  type: ButtonType.primary,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
