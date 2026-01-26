import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
import 'package:birdo/view/widgets/task_form_fields.dart';
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
              SizedBox(height: AppTheme.spacing.large),

              ChunkyButton(
                text: 'Save',
                onPressed: () async {
                  final taskController = Provider.of<TaskController>(
                    context,
                    listen: false,
                  );
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
            ],
          ),
        ),
      ),
    );
  }

}
