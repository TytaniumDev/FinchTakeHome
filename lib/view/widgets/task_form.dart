import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/constants/rewards.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
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
               Builder(
                 builder: (context) {
                   final inheritedStyle = DefaultTextStyle.of(context);
                   return RichText(
                     text: TextSpan(
                       text: '+$repeatedTaskCompletionReward ',
                       style: AppTheme.typography.subtitle2.copyWith(
                         fontFamily: inheritedStyle.style.fontFamily,
                       ),
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
                         TextSpan(
                           text: ' bonus for doing repeated tasks!',
                           style: TextStyle(
                             fontFamily: inheritedStyle.style.fontFamily,
                           ),
                         ),
                       ],
                     ),
                   );
                 },
               ),
               SizedBox(height: AppTheme.spacing.small),
               CustomRepeatSelector(
                 value: state.value ?? RepeatOption.none,
                 onChanged: (value) {
                   onChanged(value);
                   state.didChange(value);
                 },
               ),
             ],
           );
         },
       );
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

/// Custom repeat selector widget that displays horizontal tabs
/// with a smooth sliding animation matching the design in the reference image
class CustomRepeatSelector extends StatefulWidget {
  final RepeatOption value;
  final Function(RepeatOption) onChanged;

  const CustomRepeatSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CustomRepeatSelector> createState() => _CustomRepeatSelectorState();
}

