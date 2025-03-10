import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/widgets/continue_button.dart';
import 'package:watertracker/core/widgets/large_selection_box.dart';
import 'package:watertracker/core/widgets/prefer_not_to_answer_button.dart';
import 'package:watertracker/core/widgets/selection_box.dart';
import 'package:watertracker/core/widgets/custom_ruler_picker.dart';
import 'package:watertracker/features/onboarding/providers/onboarding_provider.dart';
import 'package:watertracker/features/onboarding/screens/notification_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = [
      // const GoalSelectionScreenContent(),
      const GenderSelectionScreenContent(),
      const AgeSelectionScreenContent(),
      const WeightSelectionScreenContent(),
      const FitnessLevelScreenContent(),
      const VegetablesFruitsScreenContent(),
      const SugaryBeveragesScreenContent(),
      const PregnancyScreenContent(),
      const WeatherSelectionScreenContent(),
      const NotificationSetupScreenContent(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_pageController.page! < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.assessmentText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text('Assessment', style: AppTypography.subtitle),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer<OnboardingProvider>(
              builder: (context, provider, _) {
                return Text(
                  provider.pageCounter,
                  style: AppTypography.subtitle,
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                context.read<OnboardingProvider>().setPage(index + 1);
              },
              children: _pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: ContinueButton(onPressed: _handleContinue),
          ),
        ],
      ),
    );
  }
}

// Gender Selection Screen Content
class GenderSelectionScreenContent extends StatefulWidget {
  const GenderSelectionScreenContent({super.key});

  @override
  State<GenderSelectionScreenContent> createState() =>
      _GenderSelectionScreenContentState();
}

class _GenderSelectionScreenContentState
    extends State<GenderSelectionScreenContent> {
  String? _selectedGender;

  final List<Map<String, String>> _genderOptions = [
    {
      'value': 'male',
      'title': 'I am Male',
      'subtitle': 'Select if you identify as male',
      'icon':
          'assets/images/icons/onboarding_elements/onboarding_maleavater_icon.svg',
    },
    {
      'value': 'female',
      'title': 'I am Female',
      'subtitle': 'Select if you identify as female',
      'icon':
          'assets/images/icons/onboarding_elements/onboarding_femaleavater_icon.svg',
    },
  ];

  Future<void> _saveGender() async {
    if (_selectedGender != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_gender', _selectedGender!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select your Gender', style: AppTypography.headline),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              itemCount: _genderOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final option = _genderOptions[index];
                return LargeSelectionBox(
                  title: option['title']!,
                  subtitle: option['subtitle']!,
                  icon: SvgPicture.asset(
                    option['icon']!,
                    width: 32,
                    height: 32,
                  ),
                  isSelected: _selectedGender == option['value'],
                  onTap: () {
                    setState(() {
                      _selectedGender = option['value'];
                    });
                    _saveGender();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          PreferNotToAnswerButton(
            onPressed: () {
              setState(() => _selectedGender = 'not_specified');
              _saveGender();
            },
          ),
        ],
      ),
    );
  }
}

// Age Selection Screen Content
class AgeSelectionScreenContent extends StatefulWidget {
  const AgeSelectionScreenContent({super.key});

  @override
  State<AgeSelectionScreenContent> createState() =>
      _AgeSelectionScreenContentState();
}

class _AgeSelectionScreenContentState extends State<AgeSelectionScreenContent> {
  late final FixedExtentScrollController _scrollController;
  late final List<int> _ages;
  int _selectedAge = 45;

  final double _maxFontSize = 64;
  final double _minFontSize = 32;
  final double _itemExtent = 80;

