import 'package:birdo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A button widget that represents a task completion action.
///
/// This widget displays a button that can be tapped to mark a task as complete.
/// It has two visual states: incomplete (a checkmark button) and complete (a green check circle).
class GoalCompleteButton extends StatefulWidget {
  /// Callback function that is called when the button is tapped.
  final VoidCallback onTap;
  
  /// Whether the task is already completed.
  final bool isCompleted;

  /// Creates a GoalCompleteButton widget.
  const GoalCompleteButton({
    super.key,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  State<GoalCompleteButton> createState() => _GoalCompleteButtonState();
}

class _GoalCompleteButtonState extends State<GoalCompleteButton> {
  /// Whether the button is currently being pressed.
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 44.0;
    const double shadowOffset = 4.0;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Center(
        child:
            widget.isCompleted
                ? _buildCompletedIcon()
                : GestureDetector(
                  onTapDown: (_) => setState(() => isPressed = true),
                  onTapUp: (_) {
                    setState(() => isPressed = false);
                    widget.onTap();
                  },
                  onTapCancel: () => setState(() => isPressed = false),
                  child: Container(
                    margin: const EdgeInsets.only(top: shadowOffset),
                    child: Transform.translate(
                      offset: Offset(0, isPressed ? 0 : -shadowOffset),
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          color: AppTheme.colors.buttonPrimary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            if (!isPressed)
                              BoxShadow(
                                color: Colors.grey[400]!,
                                offset: const Offset(0, shadowOffset),
                              ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  /// Builds the completed state icon.
  Widget _buildCompletedIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Icon(Icons.check_circle, size: 32, color: Colors.green),
    );
  }
}
