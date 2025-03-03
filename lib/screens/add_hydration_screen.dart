import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/providers/hydration_provider.dart';
import 'package:watertracker/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/screens/history_screen.dart';
import 'package:watertracker/screens/home_screen.dart';

class AddHydrationScreen extends StatefulWidget {
  const AddHydrationScreen({super.key});

  @override
  State<AddHydrationScreen> createState() => _AddHydrationScreenState();
}

class _AddHydrationScreenState extends State<AddHydrationScreen> {
  int _selectedIndex = 1;

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

class AddHydrationScreenContent extends StatelessWidget {
  const AddHydrationScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Add Hydration",
            style: textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: hydrationProvider.intakePercentage,
                  strokeWidth: 18,
                  backgroundColor: const Color(0xFFE5E5E5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFB1C7FF),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    "${(hydrationProvider.intakePercentage * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF314370),
                    ),
                  ),
                  Text(
                    "${hydrationProvider.currentIntake} ml",
                    style: textTheme.bodyLarge,
                  ),
                  Text(
                    "-${hydrationProvider.remainingIntake} ml",
                    style: textTheme.bodyMedium!.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAmountButton(
                context,
                250,
                hydrationProvider,
                const Color(0xFFE8D4FF),
              ),
              const SizedBox(width: 20),
              _buildAmountButton(
                context,
                500,
                hydrationProvider,
                const Color(0xFFC9F2F6),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAmountButton(
                context,
                100,
                hydrationProvider,
                const Color(0xFFD2FFD6),
              ),
              const SizedBox(width: 20),
              _buildAmountButton(
                context,
                400,
                hydrationProvider,
                const Color(0xFFFEFFD1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountButton(
    BuildContext context,
    int amount,
    HydrationProvider provider,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () {
        provider.addHydration(amount);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: Theme.of(context).textTheme.bodyLarge,
      ),
      child: Text(
        "$amount ml",
        style: Theme.of(
          context,
        ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
