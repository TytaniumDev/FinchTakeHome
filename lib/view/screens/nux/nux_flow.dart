import 'package:birdo/controllers/nux_controller.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/user.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/services/pet_service.dart';
import 'package:birdo/model/services/user_service.dart';
import 'package:birdo/view/screens/nux/nux_bird_name_screen.dart';
import 'package:birdo/view/screens/nux/nux_user_name_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Container widget for the NUX flow
class NuxFlow extends StatefulWidget {
  final NuxController controller;

  const NuxFlow({super.key, required this.controller});

  @override
  State<NuxFlow> createState() => _NuxFlowState();
}

class _NuxFlowState extends State<NuxFlow> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBirdNameSubmitted(String name) {
    widget.controller.birdName = name;
  }

  void _onUserNameSubmitted(String name) {
    widget.controller.userName = name;
  }

  void _goToNextScreen() {
    debugPrint('NuxFlow: Going to next screen');
    final currentIndex = widget.controller.getCurrentScreenIndex();
    final nextIndex = currentIndex + 1;
    debugPrint(
      'NuxFlow: Current index: $currentIndex, Next index: $nextIndex, Total screens: ${widget.controller.getTotalScreenCount()}',
    );

    if (nextIndex < widget.controller.getTotalScreenCount()) {
      widget.controller.goToNextScreen();

      debugPrint('NuxFlow: Animating to page $nextIndex');
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      debugPrint('NuxFlow: Animation started');
    } else {
      debugPrint('NuxFlow: Next index out of bounds, not animating');
    }
  }

  void _goToPreviousScreen() {
    final prevIndex = widget.controller.getCurrentScreenIndex() - 1;
    if (prevIndex >= 0) {
      widget.controller.goToPreviousScreen();

      _pageController.animateToPage(
        prevIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeNux() async {
    final birdName = widget.controller.birdName;
    final userName = widget.controller.userName;

    if (birdName != null && userName != null) {
      try {
        final pet = await PetService.createNewPet(
          name: birdName,
          gender: Gender.other,
        );

        debugPrint('NuxFlow: Created pet with name: ${pet.name}');

        final userId = await UserService.getOrCreateUserId();
        final user = await UserService.getUser(userId);

        if (user != null) {
          await UserService.changeUserName(userName);
        } else {
          final newUser = User(id: userId, name: userName);
          await UserService.saveUser(newUser);
        }

        if (!mounted) return;
        final petManager = Provider.of<PetManager>(context, listen: false);
        await petManager.loadCurrentPet();

        await widget.controller.completeNux();

        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/');
      } catch (e) {
        debugPrint('NuxFlow: Error completing NUX: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting up your account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.controller.getCurrentScreenIndex() == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          _goToPreviousScreen();
        }
      },
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.controller.getTotalScreenCount(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return NuxBirdNameScreen(
              onNameSubmitted: _onBirdNameSubmitted,
              onNext: _goToNextScreen,
            );
          } else {
            return NuxUserNameScreen(
              onNameSubmitted: _onUserNameSubmitted,
              onNext: _completeNux,
              onBack: _goToPreviousScreen,
            );
          }
        },
      ),
    );
  }
}
