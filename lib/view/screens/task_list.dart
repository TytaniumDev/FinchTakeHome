import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/common/task_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    // Ensure the task manager is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskManager = Provider.of<TaskManager>(context, listen: false);
      if (!taskManager.isInitialized) {
        taskManager.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const TaskList();
  }
}
