import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:flutter/material.dart';

class ChunkyLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;
  final bool isOverlay;

  const ChunkyLoadingIndicator({
    super.key,
    this.size = 48.0,
    this.color,
    this.message,
    this.isOverlay = false,
  });

  @override
  State<ChunkyLoadingIndicator> createState() => _ChunkyLoadingIndicatorState();
}

class _ChunkyLoadingIndicatorState extends State<ChunkyLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _bounceAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? PenguinoColors.gooseBlue5;

    Widget indicator = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: widget.size * 0.6,
                          height: widget.size * 0.6,
                          decoration: BoxDecoration(
                            color: PenguinoColors.textWhite,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radius.small,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (widget.message != null) ...[
              SizedBox(height: AppTheme.spacing.medium),
              Text(
                widget.message!,
                style: AppTheme.typography.subtitle2.copyWith(
                  color: AppTheme.colors.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );

    if (widget.isOverlay) {
      return Container(
        color: PenguinoColors.black9.withValues(alpha: 77),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacing.large),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius.large),
            ),
            child: indicator,
          ),
        ),
      );
    }

    return indicator;
  }
}

class ChunkyProgressBar extends StatefulWidget {
  final double value;

  final double height;
  final Color? backgroundColor;
  final Color? fillColor;
  final String? label;
  final bool showPercentage;

  const ChunkyProgressBar({
    super.key,
    required this.value,
    this.height = 24.0,
    this.backgroundColor,
    this.fillColor,
    this.label,
    this.showPercentage = false,
  });

  @override
  State<ChunkyProgressBar> createState() => _ChunkyProgressBarState();
}

class _ChunkyProgressBarState extends State<ChunkyProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationDuration.medium,
    );
    _fillAnimation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ChunkyProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.backgroundColor ?? PenguinoColors.bgGrayLight;
    final fillColor = widget.fillColor ?? PenguinoColors.gooseBlue5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label!, style: AppTheme.typography.subtitle2),
              if (widget.showPercentage)
                Text(
                  '${(widget.value * 100).toInt()}%',
                  style: AppTheme.typography.subtitle2.copyWith(
                    color: fillColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppTheme.spacing.small),
        ],

        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radius.medium),
          ),
          child: AnimatedBuilder(
            animation: _fillAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: _fillAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radius.medium,
                        ),
                      ),
                    ),
                  ),

                  if (widget.label == null && widget.showPercentage)
                    Center(
                      child: Text(
                        '${(widget.value * 100).toInt()}%',
                        style: AppTheme.typography.button.copyWith(
                          color: PenguinoColors.textWhite,
                          fontSize: widget.height * 0.5,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
