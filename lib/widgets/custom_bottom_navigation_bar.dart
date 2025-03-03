import 'package:flutter/material.dart';
import 'package:watertracker/screens/add_hydration_screen.dart';
import 'package:watertracker/screens/history_screen.dart';
import 'package:watertracker/screens/home_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: IconButton(
              icon: Image.asset(
                selectedIndex == 0
                    ? 'assets/navbaricons/waterdropicons-selected.svg'
                    : 'assets/navbaricons/waterdropicons-unselect.svg',
                width: 30,
                height: 30,
              ),
              onPressed: () => onItemTapped(0),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Image.asset(
                selectedIndex == 1
                    ? 'assets/navbaricons/circle-notch-selected.svg'
                    : 'assets/navbaricons/circle-notch-non-selected.svg',
                width: 60,
                height: 60,
              ),
              onPressed: () => onItemTapped(1),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Image.asset(
                selectedIndex == 2
                    ? 'assets/navbaricons/options-selected.svg'
                    : 'assets/navbaricons/options-nonselected.svg',
                width: 30,
                height: 30,
              ),
              onPressed: () => onItemTapped(2),
            ),
          ),
        ],
      ),
    );
  }
}
