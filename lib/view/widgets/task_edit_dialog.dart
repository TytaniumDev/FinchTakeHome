import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows options dialog for editing or deleting a task
void showTaskOptionsDialog(BuildContext context, Task task) {
  showDialog(
    context: context,
    builder: (context) => TaskOptionsDialog(task: task),
  );
}

class TaskOptionsDialog extends StatelessWidget {
  final Task task;

  const TaskOptionsDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isRecurringTask = task.repeatingTaskId != null;

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
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                task.title,
                style: AppTheme.typography.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacing.medium),

              if (isRecurringTask) ...[
                Text(
                  'This is a recurring task',
                  style: AppTheme.typography.subtitle2.copyWith(
                    color: AppTheme.colors.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacing.large),

                ChunkyButton(
                  text: 'Edit This Instance',
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showEditTaskDialog(context, task, editAllFuture: false);
                  },
                  type: ButtonType.secondary,
                  isFullWidth: true,
                ),
                SizedBox(height: AppTheme.spacing.small),

                ChunkyButton(
                  text: 'Edit All Future',
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showEditRecurringTaskDialog(context, task);
                  },
                  type: ButtonType.secondary,
                  isFullWidth: true,
                ),
                SizedBox(height: AppTheme.spacing.small),

                ChunkyButton(
                  text: 'Delete Template',
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDeleteRecurringTaskDialog(context, task);
                  },
                  type: ButtonType.accent,
                  isFullWidth: true,
                ),
              ] else ...[
                ChunkyButton(
                  text: 'Edit Task',
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showEditTaskDialog(context, task, editAllFuture: false);
                  },
                  type: ButtonType.secondary,
                  isFullWidth: true,
                ),
                SizedBox(height: AppTheme.spacing.small),

                ChunkyButton(
                  text: 'Delete Task',
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDeleteTaskDialog(context, task);
                  },
                  type: ButtonType.accent,
                  isFullWidth: true,
                ),
              ],

              SizedBox(height: AppTheme.spacing.medium),

              ChunkyButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
                type: ButtonType.tertiary,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, {required bool editAllFuture}) {
    showDialog(
      context: context,
      builder: (context) => _EditTaskDialog(task: task),
    );
  }

  void _showEditRecurringTaskDialog(BuildContext context, Task task) {
    // For now, show a simple message
    // TODO: Implement full edit form for recurring tasks
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Recurring Task'),
        content: const Text('Editing recurring task templates is not yet implemented. This will be available in the recurring tasks management screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final taskController = Provider.of<TaskController>(context, listen: false);
              await taskController.deleteTask(task.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteRecurringTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Task'),
        content: Text('This will delete the recurring task template for "${task.title}" and stop creating new instances. Existing completed tasks will be kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final taskController = Provider.of<TaskController>(context, listen: false);
              if (task.repeatingTaskId != null) {
                await taskController.deleteRepeatingTask(task.repeatingTaskId!);
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete Template', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EditTaskDialog extends StatefulWidget {
  final Task task;

  const _EditTaskDialog({required this.task});

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late TextEditingController _titleController;
  late TaskCategory _selectedCategory;
  late int _energyReward;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedCategory = widget.task.category;
    _energyReward = widget.task.energyReward;
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
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Task',
                style: AppTheme.typography.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.primary,
                ),
                textAlign: TextAlign.center,
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
              SizedBox(height: AppTheme.spacing.large),

              Row(
                children: [
                  Expanded(
                    child: ChunkyButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      type: ButtonType.tertiary,
                      isFullWidth: true,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing.small),
                  Expanded(
                    child: ChunkyButton(
                      text: 'Save',
                      onPressed: () async {
                        final taskController = Provider.of<TaskController>(context, listen: false);
                        await taskController.updateTask(
                          widget.task.id,
                          _titleController.text.trim(),
                          _energyReward,
                          _selectedCategory,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      type: ButtonType.primary,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
