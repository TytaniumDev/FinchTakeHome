import 'package:birdo/controllers/pet_controller.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize pet data when screen loads
    final petManager = Provider.of<PetManager>(context, listen: false);
    if (petManager.currentPet == null) {
      petManager.loadCurrentPet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<PetManager>(
            builder: (context, petManager, child) {
              final pet = petManager.currentPet;

              if (pet == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPetVisualization(pet, petManager),
                  const SizedBox(height: 24),

                  _buildStatisticsSection(pet),
                  const SizedBox(height: 32),

                  _buildActivitySection(),
                  const SizedBox(height: 32),

                  _buildCustomizationSection(pet, context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPetVisualization(Pet pet, PetManager petManager) {
    return Column(
      children: [
        Text(
          pet.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 77),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: SvgPicture.asset(
              _getPetSvgAsset(pet.growthStage),
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getGrowthStageLabel(pet.growthStage),
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),

        if (pet.growthStage != PetGrowthStage.adult)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                const Text(
                  'Progress to next evolution:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _calculateEvolutionProgress(pet),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatisticsSection(Pet pet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pet Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildStatItem(
              'Full Energy Days',
              '${pet.energy.fullEnergyDays} days',
            ),
            _buildStatItem(
              'Total Energy Earned',
              pet.energy.totalEnergyEarned.toStringAsFixed(0),
            ),
            _buildStatItem(
              'Current Growth Stage',
              _getGrowthStageLabel(pet.growthStage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Icon(Icons.emoji_nature, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  const Text(
                    'Activity Chart Coming Soon!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationSection(Pet pet, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customization',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Pet Name'),
              subtitle: Text(pet.name),
              onTap: () => _showNameEditDialog(context, pet),
            ),
            const ListTile(
              leading: Icon(Icons.color_lens, color: Colors.grey),
              title: Text('Change Pet Color'),
              subtitle: Text('Coming soon'),
              enabled: false,
            ),
            const ListTile(
              leading: Icon(Icons.style, color: Colors.grey),
              title: Text('Pet Accessories'),
              subtitle: Text('Coming soon'),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showNameEditDialog(BuildContext context, Pet pet) {
    final TextEditingController controller = TextEditingController(
      text: pet.name,
    );
    final petController = Provider.of<PetController>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Pet Name'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Pet Name'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    // Use PetController to update the pet name
                    petController.updatePet(name: controller.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
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

  double _calculateEvolutionProgress(Pet pet) {
    if (pet.growthStage == PetGrowthStage.adult) {
      return 1.0;
    }

    final requiredDays = pet.getRequiredFullEnergyDaysForEvolution();

    if (requiredDays <= 0) {
      return 0.0;
    }

    final progress = pet.energy.fullEnergyDays / requiredDays;

    return progress.clamp(0.0, 1.0);
  }
}
