import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/hydration/widgets/quick_add_button_grid.dart';

/// Example widget demonstrating QuickAddButtonGrid usage
class QuickAddButtonGridExample extends StatefulWidget {
  const QuickAddButtonGridExample({super.key});

  @override
  State<QuickAddButtonGridExample> createState() =>
      _QuickAddButtonGridExampleState();
}

class _QuickAddButtonGridExampleState extends State<QuickAddButtonGridExample> {
  DrinkType _selectedDrinkType = DrinkType.water;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Add Button Grid Example'),
        backgroundColor: Colors.blue[100],
      ),
      body: Consumer<HydrationProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current intake display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Intake',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.currentIntake} ml / ${provider.dailyGoal} ml',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: provider.intakePercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[400]!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Drink type selector
                Text(
                  'Selected Drink Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButton<DrinkType>(
                  value: _selectedDrinkType,
                  onChanged: (DrinkType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedDrinkType = newValue;
                      });
                    }
                  },
                  items:
                      DrinkType.values.map<DropdownMenuItem<DrinkType>>((
                        DrinkType value,
                      ) {
                        return DropdownMenuItem<DrinkType>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(value.icon, color: value.color),
                              const SizedBox(width: 8),
                              Text(value.displayName),
                              const SizedBox(width: 8),
                              Text(
                                '(${(value.waterContent * 100).round()}% water)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 20),

                // Quick add button grid
                Text(
                  'Quick Add Buttons',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                QuickAddButtonGrid(
                  selectedDrinkType: _selectedDrinkType,
                  onAmountAdded: () {
                    // Show a snackbar when amount is added
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added ${_selectedDrinkType.displayName}!',
                        ),
                        duration: const Duration(seconds: 1),
                        backgroundColor: _selectedDrinkType.color,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Recent entries
                Text(
                  "Today's Entries",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                Expanded(
                  child:
                      provider.todaysEntries.isEmpty
                          ? const Center(
                            child: Text(
                              'No entries today. Add some hydration!',
                            ),
                          )
                          : ListView.builder(
                            itemCount: provider.todaysEntries.length,
                            itemBuilder: (context, index) {
                              final entry = provider.todaysEntries[index];
                              return ListTile(
                                leading: Icon(
                                  entry.type.icon,
                                  color: entry.type.color,
                                ),
                                title: Text(
                                  '${entry.amount} ml ${entry.type.displayName}',
                                ),
                                subtitle: Text(
                                  '${entry.waterContent} ml water • ${_formatTime(entry.timestamp)}',
                                ),
                                trailing: Text(
                                  '${(entry.type.waterContent * 100).round()}%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
