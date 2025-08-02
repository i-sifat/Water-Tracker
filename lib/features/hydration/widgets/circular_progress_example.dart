import 'package:flutter/material.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/models/hydration_progress.dart';
import 'package:watertracker/features/hydration/widgets/circular_progress_section.dart';

/// Example widget demonstrating how to use CircularProgressSection
/// This can be used as a reference for integration into the main hydration screen
class CircularProgressExample extends StatefulWidget {
  const CircularProgressExample({super.key});

  @override
  State<CircularProgressExample> createState() =>
      _CircularProgressExampleState();
}

class _CircularProgressExampleState extends State<CircularProgressExample> {
  late HydrationProgress _progress;
  int _currentPage = 1; // 0 = history, 1 = main, 2 = goals

  @override
  void initState() {
    super.initState();
    _initializeProgress();
  }

  void _initializeProgress() {
    final now = DateTime.now();
    final reminderTime = now.add(const Duration(hours: 2, minutes: 22));

    _progress = HydrationProgress(
      currentIntake: 1750, // 1.75L
      dailyGoal: 3000, // 3L
      todaysEntries: [
        HydrationData(
          id: '1',
          amount: 500,
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
        HydrationData(
          id: '2',
          amount: 750,
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
        HydrationData(
          id: '3',
          amount: 500,
          timestamp: now.subtract(const Duration(minutes: 30)),
          type: DrinkType.tea,
        ),
      ],
      nextReminderTime: reminderTime,
    );
  }

  void _addHydration(int amount) {
    setState(() {
      final newEntry = HydrationData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        timestamp: DateTime.now(),
      );

      final updatedEntries = [..._progress.todaysEntries, newEntry];
      final newIntake = _progress.currentIntake + amount;

      _progress = _progress.copyWith(
        currentIntake: newIntake,
        todaysEntries: updatedEntries,
      );
    });
  }

  void _simulatePageChange(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Circular Progress Example'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header section
            _buildHeader(),
            const SizedBox(height: 32),

            // Circular progress section
            CircularProgressSection(
              progress: _progress,
              currentPage: _currentPage,
            ),

            const SizedBox(height: 32),

            // Quick add buttons for testing
            _buildQuickAddButtons(),

            const SizedBox(height: 24),

            // Page navigation buttons for testing
            _buildPageNavigationButtons(),

            const SizedBox(height: 24),

            // Progress info card
            _buildProgressInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        const Column(
          children: [
            Text(
              'Today',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF313A34),
              ),
            ),
            Text(
              '07:00 AM • 2min • 11:00 PM',
              style: TextStyle(fontSize: 12, color: Color(0xFF647067)),
            ),
          ],
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
      ],
    );
  }

  Widget _buildQuickAddButtons() {
    final buttonData = [
      {'amount': 500, 'color': const Color(0xFFB39DDB)},
      {'amount': 250, 'color': const Color(0xFF81D4FA)},
      {'amount': 400, 'color': const Color(0xFFA5D6A7)},
      {'amount': 100, 'color': const Color(0xFFFFF59D)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add (for testing)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF313A34),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: buttonData.length,
          itemBuilder: (context, index) {
            final data = buttonData[index];
            return ElevatedButton(
              onPressed: () => _addHydration(data['amount']! as int),
              style: ElevatedButton.styleFrom(
                backgroundColor: data['color']! as Color,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '${data['amount']} ml',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPageNavigationButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Page Navigation (for testing)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF313A34),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _simulatePageChange(0),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _currentPage == 0
                        ? const Color(0xFF918DFE)
                        : Colors.grey[300],
                foregroundColor:
                    _currentPage == 0 ? Colors.white : Colors.black87,
              ),
              child: const Text('History'),
            ),
            ElevatedButton(
              onPressed: () => _simulatePageChange(1),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _currentPage == 1
                        ? const Color(0xFF918DFE)
                        : Colors.grey[300],
                foregroundColor:
                    _currentPage == 1 ? Colors.white : Colors.black87,
              ),
              child: const Text('Main'),
            ),
            ElevatedButton(
              onPressed: () => _simulatePageChange(2),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _currentPage == 2
                        ? const Color(0xFF918DFE)
                        : Colors.grey[300],
                foregroundColor:
                    _currentPage == 2 ? Colors.white : Colors.black87,
              ),
              child: const Text('Goals'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF313A34),
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressRow(
              'Current Intake',
              '${_progress.currentIntake} ml',
            ),
            _buildProgressRow('Daily Goal', '${_progress.dailyGoal} ml'),
            _buildProgressRow(
              'Progress',
              '${(_progress.percentage * 100).toStringAsFixed(1)}%',
            ),
            _buildProgressRow('Remaining', '${_progress.remainingIntake} ml'),
            _buildProgressRow(
              'Entries Today',
              '${_progress.todaysEntries.length}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF647067)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF313A34),
            ),
          ),
        ],
      ),
    );
  }
}
