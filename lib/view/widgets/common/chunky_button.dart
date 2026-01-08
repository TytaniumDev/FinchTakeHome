import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/core/theme/button_styles.dart';
import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:flutter/material.dart';

class ChunkyButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSmall;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double shadowOffset;
  final MainAxisAlignment alignment;
  final TextStyle? textStyle;

  const ChunkyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isSmall = false,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.shadowOffset = 6.0,
    this.alignment = MainAxisAlignment.center,
    this.textStyle,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool isPressed = false;

  Color _getButtonColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return AppTheme.colors.buttonPrimary;
      case ButtonType.secondary:
        return AppTheme.colors.buttonSecondary;
      case ButtonType.tertiary:
        return Colors.transparent;

      case ButtonType.accent:
        return AppTheme.colors.accent;
    }
  }

  Color _getShadowColor() {
    final baseColor = _getButtonColor();
    if (baseColor == Colors.transparent) {
      return AppTheme.colors.buttonPrimary.withValues(alpha: 77);
    }

    return ChunkyButtonStyles.getDarkerColor(baseColor);
  }

  EdgeInsets _getButtonPadding() {
    return EdgeInsets.symmetric(
      horizontal:
          widget.isSmall ? AppTheme.spacing.large : AppTheme.spacing.xlarge,
      vertical:
          widget.isSmall ? AppTheme.spacing.medium : AppTheme.spacing.large,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: Container(
        width: widget.isFullWidth ? double.infinity : null,
        margin: EdgeInsets.only(top: widget.shadowOffset),
        child: Transform.translate(
          offset: Offset(0, isPressed ? 0 : -widget.shadowOffset),
          child: Container(
            decoration: BoxDecoration(
              color:
                  widget.type == ButtonType.tertiary
                      ? Colors.transparent
                      : _getButtonColor(),
              borderRadius: BorderRadius.circular(AppTheme.radius.large),
              border:
                  widget.type == ButtonType.tertiary
                      ? Border.all(color: AppTheme.colors.primary, width: 2.0)
                      : null,
              boxShadow: [
                if (!isPressed && !widget.isLoading)
                  BoxShadow(
                    color: _getShadowColor(),
                    offset: Offset(0, widget.shadowOffset),
                    blurRadius: 0,
                  ),
              ],
            ),
            padding: _getButtonPadding(),
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final TextStyle defaultStyle = widget.textStyle ?? AppTheme.typography.button.copyWith(
      fontSize: widget.isSmall ? 16 : 20,
      fontWeight: FontWeight.bold,
    );

    if (widget.isLoading) {
      return SizedBox(
        height: widget.isSmall ? 20 : 24,
        width: widget.isSmall ? 20 : 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.type == ButtonType.tertiary
                ? PenguinoColors.gooseBlue5
                : PenguinoColors.textWhite,
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: widget.alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: widget.isSmall ? 18 : 24),
          SizedBox(width: AppTheme.spacing.small),
          Flexible(
            child: Text(
              widget.text,
              style: defaultStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: widget.alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.text,
            style: defaultStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

enum ButtonType { primary, secondary, tertiary, accent }

class ChunkyIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final bool isLoading;
  final double shadowOffset;

  const ChunkyIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 48.0,
    this.isLoading = false,
    this.shadowOffset = 4.0,
  });

  @override
  State<ChunkyIconButton> createState() => _ChunkyIconButtonState();
}

class _ChunkyIconButtonState extends State<ChunkyIconButton> {
  bool isPressed = false;

  Color _getButtonColor() {
    return widget.color ?? AppTheme.colors.primary;
  }

  Color _getShadowColor() {
    final baseColor = _getButtonColor();

    return ChunkyButtonStyles.getDarkerColor(baseColor);
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = _getButtonColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: Container(
        width: widget.size,
        height: widget.size,
        margin: EdgeInsets.only(top: widget.shadowOffset),
        child: Transform.translate(
          offset: Offset(0, isPressed ? 0 : -widget.shadowOffset),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(AppTheme.radius.circular),
              boxShadow: [
                if (!isPressed && !widget.isLoading)
                  BoxShadow(
                    color: _getShadowColor(),
                    offset: Offset(0, widget.shadowOffset),
                    blurRadius: 0,
                  ),
              ],
            ),
            child: Center(
              child:
                  widget.isLoading
                      ? SizedBox(
                        height: widget.size * 0.5,
                        width: widget.size * 0.5,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            PenguinoColors.textWhite,
                          ),
                        ),
                      )
                      : Icon(
                        widget.icon,
                        size: widget.size * 0.5,
                        color: PenguinoColors.textWhite,
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
