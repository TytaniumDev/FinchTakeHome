import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
import 'package:birdo/view/widgets/common/chunky_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnergyIndicator extends StatelessWidget {
  const EnergyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DayManager, PetManager>(
      builder: (context, dayManager, petManager, child) {
        final currentEnergy = dayManager.getTotalEnergy();
        final maxEnergy = petManager.maxEnergy;
        final percentage = currentEnergy / maxEnergy;
        final isFull = currentEnergy >= maxEnergy;

        return _buildEnergyDisplay(
          context,
          currentEnergy: currentEnergy,
          maxEnergy: maxEnergy,
          percentage: percentage,
          isFull: isFull,
        );
      },
    );
  }

  Widget _buildEnergyDisplay(
    BuildContext context, {
    required int currentEnergy,
    required int maxEnergy,
    required double percentage,
    required bool isFull,
  }) {
    return ChunkyCard(
      padding: EdgeInsets.all(AppTheme.spacing.medium),
      color: isFull ? Colors.green[50] : AppTheme.colors.surface,
      borderRadius: AppTheme.radius.large,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Day Energy',
            style: AppTheme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: isFull ? Colors.green[800] : AppTheme.colors.primary,
            ),
          ),
          SizedBox(height: AppTheme.spacing.small),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$currentEnergy / $maxEnergy',
                style: AppTheme.typography.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFull ? Colors.green[800] : AppTheme.colors.onSurface,
                ),
              ),
              if (isFull)
                Padding(
                  padding: EdgeInsets.only(left: AppTheme.spacing.small),
                  child: Icon(Icons.star, color: Colors.amber, size: 28),
                ),
            ],
          ),
          SizedBox(height: AppTheme.spacing.medium),

          ChunkyProgressBar(
            value: percentage,
            height: 20,
            backgroundColor:
                isFull ? Colors.green[100] : AppTheme.colors.surface,
            fillColor: isFull ? Colors.green[600] : AppTheme.colors.primary,
            showPercentage: false,
          ),

          if (isFull)
            Padding(
              padding: EdgeInsets.only(top: AppTheme.spacing.small),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, color: Colors.amber, size: 16),
                  SizedBox(width: AppTheme.spacing.xsmall),
                  Text(
                    'Full Energy Day!',
                    style: AppTheme.typography.subtitle2.copyWith(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing.xsmall),
                  Icon(Icons.celebration, color: Colors.amber, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedEnergyIndicator extends StatefulWidget {
  const AnimatedEnergyIndicator({super.key});

  @override
  State<AnimatedEnergyIndicator> createState() =>
      _AnimatedEnergyIndicatorState();
}

class _AnimatedEnergyIndicatorState extends State<AnimatedEnergyIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationDuration.slow,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
    return Consumer2<DayManager, PetManager>(
      builder: (context, dayManager, petManager, child) {
        final currentEnergy = dayManager.getTotalEnergy();
        final maxEnergy = petManager.maxEnergy;
        final percentage = currentEnergy / maxEnergy;
        final isFull = currentEnergy >= maxEnergy;

        if (isFull &&
            _animationController.duration !=
                AppTheme.animationDuration.medium) {
          _animationController.duration = AppTheme.animationDuration.medium;
          _animationController.reset();
          _animationController.repeat(reverse: true);
        } else if (!isFull &&
            _animationController.duration != AppTheme.animationDuration.slow) {
          _animationController.duration = AppTheme.animationDuration.slow;
          _animationController.reset();
          _animationController.repeat(reverse: true);
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: isFull ? _pulseAnimation.value : 1.0,
              child: _buildEnergyDisplay(
                context,
                currentEnergy: currentEnergy,
                maxEnergy: maxEnergy,
                percentage: percentage,
                isFull: isFull,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnergyDisplay(
    BuildContext context, {
    required int currentEnergy,
    required int maxEnergy,
    required double percentage,
    required bool isFull,
  }) {
    return ChunkyCard(
      padding: EdgeInsets.all(AppTheme.spacing.medium),
      color: isFull ? Colors.green[50] : AppTheme.colors.surface,
      borderRadius: AppTheme.radius.large,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Day Energy',
            style: AppTheme.typography.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: isFull ? Colors.green[800] : AppTheme.colors.primary,
            ),
          ),
          SizedBox(height: AppTheme.spacing.small),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$currentEnergy / $maxEnergy',
                style: AppTheme.typography.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFull ? Colors.green[800] : AppTheme.colors.onSurface,
                ),
              ),
              if (isFull)
                Padding(
                  padding: EdgeInsets.only(left: AppTheme.spacing.small),
                  child: Icon(Icons.star, color: Colors.amber, size: 28),
                ),
            ],
          ),
          SizedBox(height: AppTheme.spacing.medium),

          ChunkyProgressBar(
            value: percentage,
            height: 20,
            backgroundColor:
                isFull ? Colors.green[100] : AppTheme.colors.surface,
            fillColor: isFull ? Colors.green[600] : AppTheme.colors.primary,
            showPercentage: false,
          ),

          if (isFull)
            Padding(
              padding: EdgeInsets.only(top: AppTheme.spacing.small),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, color: Colors.amber, size: 16),
                  SizedBox(width: AppTheme.spacing.xsmall),
                  Text(
                    'Full Energy Day!',
                    style: AppTheme.typography.subtitle2.copyWith(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing.xsmall),
                  Icon(Icons.celebration, color: Colors.amber, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
