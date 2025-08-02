import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/buttons/continue_button.dart';
import 'package:watertracker/core/widgets/common/exit_confirmation_modal.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';

class DrinkGoalSelectionScreen extends StatefulWidget {
  const DrinkGoalSelectionScreen({super.key});

  @override
  State<DrinkGoalSelectionScreen> createState() => _DrinkGoalSelectionScreenState();
}

class _DrinkGoalSelectionScreenState extends State<DrinkGoalSelectionScreen> {
  double? _selectedGoal;
  bool _useMetric = true; // true for liters, false for fl oz

  final List<double> _metricGoals = [1.0, 1.5, 2.0, 2.5, 3.0];
  final List<double> _imperialGoals = [34.0, 51.0, 68.0, 85.0, 102.0]; // fl oz equivalents

  List<double> get _currentGoals => _useMetric ? _metricGoals : _imperialGoals;
  String get _currentUnit => _useMetric ? 'L' : 'FL OZ';

  void _toggleUnit() {
    setState(() {
      _useMetric = !_useMetric;
      _selectedGoal = null; // Reset selection when unit changes
    });
  }

  void _selectGoal(double goal) {
    setState(() {
      _selectedGoal = goal;
    });
  }

  void _onCalculatePressed(OnboardingProvider provider) {
    // Navigate to the existing onboarding flow starting from age selection
    provider.goToStep(2); // Age selection screen
  }

  void _onContinuePressed(OnboardingProvider provider) async {
    if (_selectedGoal != null) {
      // Save the selected goal to user profile
      // Convert to liters if imperial was selected
      double goalInLiters = _useMetric ? _selectedGoal! : _selectedGoal! / 33.814;
      
      // Update the user profile with the selected goal
      provider.updateDrinkGoal(goalInLiters);
      
      // Complete onboarding and go to home screen
      await provider.completeOnboarding();
      
      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            // Show exit confirmation modal
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => const ExitConfirmationModal(),
            );
            return shouldExit ?? false;
          },
                     child: OnboardingScreenWrapper(
             showBackButton: false,
             showProgress: false,
             backgroundColor: AppColors.onboardingBackground,
             padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
             onContinue: _selectedGoal != null ? () => _onContinuePressed(onboardingProvider) : null,
             canContinue: _selectedGoal != null,
             title: null, // Hide the "Assessment" title
             subtitle: null,
                         child: SingleChildScrollView(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   const SizedBox(height: 80),
                   
                   // Title
                   const Text(
                     'DRINK GOAL',
                     style: AppTypography.headline,
                   ),
                   
                   const SizedBox(height: 40),
                   
                   // Calculate option (tappable) - centered
                   GestureDetector(
                     onTap: () => _onCalculatePressed(onboardingProvider),
                     child: Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(
                         color: AppColors.lightBlue.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(
                           color: AppColors.lightBlue.withValues(alpha: 0.3),
                           width: 1,
                         ),
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           Container(
                             padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                               color: AppColors.lightBlue,
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: const Icon(
                               Icons.calculate,
                               color: Colors.white,
                               size: 24,
                             ),
                           ),
                           const SizedBox(height: 16),
                                                       Text(
                              'Calculate',
                              style: AppTypography.subtitle.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Setup your personal water requirement',
                              style: AppTypography.subtitle.copyWith(
                                fontSize: 16,
                                color: AppColors.textSubtitle,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'in four easy steps',
                              style: AppTypography.subtitle.copyWith(
                                fontSize: 16,
                                color: AppColors.textSubtitle,
                              ),
                              textAlign: TextAlign.center,
                            ),
                         ],
                       ),
                     ),
                   ),
                   
                   const SizedBox(height: 32),
                   
                   // Or divider
                   Row(
                     children: [
                       Expanded(
                         child: Container(
                           height: 1,
                           color: AppColors.textSubtitle.withValues(alpha: 0.3),
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 16),
                         child: Text(
                           'or simply pick a goal',
                           style: AppTypography.subtitle.copyWith(
                             fontSize: 16,
                             fontWeight: FontWeight.w500,
                             color: AppColors.textSubtitle,
                           ),
                         ),
                       ),
                       Expanded(
                         child: Container(
                           height: 1,
                           color: AppColors.textSubtitle.withValues(alpha: 0.3),
                         ),
                       ),
                     ],
                   ),
                  
                  const SizedBox(height: 24),
                  
                  // Goal selection grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _currentGoals.length + 1, // +1 for custom option
                    itemBuilder: (context, index) {
                      if (index == _currentGoals.length) {
                        // Custom option
                        return _buildGoalCard(
                          '...',
                          null,
                          isSelected: false,
                          onTap: () {
                            // Show custom input dialog
                            _showCustomGoalDialog(context);
                          },
                        );
                      }
                      
                      final goal = _currentGoals[index];
                      final isSelected = _selectedGoal == goal;
                      
                      return _buildGoalCard(
                        '${goal.toStringAsFixed(goal.truncateToDouble() == goal ? 0 : 1)}',
                        goal,
                        isSelected: isSelected,
                        onTap: () => _selectGoal(goal),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Unit toggle button - Material Design style
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.checkBoxCircle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textSubtitle.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // L button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (!_useMetric) {
                                setState(() {
                                  _useMetric = true;
                                  _selectedGoal = null;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: _useMetric ? AppColors.lightBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: _useMetric ? [
                                  BoxShadow(
                                    color: AppColors.lightBlue.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                                                             child: Text(
                                 'L',
                                 style: AppTypography.buttonText.copyWith(
                                   fontWeight: FontWeight.w700,
                                   color: _useMetric ? Colors.white : AppColors.textHeadline,
                                 ),
                               ),
                            ),
                          ),
                        ),
                        // FL OZ button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_useMetric) {
                                setState(() {
                                  _useMetric = false;
                                  _selectedGoal = null;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: !_useMetric ? AppColors.lightBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: !_useMetric ? [
                                  BoxShadow(
                                    color: AppColors.lightBlue.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                                                             child: Text(
                                 'FL OZ',
                                 style: AppTypography.buttonText.copyWith(
                                   fontWeight: FontWeight.w700,
                                   color: !_useMetric ? Colors.white : AppColors.textHeadline,
                                 ),
                               ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(String text, double? goal, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.lightBlue : AppColors.textSubtitle.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.lightBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
                 child: Center(
           child: Text(
             text,
             style: AppTypography.buttonText.copyWith(
               fontWeight: FontWeight.w700,
               color: isSelected ? Colors.white : AppColors.textHeadline,
             ),
           ),
         ),
      ),
    );
  }

  void _showCustomGoalDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Custom Goal',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            color: AppColors.textHeadline,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your custom water goal in $_currentUnit',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textSubtitle,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText: _currentUnit,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSubtitle),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                setState(() {
                  _selectedGoal = value;
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
} 