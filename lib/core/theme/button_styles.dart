import 'package:birdo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ChunkyButtonStyles {
  static ButtonStyle primaryButton({bool isSmall = false}) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.disabled;
        }
        if (states.contains(WidgetState.pressed)) {
          return AppTheme.colors.primaryVariant;
        }
        return AppTheme.colors.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.onDisabled;
        }
        return AppTheme.colors.onPrimary;
      }),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal:
              isSmall ? AppTheme.spacing.large : AppTheme.spacing.xlarge,
          vertical: isSmall ? AppTheme.spacing.medium : AppTheme.spacing.large,
        ),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius.large),
        ),
      ),
      elevation: WidgetStateProperty.all<double>(0),
      shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
      overlayColor: WidgetStateProperty.all<Color>(
        Colors.white.withValues(alpha: 26),
      ),
      animationDuration: AppTheme.animationDuration.medium,
    );
  }

  static ButtonStyle secondaryButton({bool isSmall = false}) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.disabled;
        }
        if (states.contains(WidgetState.pressed)) {
          return AppTheme.colors.secondaryVariant;
        }
        return AppTheme.colors.secondary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.onDisabled;
        }
        return AppTheme.colors.onSecondary;
      }),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal:
              isSmall ? AppTheme.spacing.large : AppTheme.spacing.xlarge,
          vertical: isSmall ? AppTheme.spacing.medium : AppTheme.spacing.large,
        ),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius.large),
        ),
      ),
      elevation: WidgetStateProperty.all<double>(0),
      shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
      overlayColor: WidgetStateProperty.all<Color>(
        Colors.white.withValues(alpha: 26),
      ),
      animationDuration: AppTheme.animationDuration.medium,
    );
  }

  static ButtonStyle tertiaryButton({bool isSmall = false}) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.pressed)) {
          return AppTheme.colors.primary.withValues(alpha: 26);
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.disabled;
        }
        return AppTheme.colors.primary;
      }),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal:
              isSmall ? AppTheme.spacing.large : AppTheme.spacing.xlarge,
          vertical: isSmall ? AppTheme.spacing.medium : AppTheme.spacing.large,
        ),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius.large),
          side: BorderSide(color: AppTheme.colors.primary, width: 2.0),
        ),
      ),
      elevation: WidgetStateProperty.all<double>(0),
      overlayColor: WidgetStateProperty.all<Color>(
        AppTheme.colors.primary.withValues(alpha: 26),
      ),
      animationDuration: AppTheme.animationDuration.medium,
    );
  }

  static ButtonStyle accentButton({bool isSmall = false}) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.disabled;
        }
        if (states.contains(WidgetState.pressed)) {
          return AppTheme.colors.accent.withValues(alpha: 204);
        }
        return AppTheme.colors.accent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.onDisabled;
        }
        return AppTheme.colors.onAccent;
      }),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal:
              isSmall ? AppTheme.spacing.large : AppTheme.spacing.xlarge,
          vertical: isSmall ? AppTheme.spacing.medium : AppTheme.spacing.large,
        ),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius.large),
        ),
      ),
      elevation: WidgetStateProperty.all<double>(0),
      shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
      overlayColor: WidgetStateProperty.all<Color>(
        Colors.white.withValues(alpha: 26),
      ),
      animationDuration: AppTheme.animationDuration.medium,
    );
  }

  static ButtonStyle iconButton({
    Color? color,
    double size = 48.0,
    double shadowOffset = 4.0,
  }) {
    final buttonColor = color ?? AppTheme.colors.primary;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.disabled;
        }
        if (states.contains(WidgetState.pressed)) {
          return buttonColor.withValues(alpha: 204);
        }
        return buttonColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return AppTheme.colors.onDisabled;
        }
        return Colors.white;
      }),
      minimumSize: WidgetStateProperty.all<Size>(Size(size, size)),
      maximumSize: WidgetStateProperty.all<Size>(Size(size, size)),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius.circular),
        ),
      ),
      elevation: WidgetStateProperty.all<double>(0),
      shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.all(AppTheme.spacing.small),
      ),
      animationDuration: AppTheme.animationDuration.medium,
    );
  }

  static Color getDarkerColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness * 0.8).clamp(0.0, 1.0)).toColor();
  }
}
