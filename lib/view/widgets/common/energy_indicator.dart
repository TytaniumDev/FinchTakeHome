import 'package:birdo/model/managers/pet_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnergyIndicator extends StatelessWidget {
  const EnergyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetManager>(
      builder: (context, petManager, child) {
        final currentEnergy = petManager.currentEnergy;
        final maxEnergy = petManager.maxEnergy;
        final percentage = petManager.energyPercentage;
        final isFull = petManager.isEnergyFull;

        return _buildEnergyIndicator(
          context,
          currentEnergy: currentEnergy,
          maxEnergy: maxEnergy,
          percentage: percentage,
          isFull: isFull,
        );
      },
    );
  }

  Widget _buildEnergyIndicator(
    BuildContext context, {
    required int currentEnergy,
    required int maxEnergy,
    required double percentage,
    required bool isFull,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: 0,
              green: 0,
              blue: 0,
              alpha: 0.1,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Energy', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '$currentEnergy / $maxEnergy',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
