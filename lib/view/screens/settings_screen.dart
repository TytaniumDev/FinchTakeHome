import 'package:birdo/controllers/home_controller.dart';
import 'package:birdo/controllers/settings_controller.dart';
import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/entities/user.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/model/services/user_service.dart';
import 'package:birdo/view/widgets/common/birdo_toast.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _dayOffset = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadDayOffset();
    _loadUser();

    // Initialize settings data
    final settingsController = Provider.of<SettingsController>(
      context,
      listen: false,
    );
    settingsController.loadSettingsData();
  }

  Future<void> _loadUser() async {
    final user = await UserService.getCurrentUser();
    setState(() {
      _user = user;
    });
  }

  Future<void> _loadDayOffset() async {
    try {
      final offset = await ServiceLocator.dateTimeService.getDayOffset();

      setState(() {
        _dayOffset = offset;
      });
    } catch (e) {
      print('Error loading day offset: $e');
    }
  }

  Future<void> _showChangeNameDialog(BuildContext contextParam) async {
    final user = await UserService.getCurrentUser();
    if (user == null) return;

    if (!mounted) return;

    final TextEditingController nameController = TextEditingController(
      text: user.name,
    );

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Name'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'New Name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    await UserService.changeUserName(newName);
                    await UserService.syncUserToServer();
                    if (context.mounted) {
                      Navigator.pop(context);
                      final user = await UserService.getCurrentUser();
                      if (context.mounted) {
                        setState(() {
                          _user = user;
                        });
                        BirdoToastManager.showSuccess(
                          context,
                          message: 'Name updated successfully',
                        );
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(PenguinoColors.gooseBlue5, Colors.white, 0.5),
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer3<PetManager, RainbowStonesManager, DayManager>(
        builder: (
          context,
          petManager,
          rainbowStonesManager,
          dayManager,
          child,
        ) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Profile Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'User ID: ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            if (_user?.id != null)
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: _user!.id),
                                  );
                                  BirdoToastManager.showInfo(
                                    context,
                                    message: 'User ID copied to clipboard',
                                  );
                                },
                                child: Text(
                                  _user!.id,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            else
                              const Text(
                                'Not set',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current name: ${_user?.name ?? 'Not set'}',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ChunkyButton(
                          text: 'Change Name',
                          icon: Icons.person,
                          type: ButtonType.primary,
                          onPressed: () => _showChangeNameDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Debug Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time Travel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Current day offset: $_dayOffset days'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: [
                        ChunkyButton(
                          text: '-1',
                          icon: Icons.arrow_back,
                          isSmall: true,
                          type: ButtonType.primary,
                          onPressed: () => _updateDayOffset(-1),
                        ),
                        ChunkyButton(
                          text: 'Reset',
                          icon: Icons.restart_alt,
                          isSmall: true,
                          type: ButtonType.primary,
                          onPressed:
                              _dayOffset == 0
                                  ? null
                                  : () => _updateDayOffset(0, reset: true),
                        ),
                        ChunkyButton(
                          text: '+1',
                          icon: Icons.arrow_forward,
                          isSmall: true,
                          type: ButtonType.primary,
                          onPressed: () => _updateDayOffset(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChunkyButton(
                      text: 'Clear All Data',
                      icon: Icons.delete_forever,
                      type: ButtonType.primary,
                      onPressed: () => _showClearDataConfirmation(context),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Delete all stored data and restart the app',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChunkyButton(
                      text: 'Clear Pet Data',
                      icon: Icons.pets,
                      type: ButtonType.primary,
                      onPressed: () => _showClearPetDataConfirmation(context),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Delete only pet-related data',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChunkyButton(
                      text: 'Clear Task Data',
                      icon: Icons.task,
                      type: ButtonType.primary,
                      onPressed: () => _showClearTaskDataConfirmation(context),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Delete only task-related data',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChunkyButton(
                      text: 'Reset NUX',
                      icon: Icons.refresh,
                      type: ButtonType.primary,
                      onPressed: () => _showResetNuxConfirmation(context),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Reset the new user experience flow',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showClearDataConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'This will delete all stored data and restart the app. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await _clearAllData(context);
    }
  }

  Future<void> _showClearPetDataConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Pet Data'),
            content: const Text(
              'This will delete all pet-related data. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('Clear Pet Data'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await _clearPetData(context);
    }
  }

  Future<void> _showClearTaskDataConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Task Data'),
            content: const Text(
              'This will delete all task-related data. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('Clear Task Data'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await _clearTaskData(context);
    }
  }

  Future<void> _showResetNuxConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset NUX'),
            content: const Text(
              'This will reset the new user experience flow. You will need to go through the setup process again the next time you open the app.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await _resetNux(context);
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    try {
      final homeController = Provider.of<HomeController>(
        context,
        listen: false,
      );

      // Clear all data
      await Hive.box<Pet>(petBox).clear();
      await Hive.box<Task>(taskBox).clear();
      await Hive.box<Day>(dayBox).clear();
      await Hive.box<RainbowStones>(rainbowStonesBox).clear();
      await Hive.box(settingsBox).clear();

      // Reset NUX state to ensure the onboarding flow starts properly
      await ServiceLocator.nuxController.resetNux();

      if (context.mounted) {
        BirdoToastManager.showSuccess(
          context,
          message: 'All data cleared successfully. Restarting app...',
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            // Use pushNamedAndRemoveUntil to clear the navigation stack
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);

            // Force a rebuild of the app by triggering a state change
            // This helps ensure the app properly restarts with a clean state
            homeController.forceAppRestart();
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        BirdoToastManager.showError(
          context,
          message: 'Error clearing data: $e',
        );
      }
    }
  }

  Future<void> _clearPetData(BuildContext context) async {
    try {
      final homeController = Provider.of<HomeController>(
        context,
        listen: false,
      );

      // Clear pet data
      await Hive.box<Pet>(petBox).clear();

      // Show success message
      if (context.mounted) {
        BirdoToastManager.showSuccess(
          context,
          message: 'Pet data cleared successfully. Restarting app...',
        );

        // Use a longer delay to ensure the toast is visible
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            // Use pushNamedAndRemoveUntil to clear the navigation stack
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);

            // Force a rebuild of the app by triggering a state change
            homeController.forceAppRestart();
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        BirdoToastManager.showError(
          context,
          message: 'Error clearing pet data: $e',
        );
      }
    }
  }

  Future<void> _clearTaskData(BuildContext context) async {
    try {
      final homeController = Provider.of<HomeController>(
        context,
        listen: false,
      );

      // Clear task and day data
      await Hive.box<Task>(taskBox).clear();
      await Hive.box<Day>(dayBox).clear();

      // Show success message
      if (context.mounted) {
        BirdoToastManager.showSuccess(
          context,
          message: 'Task data cleared successfully. Restarting app...',
        );

        // Use a longer delay to ensure the toast is visible
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            // Use pushNamedAndRemoveUntil to clear the navigation stack
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);

            // Force a rebuild of the app by triggering a state change
            homeController.forceAppRestart();
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        BirdoToastManager.showError(
          context,
          message: 'Error clearing task data: $e',
        );
      }
    }
  }

  Future<void> _resetNux(BuildContext context) async {
    try {
      final homeController = Provider.of<HomeController>(
        context,
        listen: false,
      );

      await ServiceLocator.nuxController.resetNux();

      if (context.mounted) {
        BirdoToastManager.showSuccess(
          context,
          message: 'NUX reset successfully. Restarting app...',
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            // Use pushNamedAndRemoveUntil to clear the navigation stack
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);

            // Force a rebuild of the app by triggering a state change
            homeController.forceAppRestart();
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        BirdoToastManager.showError(
          context,
          message: 'Error resetting NUX: $e',
        );
      }
    }
  }

  void _updateDayOffset(int value, {bool reset = false}) async {
    final dayManager = Provider.of<DayManager>(context, listen: false);
    final petManager = Provider.of<PetManager>(context, listen: false);
    final taskManager = Provider.of<TaskManager>(context, listen: false);
    final rainbowStonesManager = Provider.of<RainbowStonesManager>(
      context,
      listen: false,
    );
    final homeController = Provider.of<HomeController>(context, listen: false);

    try {
      final newOffset = reset ? 0 : _dayOffset + value;

      setState(() {
        _dayOffset = newOffset;
      });

      await ServiceLocator.dateTimeService.setDayOffset(newOffset);

      final offsetDate = ServiceLocator.dateTimeService.getCurrentDate();

      final dayId = ServiceLocator.dateTimeService.generateDayId(offsetDate);
      Day? targetDay = Hive.box<Day>(dayBox).get(dayId);

      if (targetDay == null) {
        targetDay = Day.create(offsetDate);
        await Hive.box<Day>(dayBox).put(targetDay.id, targetDay);
      }

      // Update all managers to reflect the new date
      await dayManager.loadCurrentDay();
      await taskManager.loadTasksForDay(offsetDate);
      await rainbowStonesManager.loadRainbowStones();
      await petManager.loadCurrentPet();
      await homeController.loadHomeScreenData();

      if (mounted) {
        BirdoToastManager.showInfo(
          context,
          message:
              reset
                  ? 'Time reset to current day'
                  : 'Time traveled to ${offsetDate.year}-${offsetDate.month.toString().padLeft(2, '0')}-${offsetDate.day.toString().padLeft(2, '0')}',
        );
      }
    } catch (e) {
      if (mounted) {
        BirdoToastManager.showError(
          context,
          message: 'Error updating day offset: $e',
        );
      }
    }
  }
}