  @override
  void initState() {
    super.initState();
    _ages = List.generate(100, (index) => index + 1);
    _scrollController = FixedExtentScrollController(
      initialItem: _ages.indexOf(_selectedAge),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_age', _selectedAge);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 40, 24, 60),
          child: Text("What's your Age?", style: AppTypography.headline),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: _itemExtent,
                margin: const EdgeInsets.symmetric(horizontal: 120),
                decoration: BoxDecoration(
                  color: AppColors.selectedBorder,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: _itemExtent,
                perspective: 0.001,
                diameterRatio: 1.3,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() => _selectedAge = _ages[index]);
                  _saveAge();
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _ages.length,
                  builder: (context, index) {
                    final age = _ages[index];
                    final isSelected = age == _selectedAge;
                    final fontSize = isSelected ? _maxFontSize : _minFontSize;

                    return Center(
                      child: Text(
                        age.toString(),
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isSelected
                                  ? Colors.white
                                  : AppColors.assessmentText,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Weight Selection Screen Content
class WeightSelectionScreenContent extends StatefulWidget {
  const WeightSelectionScreenContent({super.key});

  @override
  State<WeightSelectionScreenContent> createState() =>
      _WeightSelectionScreenContentState();
}

class _WeightSelectionScreenContentState
    extends State<WeightSelectionScreenContent> {
  bool _isKg = true;
  double _weight = 65.0;
  final double _minWeightKg = 1.0;
  final double _maxWeightKg = 150.0;

  @override
  void initState() {
    super.initState();
    _loadSavedWeight();
  }

  Future<void> _loadSavedWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnit = prefs.getBool('weight_unit_is_kg') ?? true;
    final savedWeight = prefs.getDouble('user_weight') ?? 65.0;

    setState(() {
      _isKg = savedUnit;
      _weight = _clampWeight(savedWeight, savedUnit);
    });
  }

  double _convertKgToLbs(double kg) => kg * 2.20462;
  double _convertLbsToKg(double lbs) => lbs / 2.20462;

  double _clampWeight(double value, bool isKg) {
    final min = isKg ? _minWeightKg : _convertKgToLbs(_minWeightKg);
    final max = isKg ? _maxWeightKg : _convertKgToLbs(_maxWeightKg);
    return value.clamp(min, max);
  }

  Future<void> _saveWeight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_weight', _weight);
    await prefs.setBool('weight_unit_is_kg', _isKg);
  }

  @override
  Widget build(BuildContext context) {
    final minValue = _isKg ? _minWeightKg : _convertKgToLbs(_minWeightKg);
    final maxValue = _isKg ? _maxWeightKg : _convertKgToLbs(_maxWeightKg);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Text(
            "What's your current\nweight right now?",
            style: AppTypography.headline,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUnitButton('kg', true),
              const SizedBox(width: 8),
              _buildUnitButton('lbs', false),
            ],
          ),
        ),
        const SizedBox(height: 60),
        Expanded(
          child: CustomRulerPicker(
            value: _weight,
            minValue: minValue,
            maxValue: maxValue,
            isKg: _isKg,
            onValueChanged: (value) {
              setState(() => _weight = value);
              _saveWeight();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUnitButton(String unit, bool isKg) {
    final bool isSelected = _isKg == isKg;

    return GestureDetector(
      onTap: () {
        if (_isKg != isKg) {
          setState(() {
            final newWeight =
                _isKg ? _convertKgToLbs(_weight) : _convertLbsToKg(_weight);
            _weight = _clampWeight(newWeight, isKg);
            _isKg = isKg;
          });
          _saveWeight();
        }
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedBorder : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.assessmentText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Exercise Frequency Screen Content
class FitnessLevelScreenContent extends StatefulWidget {
  const FitnessLevelScreenContent({super.key});

  @override
  State<FitnessLevelScreenContent> createState() =>
      _FitnessLevelScreenContentState();
}

class _FitnessLevelScreenContentState extends State<FitnessLevelScreenContent> {
  int _selectedLevel = 0;

  Future<void> _saveFitnessLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fitness_level', _selectedLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          "Fitness Level",
          style: AppTypography.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'How frequent do you take exercise?',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.pageCounter,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 100),
        SizedBox(
          height: 300,
          width: double.infinity,
          child: SvgPicture.asset(
            'assets/images/icons/onboarding_elements/trainning_icon.svg',
          ),
        ),
        const Spacer(),
        _buildSlider(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSlider() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0FF),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => Container(width: 2, height: 24, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          top: -8,
          left:
              24 +
              (_selectedLevel * ((MediaQuery.of(context).size.width - 48) / 3)),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              final width = MediaQuery.of(context).size.width - 48;
              final segmentWidth = width / 3;
              final dx = details.globalPosition.dx - 24;
              final newLevel = (dx / segmentWidth).round().clamp(0, 2);
              if (newLevel != _selectedLevel) {
                setState(() {
                  _selectedLevel = newLevel;
                });
                _saveFitnessLevel();
              }
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.chevron_right, color: Colors.white, size: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Vegetable Intake Screen Content
class VegetablesFruitsScreenContent extends StatefulWidget {
  const VegetablesFruitsScreenContent({super.key});

  @override
  State<VegetablesFruitsScreenContent> createState() =>
      _VegetablesFruitsScreenContentState();
}

class _VegetablesFruitsScreenContentState
    extends State<VegetablesFruitsScreenContent> {
  String _selectedFrequency = '';

  final List<Map<String, String>> _frequencies = [
    {'title': 'Rarely', 'subtitle': 'Few times a week', 'icon': '🥗'},
    {'title': 'Often', 'subtitle': 'Several per day', 'icon': '🥬'},
    {'title': 'Regularly', 'subtitle': 'Every day', 'icon': '🥦'},
  ];

  Future<void> _saveFrequency() async {
    if (_selectedFrequency.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vegetable_frequency', _selectedFrequency);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vegetables', style: AppTypography.headline),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              itemCount: _frequencies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final frequency = _frequencies[index];
                return SelectionBox(
                  title: frequency['title']!,
                  subtitle: frequency['subtitle']!,
                  icon: Text(
                    frequency['icon']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  isSelected: _selectedFrequency == frequency['title'],
                  onTap: () {
                    setState(() {
                      _selectedFrequency = frequency['title']!;
                    });
                    _saveFrequency();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Sugary Drinks Screen Content
class SugaryBeveragesScreenContent extends StatefulWidget {
  const SugaryBeveragesScreenContent({super.key});

  @override
  State<SugaryBeveragesScreenContent> createState() =>
      _SugaryBeveragesScreenContentState();
}

class _SugaryBeveragesScreenContentState
    extends State<SugaryBeveragesScreenContent> {
  String _selectedFrequency = '';

  final List<Map<String, dynamic>> _frequencies = [
    {
      'title': 'Almost never',
      'subtitle': 'Never / several times a month',
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-1.svg',
      'value': 'almost_never',
      'iconBgColor': const Color(0xFFF2F2F2),
    },
    {
      'title': 'Rarely',
      'subtitle': 'Few times a week',
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-2.svg',
      'value': 'rarely',
      'iconBgColor': const Color(0xFFE9D9FF),
    },
    {
      'title': 'Regularly',
      'subtitle': 'Every day',
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-3.svg',
      'value': 'regularly',
      'iconBgColor': const Color(0xFFE4F0FF),
    },
    {
      'title': 'Often',
      'subtitle': 'Several per day',
      'icon': 'assets/onboarding_elements/select_your_goal_icons/Frame-4.svg',
      'value': 'often',
      'iconBgColor': const Color(0xFFFFF8E5),
    },
  ];

  Future<void> _saveFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sugary_beverages_frequency', _selectedFrequency);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sugary Beverages', style: AppTypography.headline),
          const SizedBox(height: 8),
          Text(
            'Select your habit.',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.pageCounter,
              fontWeight: FontWeight.w400,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: _frequencies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final frequency = _frequencies[index];
                return SelectionBox(
                  title: frequency['title'] as String,
                  subtitle: frequency['subtitle'] as String,
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: frequency['iconBgColor'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        frequency['icon'] as String,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  isSelected: _selectedFrequency == frequency['value'],
                  onTap: () {
                    setState(() {
                      _selectedFrequency = frequency['value'] as String;
                    });
                    _saveFrequency();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Pregnancy Status Screen Content
class PregnancyScreenContent extends StatefulWidget {
  const PregnancyScreenContent({super.key});

  @override
  State<PregnancyScreenContent> createState() => _PregnancyScreenContentState();
}

class _PregnancyScreenContentState extends State<PregnancyScreenContent> {
  String? _selectedOption;

  final List<Map<String, String>> _options = [
    {
      'title': 'Pregnancy',
      'subtitle': 'Few times a week',
      'value': 'pregnancy',
      'icon': '🤰',
    },
    {
      'title': 'Breastfeeding',
      'subtitle': 'Several per day',
      'value': 'breastfeeding',
      'icon': '🍼',
    },
  ];

  Future<void> _saveSelection() async {
    if (_selectedOption != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pregnancy_status', _selectedOption!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pregnancy/Breast\nfeed', style: AppTypography.headline),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              itemCount: _options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final option = _options[index];
                return LargeSelectionBox(
                  title: option['title']!,
                  subtitle: option['subtitle']!,
                  icon: Text(
                    option['icon']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  isSelected: _selectedOption == option['value'],
                  onTap: () {
                    setState(() {
                      _selectedOption = option['value'];
                    });
                    _saveSelection();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          PreferNotToAnswerButton(
            onPressed: () {
              setState(() => _selectedOption = 'none');
              _saveSelection();
            },
          ),
        ],
      ),
    );
  }
}

// Weather Selection Screen Content
class WeatherSelectionScreenContent extends StatefulWidget {
  const WeatherSelectionScreenContent({super.key});

  @override
  State<WeatherSelectionScreenContent> createState() =>
      _WeatherSelectionScreenContentState();
}

class _WeatherSelectionScreenContentState
    extends State<WeatherSelectionScreenContent> {
  String? _selectedWeather;
  final PageController _pageController = PageController(
    viewportFraction: 0.7,
    initialPage: 1,
  );

  final List<Map<String, dynamic>> _weatherOptions = [
    {
      'title': 'Cold',
      'icon': Icons.ac_unit,
      'value': 'cold',
      'description': 'Below 20°C',
    },
    {
      'title': 'Normal',
      'icon': Icons.thermostat,
      'value': 'normal',
      'description': '20-25°C',
    },
    {
      'title': 'Hot',
      'icon': Icons.wb_sunny,
      'value': 'hot',
      'description': 'Above 25°C',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveWeather() async {
    if (_selectedWeather != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_preference', _selectedWeather!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's the Weather?", style: AppTypography.headline),
          const SizedBox(height: 16),
          Text(
            'Select your current weather condition.',
            style: AppTypography.subtitle,
          ),
          const Spacer(),
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _weatherOptions.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedWeather = _weatherOptions[index]['value'] as String;
                });
                _saveWeather();
              },
              itemBuilder: (context, index) {
                final weather = _weatherOptions[index];
                final isSelected = _selectedWeather == weather['value'];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.selectedBorder
                            : AppColors.boxIconBackground,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        weather['icon'] as IconData,
                        size: 80,
                        color:
                            isSelected
                                ? Colors.white
                                : AppColors.assessmentText,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        weather['title'] as String,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? Colors.white
                                  : AppColors.assessmentText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather['description'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isSelected
                                  ? Colors.white70
                                  : AppColors.textSubtitle,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// Notification Setup Screen Content
class NotificationSetupScreenContent extends StatefulWidget {
  const NotificationSetupScreenContent({super.key});

  @override
  State<NotificationSetupScreenContent> createState() =>
      _NotificationSetupScreenContentState();
}

class _NotificationSetupScreenContentState
    extends State<NotificationSetupScreenContent> {
  final Map<String, bool> _notifications = {
    'appointment': true,
    'doctor': false,
    'chatbot': true,
  };
  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _notifications.entries) {
      await prefs.setBool('notification_${entry.key}', entry.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text('Notification Setup', style: AppTypography.headline),
        const SizedBox(height: 8),
        Text(
          "Choose which notification you'd like to setup.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 32),
        _buildNotificationOption(
          'App Notification',
          'appointment',
          const Color(0xFFFFE8E8),
          '📅',
        ),
      ],
    );
  }

  Widget _buildNotificationOption(
    String title,
    String key,
    Color backgroundColor,
    String emoji,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          Switch(
            value: _notifications[key]!,
            onChanged: (value) {
              setState(() {
                _notifications[key] = value;
              });
              _saveNotificationPreferences();
            },
            activeColor: AppColors.selectedBorder,
            activeTrackColor: AppColors.preferNotToAnswer,
          ),
        ],
      ),
    );
  }
}
