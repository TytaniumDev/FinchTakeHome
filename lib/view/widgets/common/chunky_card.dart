import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:flutter/material.dart';

class ChunkyCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double elevation;
  final double shadowOffset;
  final bool isInteractive;

  const ChunkyCard({
    super.key,
    required this.child,
    this.color,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.elevation = 4.0,
    this.shadowOffset = 4.0,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.colors.surface;

    return AnimatedContainer(
      duration: AppTheme.animationDuration.medium,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor:
              isInteractive
                  ? AppTheme.colors.primary.withValues(alpha: 26)
                  : Colors.transparent,
          highlightColor:
              isInteractive
                  ? AppTheme.colors.primary.withValues(alpha: 13)
                  : Colors.transparent,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class ChunkyHeaderCard extends StatelessWidget {
  final Widget header;
  final Widget content;
  final Color? headerColor;
  final Color? contentColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final double elevation;
  final double shadowOffset;

  const ChunkyHeaderCard({
    super.key,
    required this.header,
    required this.content,
    this.headerColor,
    this.contentColor,
    this.borderRadius = 16.0,
    this.onTap,
    this.elevation = 4.0,
    this.shadowOffset = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final headerBgColor = headerColor ?? AppTheme.colors.primary;
    final contentBgColor = contentColor ?? AppTheme.colors.surface;

    return AnimatedContainer(
      duration: AppTheme.animationDuration.medium,
      decoration: BoxDecoration(
        color: contentBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor:
              onTap != null
                  ? AppTheme.colors.primary.withValues(alpha: 26)
                  : Colors.transparent,
          highlightColor:
              onTap != null
                  ? AppTheme.colors.primary.withValues(alpha: 13)
                  : Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
                child: Container(
                  color: headerBgColor,
                  padding: EdgeInsets.all(AppTheme.spacing.medium),
                  child: header,
                ),
              ),

              Padding(
                padding: EdgeInsets.all(AppTheme.spacing.medium),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChunkyTaskCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final Color? categoryColor;
  final Widget? completeButton;

  const ChunkyTaskCard({
    super.key,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.onTap,
    this.onComplete,
    this.categoryColor,
    this.completeButton,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isCompleted
            ? AppTheme.colors.surface.withValues(alpha: 153)
            : AppTheme.colors.surface;

    final textColor =
        isCompleted
            ? AppTheme.colors.onSurface.withValues(alpha: 128)
            : AppTheme.colors.onSurface;

    final indicatorColor = categoryColor ?? PenguinoColors.gooseBlue5;

    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: ChunkyCard(
        color: cardColor,
        onTap: onTap,
        isInteractive: onTap != null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: description != null ? 80 : 40,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: AppTheme.spacing.medium),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTheme.typography.subtitle1.copyWith(
                      color: textColor,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (completeButton != null) ...[
              SizedBox(width: AppTheme.spacing.medium),
              completeButton!,
            ],
          ],
        ),
      ),
    );
  }
}
