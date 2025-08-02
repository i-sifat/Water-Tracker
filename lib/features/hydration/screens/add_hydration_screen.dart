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

  // Swipe functionality
  late AnimationController _swipeAnimationController;
  late Animation<Offset> _swipeAnimation;
  double _swipeOffset = 0.0;
  bool _isSwipeActive = false;
  
  // Page states
  int _currentPage = 1; // 0: History (up), 1: Main (center), 2: Goal Breakdown (down)

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
    
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _loadSmartSuggestions();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _notesController.dispose();
    _undoAnimationController.dispose();
    _circularCardController.dispose();
    _swipeAnimationController.dispose();
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

  void _handleVerticalDrag(DragUpdateDetails details) {
    if (_isSwipeActive) return;
    
    setState(() {
      _swipeOffset += details.delta.dy;
      _swipeOffset = _swipeOffset.clamp(-200.0, 200.0);
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_isSwipeActive) return;
    
    final velocity = details.velocity.pixelsPerSecond.dy;
    final threshold = 80.0;
    
    int targetPage = _currentPage;
    
    if (_swipeOffset < -threshold || velocity < -500) {
      // Swipe up - go to history page
      targetPage = 0;
    } else if (_swipeOffset > threshold || velocity > 500) {
      // Swipe down - go to goal breakdown page
      targetPage = 2;
    }
    
    _animateToPage(targetPage);
  }

  void _animateToPage(int page) {
    if (_isSwipeActive || page == _currentPage) {
      _resetSwipeOffset();
      return;
    }
    
    setState(() {
      _isSwipeActive = true;
      _currentPage = page;
    });
    
    Offset targetOffset;
    switch (page) {
      case 0: // History page
        targetOffset = const Offset(0, 1);
        break;
      case 2: // Goal breakdown page
        targetOffset = const Offset(0, -1);
        break;
      default: // Main page
        targetOffset = Offset.zero;
    }
    
    _swipeAnimation = Tween<Offset>(
      begin: Offset(0, _swipeOffset / 200.0),
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _swipeAnimationController.forward(from: 0).then((_) {
      setState(() {
        _isSwipeActive = false;
        _swipeOffset = 0.0;
      });
    });
  }

  void _resetSwipeOffset() {
    _swipeAnimation = Tween<Offset>(
      begin: Offset(0, _swipeOffset / 200.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _swipeAnimationController.forward(from: 0).then((_) {
      setState(() {
        _swipeOffset = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hydrationProvider = Provider.of<HydrationProvider>(context);
    
    return GestureDetector(
      onPanUpdate: _handleVerticalDrag,
      onPanEnd: _handleVerticalDragEnd,
      child: AnimatedBuilder(
        animation: _swipeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              _isSwipeActive 
                ? _swipeAnimation.value.dy * MediaQuery.of(context).size.height
                : _swipeOffset,
            ),
            child: Stack(
              children: [
                // History Page (Top)
                if (_currentPage == 0 || _swipeOffset < -50)
                  Positioned.fill(
                    child: _buildHistoryPage(hydrationProvider),
                  ),
                
                // Goal Breakdown Page (Bottom)
                if (_currentPage == 2 || _swipeOffset > 50)
                  Positioned.fill(
                    child: _buildGoalBreakdownPage(hydrationProvider),
                  ),
                
                // Main Page (Center)
                if (_currentPage == 1 || (_swipeOffset.abs() < 50 && !_isSwipeActive))
                  Positioned.fill(
                    child: _buildMainPage(hydrationProvider),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainPage(HydrationProvider hydrationProvider) {
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

          const SizedBox(height: 100), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildHistoryPage(HydrationProvider hydrationProvider) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _animateToPage(1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textHeadline,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Today',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: AppColors.textHeadline,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Today's entries list
            Expanded(
              child: _buildTodaysEntriesList(hydrationProvider),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.waterFull,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.waterFull.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalBreakdownPage(HydrationProvider hydrationProvider) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _animateToPage(1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textHeadline,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Today',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.textHeadline,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Goal breakdown content
            Expanded(
              child: _buildGoalBreakdownContent(hydrationProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysEntriesList(HydrationProvider hydrationProvider) {
    final todaysEntries = hydrationProvider.todaysEntries;

    if (todaysEntries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 64,
              color: AppColors.textSubtitle,
            ),
            SizedBox(height: 16),
            Text(
              'No entries today yet',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                color: AppColors.textSubtitle,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: todaysEntries.length,
      itemBuilder: (context, index) {
        final entry = todaysEntries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Drink type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.waterFull.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDrinkTypeIcon(entry.type),
                  color: AppColors.waterFull,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Entry details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(entry.amount / 1000).toStringAsFixed(1)} L',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    if (entry.notes?.isNotEmpty == true)
                      Text(
                        entry.notes!,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: AppColors.textSubtitle,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Time
              Text(
                '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')} ${entry.timestamp.hour >= 12 ? 'PM' : 'AM'}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.textSubtitle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalBreakdownContent(HydrationProvider hydrationProvider) {
    final currentIntake = hydrationProvider.currentIntake;
    final dailyGoal = hydrationProvider.dailyGoal;
    
    // Calculate breakdown values
    final manualVolume = currentIntake; // For now, all intake is manual
    final lifestyleBonus = 0; // Placeholder
    final weatherBonus = 0; // Placeholder
    final totalGoal = manualVolume + lifestyleBonus + weatherBonus;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Manual volume
          _buildBreakdownItem(
            icon: Icons.edit,
            iconColor: AppColors.textSubtitle,
            title: 'Manual volume',
            subtitle: 'Tap to calculate',
            value: '$manualVolume ml',
            onTap: () {
              // Handle manual volume calculation
            },
          ),
          
          const SizedBox(height: 20),
          
          // Lifestyle
          _buildBreakdownItem(
            icon: Icons.access_time,
            iconColor: AppColors.waterFull,
            title: 'Lifestyle',
            subtitle: 'Inactive',
            value: '$lifestyleBonus ml',
            onTap: () {
              // Handle lifestyle settings
            },
          ),
          
          const SizedBox(height: 20),
          
          // Weather
          _buildBreakdownItem(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            title: 'Weather',
            subtitle: 'Normal',
            value: '$weatherBonus ml',
            onTap: () {
              // Handle weather settings
            },
          ),
          
          const Spacer(),
          
          // Total
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalGoal ml',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 60,
                      color: AppColors.textHeadline,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            
            Row(
              children: [
                const Icon(
                  Icons.edit,
                  color: AppColors.textSubtitle,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                  ),
                ),
              ],
            ),
          ],
        ),
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