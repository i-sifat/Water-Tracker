import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/core/design_system/app_colors.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/widgets/onboarding_screen_wrapper.dart';
import 'package:watertracker/features/premium/screens/donation_info_screen.dart';

class PremiumUnlockScreen extends StatefulWidget {
  const PremiumUnlockScreen({super.key});

  @override
  State<PremiumUnlockScreen> createState() => _PremiumUnlockScreenState();
}

class _PremiumUnlockScreenState extends State<PremiumUnlockScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _iconAnimation;
  late Animation<double> _listAnimation;

  int _selectedPlan = 0; // 0: Yearly, 1: Monthly, 2: Lifetime

  final List<Map<String, dynamic>> _premiumFeatures = [
    {'title': '100% Ad-Free', 'icon': Icons.block},
    {'title': 'Create custom drinks', 'icon': Icons.local_drink},
    {'title': 'Advanced Statistics', 'icon': Icons.analytics},
    {'title': 'Unlimited History', 'icon': Icons.history},
    {'title': 'Health App Sync', 'icon': Icons.health_and_safety},
    {'title': 'Smart Reminders', 'icon': Icons.notifications_active},
    {'title': 'Priority Support', 'icon': Icons.support_agent},
    {'title': 'Data Export (CSV)', 'icon': Icons.file_download},
  ];

  final List<Map<String, dynamic>> _pricingPlans = [
    {
      'title': 'Yearly',
      'price': 'BDT 599.00',
      'subtitle': 'Only BDT 49.92/Month',
      'badge': 'Save 50%',
      'isRecommended': true,
    },
    {
      'title': 'Monthly',
      'price': 'BDT 99.00',
      'subtitle': 'Per month',
      'badge': null,
      'isRecommended': false,
    },
    {
      'title': 'Lifetime',
      'price': 'BDT 999.00',
      'subtitle': 'One-time payment',
      'badge': 'Best Value',
      'isRecommended': false,
    },
  ];

  @override
  void initState() {
    super.initState();

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _listAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animations
    _iconAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _listAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        return OnboardingScreenWrapper(
          showProgress: false,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          onContinue: () => _handleContinue(onboardingProvider),
          // Add skip button for premium screen
          showSkipButton: true,
          skipButtonText: 'Skip for now',
          onSkip: () => _handleSkip(onboardingProvider),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Animated mascot and decorative elements
                _buildAnimatedHeader(),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Unlock everything!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Premium features list
                _buildFeaturesList(),

                const SizedBox(height: 32),

                // Pricing plans
                _buildPricingPlans(),

                const SizedBox(height: 24),

                // Footer links
                _buildFooterLinks(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconAnimation.value,
          child: SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main mascot (water drop with crown)
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.waterFull,
                    shape: BoxShape.circle,
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      // Happy face
                      Positioned(
                        top: 20,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.white),
                            SizedBox(width: 8),
                            Icon(Icons.circle, size: 8, color: Colors.white),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        child: Icon(
                          Icons.sentiment_satisfied,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Crown
                const Positioned(
                  top: 0,
                  child: Icon(
                    Icons.workspace_premium,
                    size: 32,
                    color: Colors.amber,
                  ),
                ),

                // Decorative elements around the mascot
                Positioned(
                  left: 20,
                  top: 30,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Container(
                      width: 20,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const Positioned(
                  right: 20,
                  top: 20,
                  child: Icon(Icons.favorite, size: 24, color: Colors.red),
                ),

                const Positioned(
                  left: 10,
                  bottom: 10,
                  child: Icon(Icons.star, size: 20, color: Colors.amber),
                ),

                Positioned(
                  right: 10,
                  bottom: 20,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: Colors.green),
                  ),
                ),

                const Positioned(
                  right: 30,
                  bottom: 0,
                  child: Icon(
                    Icons.trending_up,
                    size: 20,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList() {
    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _listAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _listAnimation.value)),
            child: Column(
              children:
                  _premiumFeatures.asMap().entries.map((entry) {
                    final index = entry.key;
                    final feature = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              feature['title'] as String,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textHeadline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      children:
          _pricingPlans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            final isSelected = _selectedPlan == index;
            final isRecommended = plan['isRecommended'] as bool;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlan = index;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRecommended ? AppColors.waterFull : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.waterFull
                              : (isRecommended
                                  ? AppColors.waterFull
                                  : AppColors.unselectedBorder),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow:
                        isRecommended
                            ? [
                              BoxShadow(
                                color: AppColors.waterFull.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Row(
                    children: [
                      // Selection indicator
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected
                                  ? AppColors.waterFull
                                  : (isRecommended
                                      ? Colors.white
                                      : Colors.transparent),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.waterFull
                                    : (isRecommended
                                        ? Colors.white
                                        : AppColors.unselectedBorder),
                            width: 2,
                          ),
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  size: 12,
                                  color:
                                      isRecommended
                                          ? AppColors.waterFull
                                          : Colors.white,
                                )
                                : null,
                      ),

                      const SizedBox(width: 16),

                      // Plan details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${plan['title']} ${plan['price']}',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isRecommended
                                            ? Colors.white
                                            : AppColors.textHeadline,
                                  ),
                                ),
                                if (plan['badge'] != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      plan['badge'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan['subtitle'] as String,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color:
                                    isRecommended
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : AppColors.textSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFooterLink('Restore purchase'),
        _buildFooterLink('Terms of Use'),
        _buildFooterLink('Privacy'),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        // Handle footer link taps
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$text tapped'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSubtitle,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _handleContinue(OnboardingProvider provider) async {
    // Navigate to donation info screen
    Navigator.of(context).pushNamed(DonationInfoScreen.routeName);
  }

  void _handleSkip(OnboardingProvider provider) {
    // Skip premium and continue with onboarding
    provider.navigateNext();
  }
}
