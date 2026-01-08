import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskList extends StatelessWidget {
  final VoidCallback? onTaskTap;

  const TaskList({super.key, this.onTaskTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskManager>(
      builder: (context, taskManager, child) {
        // Get the task controller
        final taskController = Provider.of<TaskController>(context, listen: false);
        
        // Check if tasks are initialized
        if (!taskManager.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Get the tasks
        final tasks = taskManager.tasks;
        
        // Build the task list
        List<Widget> children = [];
        
        if (tasks.isEmpty) {
          children.add(
            Center(
              child: Text(
                taskManager.isTimeTravel 
                    ? 'No tasks for this day' 
                    : 'No tasks yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600]
                ),
              ),
            ),
          );
        } else {
          for (var task in tasks) {
            children.add(
              TaskCard(
                task: task,
                onTap: onTaskTap,
                onCheckboxChanged: (isCompleted) {
                  if (isCompleted == true) {
                    taskController.completeTask(task.id);
                  } else {
                    taskController.resetTask(task.id);
                  }
                },
              ),
            );
          }
        }
        
        return children.isEmpty
            ? const SizedBox.shrink()
            : ListView(children: children);
      },
    );
  }
}
