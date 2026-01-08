import 'package:birdo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum FeedbackType { success, error, info, warning }

class BirdoToast extends StatelessWidget {
  final String message;
  final FeedbackType type;
  final VoidCallback? onDismiss;
  final Duration duration;

  const BirdoToast({
    super.key,
    required this.message,
    this.type = FeedbackType.info,
    this.onDismiss,
    this.duration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing.large,
          vertical: AppTheme.spacing.medium,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 204),
          borderRadius: BorderRadius.circular(AppTheme.radius.large),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius.large),
          child: Dismissible(
            key: Key('toast_${DateTime.now().millisecondsSinceEpoch}'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) {
              if (onDismiss != null) {
                onDismiss!();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing.medium),
              child: Row(
                children: [
                  _buildIcon(),
                  SizedBox(width: AppTheme.spacing.medium),
                  Expanded(
                    child: Text(
                      message,
                      style: AppTheme.typography.body2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing.small),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    switch (type) {
      case FeedbackType.success:
        iconData = Icons.check_circle;
        break;
      case FeedbackType.error:
        iconData = Icons.error;
        break;
      case FeedbackType.warning:
        iconData = Icons.warning;
        break;
      case FeedbackType.info:
        iconData = Icons.info;
        break;
    }

    return Icon(iconData, color: Colors.white, size: 24);
  }
}

class BirdoToastManager {
  static OverlayEntry? _currentToast;
  static bool _isVisible = false;

  static void show(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismissed,
  }) {
    if (_isVisible) {
      _currentToast?.remove();
      _currentToast = null;
      _isVisible = false;
    }

    _currentToast = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            left: 0,
            right: 0,
            child: BirdoToast(
              message: message,
              type: type,
              duration: duration,
              onDismiss: () {
                _dismissToast();
                if (onDismissed != null) {
                  onDismissed();
                }
              },
            ),
          ),
    );

    Overlay.of(context).insert(_currentToast!);
    _isVisible = true;

    Future.delayed(duration, () {
      _dismissToast();
      if (onDismissed != null) {
        onDismissed();
      }
    });
  }

  static void _dismissToast() {
    if (_isVisible && _currentToast != null) {
      _currentToast?.remove();
      _currentToast = null;
      _isVisible = false;
    }
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismissed,
  }) {
    show(
      context,
      message: message,
      type: FeedbackType.success,
      duration: duration,
      onDismissed: onDismissed,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismissed,
  }) {
    show(
      context,
      message: message,
      type: FeedbackType.error,
      duration: duration,
      onDismissed: onDismissed,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismissed,
  }) {
    show(
      context,
      message: message,
      type: FeedbackType.info,
      duration: duration,
      onDismissed: onDismissed,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismissed,
  }) {
    show(
      context,
      message: message,
      type: FeedbackType.warning,
      duration: duration,
      onDismissed: onDismissed,
    );
  }
}
