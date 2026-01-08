import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/view/widgets/common/birdo_toast.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DailyCheckInModal extends StatefulWidget {
  final DateTime? date;
  final VoidCallback onCheckInComplete;

  const DailyCheckInModal({
    super.key,
    this.date,
    required this.onCheckInComplete,
  });

  @override
  State<DailyCheckInModal> createState() => _DailyCheckInModalState();
}

class _DailyCheckInModalState extends State<DailyCheckInModal> {
  bool _isCheckingIn = false;
  bool _hasEvolved = false;
  PetGrowthStage? _newGrowthStage;

  static const List<String> _checkInMessages = [
    'Le\'s go!',
    'Let\'s make today amazing!',
    'Ready for a great day?',
    'Time to shine!',
    'Another wonderful day ahead!',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _checkInMessages[DateTime.now().millisecondsSinceEpoch % 5],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            if (_hasEvolved && _newGrowthStage != null)
              _buildEvolutionIndicator(),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Today\'s Rewards',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'lib/assets/icons/rainbow-stones.svg',
                        height: 32,
                        width: 32,
                        placeholderBuilder:
                            (BuildContext context) => Icon(
                              Icons.stars,
                              size: 32,
                              color: Colors.purple,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+5',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ChunkyButton(
                text: _isCheckingIn ? 'Checking in...' : 'Start the Day!',
                onPressed:
                    _isCheckingIn ? null : () => _performCheckIn(context),
                isLoading: _isCheckingIn,
                isFullWidth: true,
                alignment: MainAxisAlignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performCheckIn(BuildContext context) async {
    setState(() {
      _isCheckingIn = true;
    });

    try {
      // Get the current growth stage before check-in
      final petManager = Provider.of<PetManager>(context, listen: false);
      final previousStage = petManager.growthStage;

      // Perform the check-in through the home controller
      widget.onCheckInComplete();

      // Check if pet evolved
      if (previousStage != null &&
          petManager.growthStage != null &&
          previousStage != petManager.growthStage) {
        setState(() {
          _hasEvolved = true;
          _newGrowthStage = petManager.growthStage;
        });

        BirdoToastManager.showSuccess(
          context,
          message:
              'Your pet has grown to ${_getArticleForStage(petManager.growthStage!)} ${_getGrowthStageName(petManager.growthStage!)}!',
        );
      }

      // Show success message
      BirdoToastManager.showSuccess(
        context,
        message: 'Check-in successful! You earned 5 Rainbow Stones!',
      );
    } catch (e) {
      BirdoToastManager.showError(context, message: 'Failed to check in: $e');
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  Widget _buildEvolutionIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Your Pet Evolved!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.auto_awesome, color: Colors.amber),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Congratulations! Your pet has grown to ${_getArticleForStage(_newGrowthStage!)} ${_getGrowthStageName(_newGrowthStage!)}!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.amber.shade900),
          ),
        ],
      ),
    );
  }

  String _getGrowthStageName(PetGrowthStage stage) {
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

  String _getArticleForStage(PetGrowthStage stage) {
    final stageName = _getGrowthStageName(stage);
    return 'aeiou'.contains(stageName[0].toLowerCase()) ? 'an' : 'a';
  }
}
