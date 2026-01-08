// Import controllers and managers
import 'package:birdo/controllers/home_controller.dart';
import 'package:birdo/controllers/pet_controller.dart';
import 'package:birdo/controllers/settings_controller.dart';
import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/hive_registrar.g.dart';
import 'package:birdo/model/entities/day.dart';
import 'package:birdo/model/entities/pet.dart';
import 'package:birdo/model/entities/rainbow_stones.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/entities/user.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/model/managers/energy_manager.dart';
import 'package:birdo/model/managers/pet_manager.dart';
import 'package:birdo/model/managers/rainbow_stones_manager.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/model/services/user_service.dart';
import 'package:birdo/view/screens/home_screen.dart';
import 'package:birdo/view/screens/nux/nux_flow.dart';
import 'package:birdo/view/screens/pet_profile_screen.dart';
import 'package:birdo/view/screens/settings_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Initialize services first
  await ServiceLocator.initialize();

  // Close any open boxes first to avoid conflicts
  try {
    await Hive.close();
  } catch (e) {
    debugPrint('Error closing Hive: $e');
  }

  // Register adapters
  Hive.registerAdapters();

  // Open boxes
  try {
    // Close specific boxes if they're already open
    if (Hive.isBoxOpen(taskBox)) {
      await Hive.box(taskBox).close();
    }
    if (Hive.isBoxOpen(petBox)) {
      await Hive.box(petBox).close();
    }
    if (Hive.isBoxOpen(dayBox)) {
      await Hive.box(dayBox).close();
    }
    if (Hive.isBoxOpen(rainbowStonesBox)) {
      await Hive.box(rainbowStonesBox).close();
    }
    if (Hive.isBoxOpen(settingsBox)) {
      await Hive.box(settingsBox).close();
    }
    if (Hive.isBoxOpen(userBoxName)) {
      await Hive.box(userBoxName).close();
    }

    // Open all boxes
    await Hive.openBox<Task>(taskBox);
    await Hive.openBox<Pet>(petBox);
    await Hive.openBox<Day>(dayBox);
    await Hive.openBox<RainbowStones>(rainbowStonesBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox<User>(userBoxName);
  } catch (e) {
    debugPrint('Error opening Hive boxes: $e');
  }

  await secondaryInitializationSteps();
  runApp(
    DevicePreview(enabled: false, builder: (context) => const BirdoTasks()),
  );
}

/// Steps that should run after hive and services are initialized.
Future<void> secondaryInitializationSteps() async {
  await UserService.maybeCreateDebugUser();
  await UserService.syncUserToServer();
}

class BirdoTasks extends StatefulWidget {
  const BirdoTasks({super.key});

  @override
  State<BirdoTasks> createState() => _BirdoTasksState();
}

class _BirdoTasksState extends State<BirdoTasks> {
  bool? _hasCompletedNux;

  @override
  void initState() {
    super.initState();
    _checkNuxCompletion();
  }

  Future<void> _checkNuxCompletion() async {
    final hasCompleted = await ServiceLocator.nuxController.isNuxCompleted();
    setState(() {
      _hasCompletedNux = hasCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskManager()),
        ChangeNotifierProvider(create: (_) => PetManager()),
        ChangeNotifierProvider(create: (_) => DayManager()),
        ChangeNotifierProvider(create: (_) => EnergyManager()),
        ChangeNotifierProvider(create: (_) => RainbowStonesManager()),

        Provider(
          create:
              (context) => TaskController(
                taskManager: context.read<TaskManager>(),
                petManager: context.read<PetManager>(),
                dayManager: context.read<DayManager>(),
              ),
        ),
        Provider(
          create:
              (context) =>
                  PetController(petManager: context.read<PetManager>()),
        ),
        Provider(
          create:
              (context) => HomeController(
                petManager: context.read<PetManager>(),
                taskManager: context.read<TaskManager>(),
                dayManager: context.read<DayManager>(),
                rainbowStonesManager: context.read<RainbowStonesManager>(),
              ),
        ),
        Provider(
          create:
              (context) => SettingsController(
                petManager: context.read<PetManager>(),
                rainbowStonesManager: context.read<RainbowStonesManager>(),
              ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final taskManager = context.read<TaskManager>();
          final petManager = context.read<PetManager>();
          final dayManager = context.read<DayManager>();
          final energyManager = context.read<EnergyManager>();
          final rainbowStonesManager = context.read<RainbowStonesManager>();

          final taskController = context.read<TaskController>();
          final petController = context.read<PetController>();
          final homeController = context.read<HomeController>();
          final settingsController = context.read<SettingsController>();

          Future.microtask(() async {
            await taskManager.initialize();
            await petManager.initialize();
            await dayManager.initialize();
            await energyManager.initialize();
            await rainbowStonesManager.initialize();

            // Initialize controllers if needed
            await taskController.initialize();
            await petController.initialize();
            await homeController.initialize();
            await settingsController.initialize();
            await _checkNuxCompletion();
          });

          if (_hasCompletedNux == null) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            title: 'Birdo Tasks',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home:
                _hasCompletedNux!
                    ? const HomeScreen()
                    : NuxFlow(controller: ServiceLocator.nuxController),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/pet_profile': (context) => const PetProfileScreen(),
              '/nux':
                  (context) =>
                      NuxFlow(controller: ServiceLocator.nuxController),
            },
          );
        },
      ),
    );
  }
}
