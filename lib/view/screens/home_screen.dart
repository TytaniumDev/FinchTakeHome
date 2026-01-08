import 'package:birdo/controllers/home_controller.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/core/theme/penguino_colors.dart';
import 'package:birdo/model/managers/day_manager.dart';
import 'package:birdo/view/screens/task_list.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:birdo/view/widgets/daily_check_in_modal.dart';
import 'package:birdo/view/widgets/energy_indicator.dart';
import 'package:birdo/view/widgets/rainbow_stones_indicator.dart';
import 'package:birdo/view/widgets/task_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _showDailyCheckIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeHomeScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload data when app is resumed
      _initializeHomeScreen();
    }
  }

  Future<void> _initializeHomeScreen() async {
    final homeController = Provider.of<HomeController>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    // Load all required data
    await homeController.loadHomeScreenData();

    // Check if daily check-in is needed
    final needsCheckIn = !homeController.hasCheckedInToday;

    setState(() {
      _isLoading = false;
      _showDailyCheckIn = needsCheckIn;
    });
  }

  void _completeDailyCheckIn() async {
    final homeController = Provider.of<HomeController>(context, listen: false);
    await homeController.performDailyCheckIn();

    setState(() {
      _showDailyCheckIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(PenguinoColors.gooseBlue5, Colors.white, 0.5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: RainbowStonesIndicator(),
        ),
        title: const Text('Birdo Tasks', style: TextStyle(color: Colors.black)),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_showDailyCheckIn) {
            return Consumer<DayManager>(
              builder: (context, dayManager, child) {
                return DailyCheckInModal(
                  date:
                      dayManager.currentDay?.date ??
                      ServiceLocator.dateTimeService.getCurrentDate(),
                  onCheckInComplete: _completeDailyCheckIn,
                );
              },
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const EnergyIndicator(),
                ),
              ),
              const Expanded(child: TaskListPage()),
            ],
          );
        },
      ),
      bottomNavigationBar:
          _showDailyCheckIn
              ? null
              : BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 8.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed:
                          () => Navigator.of(context).pushNamed('/settings'),
                      tooltip: 'Settings',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ChunkyIconButton(
                        icon: Icons.add,
                        onPressed: () {
                          showTaskFormDialog(context);
                        },
                        size: 56.0,
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'lib/assets/icons/bird-face-pet-new.svg',
                        height: 24,
                        width: 24,
                        placeholderBuilder:
                            (BuildContext context) => const Icon(Icons.pets),
                      ),
                      onPressed:
                          () => Navigator.of(context).pushNamed('/pet_profile'),
                      tooltip: 'Pet Profile',
                    ),
                  ],
                ),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
