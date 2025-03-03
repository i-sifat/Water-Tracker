import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/providers/hydration_provider.dart';
import 'package:watertracker/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/widgets/water_level_painter.dart';
import 'package:watertracker/screens/add_hydration_screen.dart';
import 'package:watertracker/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenContent(),
    const AddHydrationScreenContent(),
    const HistoryScreenContent(selectedWeekIndex: 0),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            hydrationProvider.selectedAvatar == AvatarOption.male
                ? 'assets/avatars/male-avater.svg'
                : 'assets/avatars/female-avater.svg',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          Text(
            "${hydrationProvider.currentIntake} ml",
            style: textTheme.displayLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${hydrationProvider.remainingIntake} ml remaining",
            style: textTheme.bodyMedium!.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            "${(hydrationProvider.intakePercentage * 100).toStringAsFixed(0)}%",
            style: textTheme.bodyMedium!.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          WaterLevelAnimation(
            progress: hydrationProvider.intakePercentage,
            waterColor: const Color(0xFF5F85DB), // A shade of blue
            backgroundColor: const Color(0xFFC4D7F9), // Lighter blue
            width: 150, // Increased width
            height: 250, // Increased height
          ),
          const SizedBox(height: 40),
          // Avatar selection toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Male"),
              Switch(
                value: hydrationProvider.selectedAvatar == AvatarOption.female,
                onChanged: (value) {
                  hydrationProvider.changeAvatar(
                    value ? AvatarOption.female : AvatarOption.male,
                  );
                },
              ),
              const Text("Female"),
            ],
          ),
        ],
      ),
    );
  }
}
