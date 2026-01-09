import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
import 'package:birdo/view/widgets/goal_complete_button.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckboxChanged;
  final bool isCompleted;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onCheckboxChanged,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color categoryColor = _getCategoryColor(task.category);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing.medium,
        vertical: AppTheme.spacing.small,
      ),
      child: ChunkyTaskCard(
        title: task.title,
        isCompleted: isCompleted,
        onTap: onTap,
        onComplete: onCheckboxChanged != null
            ? () => onCheckboxChanged!(!isCompleted)
            : null,
        categoryColor: categoryColor,
        completeButton: onCheckboxChanged != null
            ? GoalCompleteButton(
                isCompleted: isCompleted,
                onTap: () => onCheckboxChanged!(!isCompleted),
              )
            : null,
      ),
    );
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
}

class AnimatedTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckboxChanged;
  final bool isCompleted;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onCheckboxChanged,
    required this.isCompleted,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationDuration.medium,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isCompleted) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isCompleted != widget.isCompleted) {
      if (widget.isCompleted) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color categoryColor = _getCategoryColor(widget.task.category);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing.medium,
                vertical: AppTheme.spacing.small,
              ),
              child: ChunkyTaskCard(
                title: widget.task.title,
                isCompleted: widget.isCompleted,
                onTap: widget.onTap,
                onComplete: widget.onCheckboxChanged != null
                    ? () => widget.onCheckboxChanged!(!widget.isCompleted)
                    : null,
                categoryColor: categoryColor,
                completeButton: widget.onCheckboxChanged != null
                    ? GoalCompleteButton(
                        isCompleted: widget.isCompleted,
                        onTap: () =>
                            widget.onCheckboxChanged!(!widget.isCompleted),
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
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
}
