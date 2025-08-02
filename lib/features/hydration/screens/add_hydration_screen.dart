import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/models/hydration_data.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';

// Main screen widget that appears when users want to add hydration
class AddHydrationScreen extends StatefulWidget {
  const AddHydrationScreen({super.key});

  @override
  State<AddHydrationScreen> createState() => _AddHydrationScreenState();
}

// Content widget specifically for the Add Hydration screen
class AddHydrationScreenContent extends StatefulWidget {
  const AddHydrationScreenContent({super.key});

  @override
  State<AddHydrationScreenContent> createState() =>
      _AddHydrationScreenContentState();
}

class _AddHydrationScreenContentState extends State<AddHydrationScreenContent>
    with TickerProviderStateMixin {
  DrinkType _selectedDrinkType = DrinkType.water;
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _showCustomInput = false;
  bool _showBulkEntry = false;
  bool _showDrinkTypeSelector = false;

  // Enhanced undo functionality
  final List<HydrationData> _undoStack = [];
  late AnimationController _undoAnimationController;
  late Animation<double> _undoAnimation;
  Timer? _undoTimer;

  // Smart suggestions based on patterns
  List<int> _smartSuggestions = [500, 250, 400, 100];

  // Circular progress card controller
  late PageController _circularCardController;
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _undoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _undoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _undoAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _circularCardController = PageController(viewportFraction: 1.0);
    _loadSmartSuggestions();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _notesController.dispose();
    _undoAnimationController.dispose();
    _circularCardController.dispose();
    _undoTimer?.cancel();
    super.dispose();
  }

  void _loadSmartSuggestions() {
    final hydrationProvider = Provider.of<HydrationProvider>(
      context,
      listen: false,
    );
    final recentEntries = hydrationProvider.todaysEntries;

    if (recentEntries.isNotEmpty) {
      // Calculate most common amounts from recent entries
      final amountCounts = <int, int>{};
      for (final entry in recentEntries.take(20)) {
        amountCounts[entry.amount] = (amountCounts[entry.amount] ?? 0) + 1;
      }

      // Sort by frequency and take top suggestions
      final sortedAmounts =
          amountCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedAmounts.isNotEmpty) {
        _smartSuggestions = sortedAmounts.take(4).map((e) => e.key).toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    const darkBlueColor = Color(0xFF323062);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),

          // Time display header
          _buildTimeHeader(),

          const SizedBox(height: 40),

          // Circular progress with swipeable cards
          _buildCircularProgressSection(hydrationProvider),

          const SizedBox(height: 60),

          // Undo button (appears when there are entries in undo stack)
          if (_undoStack.isNotEmpty)
            AnimatedBuilder(
              animation: _undoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _undoAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: _undoLastEntry,
                      icon: const Icon(Icons.undo),
                      label: Text('Undo ${_undoStack.isNotEmpty ? _undoStack.last.amount : 0}ml'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 20),

          // Drink type selector toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showDrinkTypeSelector = !_showDrinkTypeSelector;
                      });
                    },
                    icon: Icon(_getDrinkTypeIcon(_selectedDrinkType)),
                    label: Text(_selectedDrinkType.displayName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _showDrinkTypeSelector
                              ? darkBlueColor
                              : Colors.grey.shade200,
                      foregroundColor:
                          _showDrinkTypeSelector ? Colors.white : darkBlueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showCustomInput = !_showCustomInput;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        _showCustomInput ? darkBlueColor : Colors.grey.shade200,
                    foregroundColor:
                        _showCustomInput ? Colors.white : darkBlueColor,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showBulkEntry = !_showBulkEntry;
                    });
                  },
                  icon: const Icon(Icons.add_box),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        _showBulkEntry ? darkBlueColor : Colors.grey.shade200,
                    foregroundColor:
                        _showBulkEntry ? Colors.white : darkBlueColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Drink type selector
          if (_showDrinkTypeSelector) _buildDrinkTypeSelector(),

          // Custom amount input
          if (_showCustomInput) _buildCustomInput(hydrationProvider),

          // Bulk entry
          if (_showBulkEntry) _buildBulkEntry(hydrationProvider),

          const SizedBox(height: 20),

          // Smart suggestion buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Quick Add',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: darkBlueColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Amount buttons with smart suggestions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountButton(
                        context,
                        _smartSuggestions[0],
                        hydrationProvider,
                        const Color(0xFFE9D9FF),
                        darkBlueColor,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildAmountButton(
                        context,
                        _smartSuggestions.length > 1
                            ? _smartSuggestions[1]
                            : 250,
                        hydrationProvider,
                        const Color(0xFFD4FFFB),
                        darkBlueColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountButton(
                        context,
                        _smartSuggestions.length > 2
                            ? _smartSuggestions[2]
                            : 400,
                        hydrationProvider,
                        const Color(0xFFDAFFC7),
                        darkBlueColor,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildAmountButton(
                        context,
                        _smartSuggestions.length > 3
                            ? _smartSuggestions[3]
                            : 100,
                        hydrationProvider,
                        const Color(0xFFFFF8BB),
                        darkBlueColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Today's entries with edit/delete options
          _buildTodaysEntries(hydrationProvider),

          const SizedBox(height: 100), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildTimeHeader() {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 7, 0); // 07:00 AM
    final endTime = DateTime(now.year, now.month, now.day, 23, 0); // 11:00 PM
    final nextReminder = _getNextReminderTime();
    final timeUntilReminder = nextReminder.difference(now);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} AM',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSubtitle,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.unselectedBorder,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${timeUntilReminder.inMinutes}min',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
              ),
            ),
          ),
          Text(
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')} PM',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSubtitle,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getNextReminderTime() {
    final now = DateTime.now();
    // Calculate next reminder time (simplified - every 2 hours)
    final nextHour = ((now.hour ~/ 2) + 1) * 2;
    if (nextHour < 24) {
      return DateTime(now.year, now.month, now.day, nextHour, 0);
    } else {
      return DateTime(now.year, now.month, now.day + 1, 8, 0); // Next day 8 AM
    }
  }

  Widget _buildCircularProgressSection(HydrationProvider hydrationProvider) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _circularCardController,
        onPageChanged: (index) {
          setState(() {
            _currentCardIndex = index;
          });
        },
        itemCount: 3, // Three swipeable cards
        itemBuilder: (context, index) {
          return _buildCircularProgressCard(hydrationProvider, index);
        },
      ),
    );
  }

  Widget _buildCircularProgressCard(HydrationProvider hydrationProvider, int cardIndex) {
    final currentIntake = hydrationProvider.currentIntake;
    final dailyGoal = hydrationProvider.dailyGoal;
    final progress = hydrationProvider.intakePercentage;
    final remainingIntake = hydrationProvider.remainingIntake;
    
    // Calculate next reminder time and remaining ml
    final nextReminder = _getNextReminderTime();
    final timeString = '${nextReminder.hour.toString().padLeft(2, '0')}:${nextReminder.minute.toString().padLeft(2, '0')} ${nextReminder.hour >= 12 ? 'PM' : 'AM'}';
    
    // Different content for each card
    String mainText;
    String subtitleText;
    String bottomText;
    
    switch (cardIndex) {
      case 0:
        mainText = '${(currentIntake / 1000).toStringAsFixed(2)} L';
        subtitleText = 'drank so far';
        bottomText = 'from a total of ${(dailyGoal / 1000).toStringAsFixed(0)} L';
        break;
      case 1:
        mainText = '${(remainingIntake / 1000).toStringAsFixed(2)} L';
        subtitleText = 'remaining';
        bottomText = 'to reach your daily goal';
        break;
      case 2:
        mainText = '${(progress * 100).toInt()}%';
        subtitleText = 'completed';
        bottomText = 'of today\'s hydration goal';
        break;
      default:
        mainText = '${(currentIntake / 1000).toStringAsFixed(2)} L';
        subtitleText = 'drank so far';
        bottomText = 'from a total of ${(dailyGoal / 1000).toStringAsFixed(0)} L';
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main circular progress
          SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: CircularProgressPainter(
                progress: progress,
                strokeWidth: 20,
                backgroundColor: AppColors.unselectedBorder,
                progressColor: AppColors.waterFull,
                innerRingColor: Colors.green,
              ),
            ),
          ),
          
          // Profile icon on the left side
          Positioned(
            left: 20,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.unselectedBorder, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                hydrationProvider.selectedAvatar == AvatarOption.male 
                    ? Icons.person 
                    : Icons.person_outline,
                size: 20,
                color: AppColors.textSubtitle,
              ),
            ),
          ),
          
          // Central content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mainText,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitleText,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHeadline,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                bottomText,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSubtitle,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${remainingIntake} ml left before $timeString',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSubtitle,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          
          // Page indicator dots
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCardIndex == index 
                        ? AppColors.textHeadline 
                        : AppColors.textSubtitle.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for building UI components
  Widget _buildDrinkTypeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Drink Type',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                DrinkType.values.map((type) {
                  final isSelected = type == _selectedDrinkType;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDrinkType = type;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF323062) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF323062)
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDrinkTypeIcon(type),
                            size: 16,
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.displayName,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(type.waterContent * 100).toInt()}%',
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white70
                                      : Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInput(HydrationProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Amount',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'Amount (ml)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _addCustomHydration(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF323062),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkEntry(HydrationProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bulk Entry - Add Multiple',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showBulkEntryDialog(provider, 250, 3),
                  child: const Text('3x 250ml'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showBulkEntryDialog(provider, 500, 2),
                  child: const Text('2x 500ml'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showBulkEntryDialog(provider, 100, 5),
                  child: const Text('5x 100ml'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysEntries(HydrationProvider provider) {
    final todaysEntries = provider.todaysEntries;

    if (todaysEntries.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No entries today yet',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Entries",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF323062),
            ),
          ),
          const SizedBox(height: 12),
          ...todaysEntries
              .take(5)
              .map((entry) => _buildEntryItem(entry, provider)),
          if (todaysEntries.length > 5)
            TextButton(
              onPressed: () {
                // Navigate to full history
              },
              child: Text('View all ${todaysEntries.length} entries'),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryItem(HydrationData entry, HydrationProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            _getDrinkTypeIcon(entry.type),
            color: const Color(0xFF323062),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.amount}ml ${entry.type.displayName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')} • ${entry.waterContent}ml water',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (entry.notes?.isNotEmpty == true)
                  Text(
                    entry.notes!,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editEntry(entry, provider),
            icon: const Icon(Icons.edit, size: 18),
            style: IconButton.styleFrom(foregroundColor: Colors.blue),
          ),
          IconButton(
            onPressed: () => _deleteEntry(entry, provider),
            icon: const Icon(Icons.delete, size: 18),
            style: IconButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountButton(
    BuildContext context,
    int amount,
    HydrationProvider provider,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () => _addHydration(provider, amount),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16),
          minimumSize: const Size.fromHeight(80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$amount ml',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Nunito',
              ),
            ),
            if (_selectedDrinkType != DrinkType.water)
              Text(
                '${(_selectedDrinkType.waterContent * amount).round()}ml water',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withValues(alpha: 0.7),
                  fontFamily: 'Nunito',
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getDrinkTypeIcon(DrinkType type) {
    switch (type) {
      case DrinkType.water:
        return Icons.water_drop;
      case DrinkType.tea:
        return Icons.local_cafe;
      case DrinkType.coffee:
        return Icons.coffee;
      case DrinkType.juice:
        return Icons.local_drink;
      case DrinkType.soda:
        return Icons.local_bar;
      case DrinkType.sports:
        return Icons.sports;
      case DrinkType.other:
        return Icons.more_horiz;
    }
  }

  // Enhanced hydration functionality methods
  Future<void> _addHydration(HydrationProvider provider, int amount) async {
    try {
      await provider.addHydration(
        amount,
        type: _selectedDrinkType,
        context: context,
      );

      // Add to undo stack
      final entry = HydrationData.create(
        amount: amount,
        type: _selectedDrinkType,
      );
      _undoStack.add(entry);

      // Start undo timer
      _undoTimer?.cancel();
      _undoAnimationController.forward();

      _undoTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          _undoAnimationController.reverse();
          _undoStack.clear();
        }
      });

      _loadSmartSuggestions();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added $amount ml of ${_selectedDrinkType.displayName} (${(_selectedDrinkType.waterContent * amount).round()}ml water)',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF323062),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding hydration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addCustomHydration(HydrationProvider provider) async {
    final amountText = _customAmountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await provider.addHydration(
        amount,
        type: _selectedDrinkType,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        context: context,
      );

      _customAmountController.clear();
      _notesController.clear();
      _loadSmartSuggestions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added $amount ml of ${_selectedDrinkType.displayName}',
            ),
            backgroundColor: const Color(0xFF323062),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding hydration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBulkEntryDialog(HydrationProvider provider, int amount, int count) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add $count entries of ${amount}ml?'),
            content: Text(
              'This will add $count separate entries of ${amount}ml ${_selectedDrinkType.displayName} each.\n\n'
              'Total: ${amount * count}ml (${(_selectedDrinkType.waterContent * amount * count).round()}ml water)',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _addBulkEntries(provider, amount, count);
                },
                child: const Text('Add All'),
              ),
            ],
          ),
    );
  }

  Future<void> _addBulkEntries(
    HydrationProvider provider,
    int amount,
    int count,
  ) async {
    try {
      for (var i = 0; i < count; i++) {
        await provider.addHydration(
          amount,
          type: _selectedDrinkType,
          notes: 'Bulk entry ${i + 1}/$count',
        );
        // Small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _loadSmartSuggestions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $count entries of ${amount}ml each'),
            backgroundColor: const Color(0xFF323062),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding bulk entries: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _undoLastEntry() async {
    if (_undoStack.isEmpty) return;

    final provider = Provider.of<HydrationProvider>(context, listen: false);
    final lastEntry = _undoStack.removeLast();

    try {
      // Find the most recent entry that matches our undo entry
      final todaysEntries = provider.todaysEntries;
      if (todaysEntries.isNotEmpty) {
        final entryToDelete = todaysEntries.firstWhere(
          (entry) =>
              entry.amount == lastEntry.amount && entry.type == lastEntry.type,
          orElse: () => todaysEntries.first,
        );

        await provider.deleteHydrationEntry(entryToDelete.id);
      }

      if (_undoStack.isEmpty) {
        _undoAnimationController.reverse();
      }

      _loadSmartSuggestions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry undone'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error undoing entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editEntry(HydrationData entry, HydrationProvider provider) {
    final amountController = TextEditingController(
      text: entry.amount.toString(),
    );
    final notesController = TextEditingController(text: entry.notes ?? '');
    var selectedType = entry.type;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Entry'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Amount (ml)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<DrinkType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Drink Type',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            DrinkType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(_getDrinkTypeIcon(type), size: 20),
                                    const SizedBox(width: 8),
                                    Text(type.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final amount = int.tryParse(amountController.text);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          await provider.editHydrationEntry(
                            entry.id,
                            amount: amount,
                            type: selectedType,
                            notes:
                                notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                          );

                          Navigator.pop(context);
                          _loadSmartSuggestions();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Entry updated successfully'),
                              backgroundColor: Color(0xFF323062),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating entry: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _deleteEntry(HydrationData entry, HydrationProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Entry'),
            content: Text(
              'Are you sure you want to delete this entry?\n\n'
              '${entry.amount}ml ${entry.type.displayName}\n'
              '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await provider.deleteHydrationEntry(entry.id);
                    Navigator.pop(context);
                    _loadSmartSuggestions();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entry deleted successfully'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting entry: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class _AddHydrationScreenState extends State<AddHydrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AddHydrationScreenContent(),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          // Handle navigation
        },
      ),
    );
  }
}

/// Custom painter for the circular progress indicator
class CircularProgressPainter extends CustomPainter {
  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    required this.innerRingColor,
  });

  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Color innerRingColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Inner green ring
    final innerRingPaint = Paint()
      ..color = innerRingColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius - strokeWidth / 2 - 5, innerRingPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.innerRingColor != innerRingColor;
  }
}