class _CustomRepeatSelectorState extends State<CustomRepeatSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _thumbPositionAnimation;
  int _targetIndex = 0;
  int _currentIndex = 0;
  bool _isDragging = false;
  double? _dragStartX;
  double? _dragStartLeft;
  double _currentThumbLeft = 0.0;

  int _getIndexForOption(RepeatOption option) {
    switch (option) {
      case RepeatOption.none:
        return 0;
      case RepeatOption.daily:
        return 1;
      case RepeatOption.weekly:
        return 2;
    }
  }

  RepeatOption _getOptionForIndex(int index) {
    switch (index) {
      case 0:
        return RepeatOption.none;
      case 1:
        return RepeatOption.daily;
      case 2:
        return RepeatOption.weekly;
      default:
        return RepeatOption.none;
    }
  }

  @override
  void initState() {
    super.initState();
    _targetIndex = _getIndexForOption(widget.value);
    _currentIndex = _targetIndex;
    _animationController = AnimationController(
      duration: AppTheme.animationDuration.medium,
      vsync: this,
    );
    _thumbPositionAnimation =
        Tween<double>(
          begin: _targetIndex.toDouble(),
          end: _targetIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.value =
        1.0; // Set to end value so it shows at target position
  }

  @override
  void didUpdateWidget(CustomRepeatSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isDragging) {
      _targetIndex = _getIndexForOption(widget.value);
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    _currentIndex = _targetIndex;
    _thumbPositionAnimation =
        Tween<double>(
          begin: _currentIndex.toDouble(),
          end: _targetIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _getTabIndexFromPosition(double x, double totalWidth) {
    final tabWidth = (totalWidth - (2 * AppTheme.spacing.small)) / 3;
    if (x < tabWidth + AppTheme.spacing.small / 2) {
      return 0;
    } else if (x < tabWidth * 2 + AppTheme.spacing.small * 1.5) {
      return 1;
    } else {
      return 2;
    }
  }

  void _handleDragStart(DragStartDetails details, double totalWidth) {
    _animationController.stop();
    setState(() {
      _isDragging = true;
      _dragStartX = details.localPosition.dx;
      final tabWidth = (totalWidth - (2 * AppTheme.spacing.small)) / 3;
      _dragStartLeft = _currentIndex * (tabWidth + AppTheme.spacing.small);
      _currentThumbLeft = _dragStartLeft!;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double totalWidth) {
    if (_dragStartX == null || _dragStartLeft == null) return;

    final tabWidth = (totalWidth - (2 * AppTheme.spacing.small)) / 3;
    final deltaX = details.localPosition.dx - _dragStartX!;
    final newLeft = (_dragStartLeft! + deltaX).clamp(
      0.0,
      totalWidth - tabWidth - AppTheme.spacing.small * 2,
    );

    final thumbCenter = newLeft + tabWidth / 2;
    final newIndex = _getTabIndexFromPosition(thumbCenter, totalWidth);

    setState(() {
      _currentThumbLeft = newLeft;
      _currentIndex = newIndex;
    });
  }

  void _handleDragEnd(DragEndDetails details, double totalWidth) {
    if (_isDragging) {
      setState(() {
        _isDragging = false;
        _targetIndex = _currentIndex;
        _dragStartX = null;
        _dragStartLeft = null;
      });
      widget.onChanged(_getOptionForIndex(_targetIndex));
      _updateAnimation();
    }
  }

  void _handleTap(int index) {
    if (!_isDragging) {
      setState(() {
        _targetIndex = index;
      });
      widget.onChanged(_getOptionForIndex(index));
      _updateAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final tabWidth = (totalWidth - (2 * AppTheme.spacing.small)) / 3;

        // Calculate thumb position
        double thumbLeft;
        if (_isDragging) {
          // During drag, use the current drag position
          thumbLeft = _currentThumbLeft;
        } else {
          // During animation, interpolate between current and target
          final animatedIndex = _thumbPositionAnimation.value;
          thumbLeft = animatedIndex * (tabWidth + AppTheme.spacing.small);
        }

        // Calculate overlap percentage for each tab
        final thumbRight = thumbLeft + tabWidth;
        final tabPositions = <double>[];
        for (int i = 0; i < 3; i++) {
          final tabLeft = i * (tabWidth + AppTheme.spacing.small);
          tabPositions.add(tabLeft);
        }

        double calculateOverlap(int tabIndex) {
          final tabLeft = tabPositions[tabIndex];
          final tabRight = tabLeft + tabWidth;
          final overlapLeft = thumbLeft.clamp(tabLeft, tabRight);
          final overlapRight = thumbRight.clamp(tabLeft, tabRight);
          final overlap = (overlapRight - overlapLeft).clamp(0.0, tabWidth);
          return overlap / tabWidth;
        }

        final overlap0 = calculateOverlap(0);
        final overlap1 = calculateOverlap(1);
        final overlap2 = calculateOverlap(2);

        return GestureDetector(
          onHorizontalDragStart: (details) =>
              _handleDragStart(details, totalWidth),
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details, totalWidth),
          onHorizontalDragEnd: (details) => _handleDragEnd(details, totalWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius.medium),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.colors.buttonPrimary,
                border: Border.all(
                  color: AppTheme.colors.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sliding indicator
                  AnimatedPositioned(
                    duration: _isDragging
                        ? Duration.zero
                        : AppTheme.animationDuration.medium,
                    curve: Curves.easeInOut,
                    left: thumbLeft,
                    width: tabWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radius.medium,
                        ),
                      ),
                    ),
                  ),
                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: _RepeatTab(
                          label: 'None',
                          selectionProgress: overlap0,
                          onTap: () => _handleTap(0),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing.small),
                      Expanded(
                        child: _RepeatTab(
                          label: 'Daily',
                          selectionProgress: overlap1,
                          onTap: () => _handleTap(1),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing.small),
                      Expanded(
                        child: _RepeatTab(
                          label: 'Weekly',
                          selectionProgress: overlap2,
                          onTap: () => _handleTap(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RepeatTab extends StatelessWidget {
  final String label;
  final double selectionProgress; // 0.0 to 1.0
  final VoidCallback onTap;

  const _RepeatTab({
    required this.label,
    required this.selectionProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Interpolate color based on selection progress
    final unselectedColor = AppTheme.colors.onSurface.withValues(alpha: 0.6);
    final selectedColor = AppTheme.colors.onPrimary;
    final textColor = Color.lerp(
      unselectedColor,
      selectedColor,
      selectionProgress,
    )!;

    // Interpolate font weight
    final fontWeight = FontWeight.lerp(
      FontWeight.w400,
      FontWeight.w500,
      selectionProgress,
    )!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing.medium,
          vertical: AppTheme.spacing.small,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radius.medium),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.typography.subtitle1.copyWith(
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
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
          constraints: BoxConstraints(minHeight: 40),
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
