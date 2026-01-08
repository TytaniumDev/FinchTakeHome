import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/view/widgets/energy_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PetView extends StatelessWidget {
  const PetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetManager>(
      builder: (context, petManager, child) {
        final pet = petManager.currentPet;
        
        if (pet == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return _buildPetDisplay(context, pet);
      },
    );
  }

  Widget _buildPetDisplay(BuildContext context, Pet pet) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          pet.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _getGrowthStageLabel(pet.growthStage),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(60),
          ),
          child: Center(
            child: SvgPicture.asset(
              _getPetSvgAsset(pet.growthStage),
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),

        const EnergyIndicator(),
      ],
    );
  }

  String _getGrowthStageLabel(PetGrowthStage stage) {
    switch (stage) {
      case PetGrowthStage.egg:
        return 'Egg';
      case PetGrowthStage.baby:
        return 'Baby';
      case PetGrowthStage.toddler:
        return 'Toddler';
      case PetGrowthStage.child:
        return 'Child';
      case PetGrowthStage.teenager:
        return 'Teenager';
      case PetGrowthStage.adult:
        return 'Adult';
    }
  }

  String _getPetSvgAsset(PetGrowthStage growthStage) {
    switch (growthStage) {
      case PetGrowthStage.egg:
        return 'lib/assets/stages/egg.svg';
      case PetGrowthStage.baby:
        return 'lib/assets/stages/baby.svg';
      case PetGrowthStage.toddler:
        return 'lib/assets/stages/toddler.svg';
      case PetGrowthStage.child:
        return 'lib/assets/stages/child.svg';
      case PetGrowthStage.teenager:
        return 'lib/assets/stages/teen.svg';
      case PetGrowthStage.adult:
        return 'lib/assets/stages/adult.svg';
    }
  }
}
