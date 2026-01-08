import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:flutter/material.dart';

class ChunkyInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;

  const ChunkyInputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.contentPadding,
  });

  @override
  State<ChunkyInputField> createState() => _ChunkyInputFieldState();
}

class _ChunkyInputFieldState extends State<ChunkyInputField> {
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.typography.subtitle2.copyWith(
            color: _getTextColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppTheme.spacing.small),

        Container(
          decoration: BoxDecoration(
            color:
                widget.enabled
                    ? AppTheme.colors.surface
                    : AppTheme.colors.disabled.withValues(alpha: 26),
            borderRadius: BorderRadius.circular(AppTheme.radius.large),
            border: Border.all(
              color: _getBorderColor(),
              width: _isFocused ? 2.0 : 1.5,
            ),
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              validator: (value) {
                if (widget.validator != null) {
                  final error = widget.validator!(value);
                  setState(() {
                    _errorText = error;
                  });
                  return error;
                }
                return null;
              },
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              style: AppTheme.typography.body1.copyWith(
                color:
                    widget.enabled
                        ? AppTheme.colors.onSurface.withValues(alpha: 153)
                        : AppTheme.colors.onDisabled,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTheme.typography.body1.copyWith(
                  color: AppTheme.colors.onSurface.withValues(alpha: 128),
                ),
                contentPadding:
                    widget.contentPadding ??
                    EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing.medium,
                      vertical: AppTheme.spacing.medium,
                    ),
                border: InputBorder.none,
                prefixIcon:
                    widget.prefixIcon != null
                        ? Icon(widget.prefixIcon, color: _getIconColor())
                        : null,
                suffixIcon:
                    widget.suffixIcon != null
                        ? IconButton(
                          icon: Icon(widget.suffixIcon, color: _getIconColor()),
                          onPressed: widget.onSuffixIconPressed,
                        )
                        : null,
              ),
            ),
          ),
        ),

        if (_errorText != null) ...[
          SizedBox(height: AppTheme.spacing.xsmall),
          Text(
            _errorText!,
            style: AppTheme.typography.caption.copyWith(
              color: AppTheme.colors.error,
            ),
          ),
        ],
      ],
    );
  }

  Color _getBorderColor() {
    if (_errorText != null) {
      return PenguinoColors.redLight;
    }
    if (_isFocused) {
      return PenguinoColors.gooseBlue5;
    }
    return PenguinoColors.black2;
  }

  Color _getTextColor() {
    if (_errorText != null) {
      return PenguinoColors.redLight;
    }
    if (_isFocused) {
      return PenguinoColors.gooseBlue5;
    }
    return PenguinoColors.black7;
  }

  Color _getIconColor() {
    if (!widget.enabled) {
      return PenguinoColors.black3;
    }
    if (_errorText != null) {
      return PenguinoColors.redLight;
    }
    if (_isFocused) {
      return PenguinoColors.gooseBlue5;
    }
    return PenguinoColors.black6.withValues(alpha: 153);
  }
}

class ChunkyTextArea extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int minLines;
  final int maxLines;
  final bool enabled;

  const ChunkyTextArea({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 5,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChunkyInputField(
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.multiline,
      validator: validator,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      enabled: enabled,
      textInputAction: TextInputAction.newline,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing.medium,
        vertical: AppTheme.spacing.medium,
      ),
    );
  }
}

class ChunkyDropdownField<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const ChunkyDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<ChunkyDropdownField<T>> createState() => _ChunkyDropdownFieldState<T>();
}

class _ChunkyDropdownFieldState<T> extends State<ChunkyDropdownField<T>> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.typography.subtitle2.copyWith(
            color: _getTextColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppTheme.spacing.small),

        Container(
          decoration: BoxDecoration(
            color:
                widget.enabled
                    ? AppTheme.colors.surface
                    : AppTheme.colors.disabled.withValues(alpha: 26),
            borderRadius: BorderRadius.circular(AppTheme.radius.large),
            border: Border.all(color: _getBorderColor(), width: 1.5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing.medium,
            vertical: AppTheme.spacing.small,
          ),
          child: DropdownButtonFormField<T>(
            initialValue: widget.value,
            items: widget.items,
            onChanged: widget.enabled ? widget.onChanged : null,
            validator: (value) {
              if (widget.validator != null) {
                final error = widget.validator!(value);
                setState(() {
                  _errorText = error;
                });
                return error;
              }
              return null;
            },
            style: AppTheme.typography.body1.copyWith(
              color:
                  widget.enabled
                      ? AppTheme.colors.onSurface.withValues(alpha: 153)
                      : AppTheme.colors.onDisabled,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color:
                  widget.enabled
                      ? AppTheme.colors.onSurface.withValues(alpha: 153)
                      : AppTheme.colors.onDisabled,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            dropdownColor: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius.medium),
            elevation: 3,
          ),
        ),

        if (_errorText != null) ...[
          SizedBox(height: AppTheme.spacing.xsmall),
          Text(
            _errorText!,
            style: AppTheme.typography.caption.copyWith(
              color: AppTheme.colors.error,
            ),
          ),
        ],
      ],
    );
  }

  Color _getBorderColor() {
    if (_errorText != null) {
      return PenguinoColors.redLight;
    }
    return PenguinoColors.black2;
  }

  Color _getTextColor() {
    if (_errorText != null) {
      return PenguinoColors.redLight;
    }
    return PenguinoColors.black7;
  }
}
