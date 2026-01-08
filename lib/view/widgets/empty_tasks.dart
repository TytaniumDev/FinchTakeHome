import 'package:flutter/material.dart';

/// A widget that displays a message when there are no tasks.
///
/// This widget is used in the TaskListScreen when there are no tasks to display.
/// It provides visual feedback to the user and suggests adding a new task.
class EmptyTasks extends StatelessWidget {
  /// Creates an EmptyTasks widget.
  const EmptyTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new task using the + button',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
