import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:watertracker/core/constants/premium_features.dart';
import 'package:watertracker/core/constants/typography.dart';
import 'package:watertracker/core/models/user_profile.dart';
import 'package:watertracker/core/utils/app_colors.dart';
import 'package:watertracker/core/utils/water_intake_calculator.dart';
import 'package:watertracker/core/widgets/buttons/primary_button.dart';
import 'package:watertracker/core/widgets/cards/app_card.dart';
import 'package:watertracker/core/widgets/common/premium_gate.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';

/// Screen for advanced goal customization (Premium feature)
class AdvancedGoalScreen extends StatefulWidget {
  const AdvancedGoalScreen({super.key});

  @override
  State<AdvancedGoalScreen> createState() => _AdvancedGoalScreenState();
}

class _AdvancedGoalScreenState extends State<AdvancedGoalScreen> {
  // Advanced factors
  double? _bodyFatPercentage;
  double? _muscleMass;
  int? _sleepHours;
  int _stressLevel = 5;
  double? _environmentalTemperature;
  double? _humidity;
  int? _altitude;
  bool _isPreWorkout = false;
  bool _isPostWorkout = false;
  int? _caffeineIntake;
  int? _alcoholIntake;
  String? _climateZone;
  int? _sweatRate;

  // Controllers
  late TextEditingController _bodyFatController;
  late TextEditingController _muscleMassController;
  late TextEditingController _sleepController;
  late TextEditingController _temperatureController;
  late TextEditingController _humidityController;
  late TextEditingController _altitudeController;
  late TextEditingController _caffeineController;
  late TextEditingController _alcoholController;
  late TextEditingController _sweatRateController;

  int _calculatedGoal = 2000;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserProfile();
  }

  void _initializeControllers() {
    _bodyFatController = TextEditingController();
    _muscleMassController = TextEditingController();
    _sleepController = TextEditingController();
    _temperatureController = TextEditingController();
    _humidityController = TextEditingController();
    _altitudeController = TextEditingController();
    _caffeineController = TextEditingController();
    _alcoholController = TextEditingController();
    _sweatRateController = TextEditingController();
  }

  @override
  void dispose() {
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _sleepController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _altitudeController.dispose();
    _caffeineController.dispose();
    _alcoholController.dispose();
    _sweatRateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    // In a real implementation, this would load from storage
    // For now, create a sample profile
    setState(() {
      _userProfile = UserProfile.create().copyWith(
        weight: 70,
        age: 30,
        gender: Gender.male,
        activityLevel: ActivityLevel.moderatelyActive,
        goals: [Goal.generalHealth],
      );
    });
    _calculateGoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Goal Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumGate(
        feature: PremiumFeature.customGoals,
        child: _buildContent(),
        lockedChild: _buildLockedContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalDisplay(),
                const SizedBox(height: 24),
                _buildBodyCompositionSection(),
                const SizedBox(height: 24),
                _buildLifestyleSection(),
                const SizedBox(height: 24),
                _buildEnvironmentalSection(),
                const SizedBox(height: 24),
                _buildActivitySection(),
                const SizedBox(height: 24),
                _buildSubstanceSection(),
              ],
            ),
          ),
        ),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildLockedContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tune,
            size: 80,
            color: AppColors.waterFull.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Advanced Goal Calculator',
            style: AppTypography.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Get personalized hydration goals based on advanced factors like body composition, sleep quality, stress levels, environmental conditions, and more.',
            style: AppTypography.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Unlock Premium',
            onPressed: () => context.read<PremiumProvider>().showPremiumFlow(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalDisplay() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Your Advanced Goal',
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${_calculatedGoal}ml',
              style: AppTypography.headline.copyWith(
                color: AppColors.waterFull,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'per day',
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This goal is calculated using advanced factors for maximum accuracy.',
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyCompositionSection() {
    return _buildSection(
      title: 'Body Composition',
      icon: Icons.fitness_center,
      children: [
        _buildNumberField(
          controller: _bodyFatController,
          label: 'Body Fat Percentage',
          suffix: '%',
          hint: 'e.g., 15',
          onChanged: (value) {
            _bodyFatPercentage = double.tryParse(value);
            _calculateGoal();
          },
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          controller: _muscleMassController,
          label: 'Muscle Mass',
          suffix: 'kg',
          hint: 'e.g., 30',
          onChanged: (value) {
            _muscleMass = double.tryParse(value);
            _calculateGoal();
          },
        ),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return _buildSection(
      title: 'Lifestyle Factors',
      icon: Icons.bedtime,
      children: [
        _buildNumberField(
          controller: _sleepController,
          label: 'Sleep Hours per Night',
          suffix: 'hours',
          hint: 'e.g., 8',
          onChanged: (value) {
            _sleepHours = int.tryParse(value);
            _calculateGoal();
          },
        ),
        const SizedBox(height: 16),
        _buildStressLevelSlider(),
      ],
    );
  }

  Widget _buildEnvironmentalSection() {
    return _buildSection(
      title: 'Environmental Conditions',
      icon: Icons.wb_sunny,
      children: [
        _buildNumberField(
          controller: _temperatureController,
          label: 'Average Temperature',
          suffix: '°C',
          hint: 'e.g., 25',
          onChanged: (value) {
            _environmentalTemperature = double.tryParse(value);
            _calculateGoal();
          },
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          controller: _humidityController,
          label: 'Humidity',
          suffix: '%',
          hint: 'e.g., 60',
          onChanged: (value) {
            _humidity = double.tryParse(value);
            _calculateGoal();
          },
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          controller: _altitudeController,
          label: 'Altitude',
          suffix: 'm',
          hint: 'e.g., 1000',
          onChanged: (value) {
            _altitude = int.tryParse(value);
            _calculateGoal();
          },
        ),
        const SizedBox(height: 16),
        _buildClimateZoneDropdown(),
      ],
    );
  }

  Widget _buildActivitySection() {
    return _buildSection(
      title: 'Activity & Exercise',
      icon: Icons.directions_run,
      children: [
        _buildNumberField(
          controller: _sweatRateController,
          label: 'Sweat Rate (during exercise)',
          suffix: 'ml/hour',
          hint: 'e.g., 800',
          onChanged: (value) {
            _sweatRate = int.tryParse(value);
            _calculateGoal();
          },
        ),
        const SizedBox(height: 16),
        _buildWorkoutTimingCheckboxes(),
      ],
    );
  }

  Widget _buildSubstanceSection() {
    return _buildSection(
      title: 'Substance Intake',
      icon: Icons.local_cafe,
      children: [
        _buildNumberField(
          controller: _caffeineController,
          label: 'Daily Caffeine Intake',
          suffix: 'mg',
          hint: 'e.g., 200',
          onChanged: (value) {
            _caffeineIntake = int.tryParse(value);
            _calculateGoal();
          },
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          controller: _alcoholController,
          label: 'Daily Alcohol Intake',
          suffix: 'drinks',
          hint: 'e.g., 1',
          onChanged: (value) {
            _alcoholIntake = int.tryParse(value);
            _calculateGoal();
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.waterFull),
                const SizedBox(width: 12),
                Text(title, style: AppTypography.subtitle),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.subtitle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStressLevelSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stress Level', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Low'),
            Expanded(
              child: Slider(
                value: _stressLevel.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _stressLevel.toString(),
                activeColor: AppColors.waterFull,
                onChanged: (value) {
                  setState(() => _stressLevel = value.round());
                  _calculateGoal();
                },
              ),
            ),
            const Text('High'),
          ],
        ),
        Text(
          'Current: $_stressLevel/10',
          style: AppTypography.subtitle,
        ),
      ],
    );
  }

  Widget _buildClimateZoneDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Climate Zone', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _climateZone,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          hint: const Text('Select climate zone'),
          items: const [
            DropdownMenuItem(value: 'tropical', child: Text('Tropical')),
            DropdownMenuItem(value: 'desert', child: Text('Desert')),
            DropdownMenuItem(value: 'temperate', child: Text('Temperate')),
            DropdownMenuItem(value: 'arctic', child: Text('Arctic')),
          ],
          onChanged: (value) {
            setState(() => _climateZone = value);
            _calculateGoal();
          },
        ),
      ],
    );
  }

  Widget _buildWorkoutTimingCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workout Timing', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Pre-workout hydration needed'),
          value: _isPreWorkout,
          onChanged: (value) {
            setState(() => _isPreWorkout = value ?? false);
            _calculateGoal();
          },
          activeColor: AppColors.waterFull,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Post-workout recovery hydration'),
          value: _isPostWorkout,
          onChanged: (value) {
            setState(() => _isPostWorkout = value ?? false);
            _calculateGoal();
          },
          activeColor: AppColors.waterFull,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: PrimaryButton(
        text: 'Apply Advanced Goal',
        onPressed: _saveAdvancedGoal,
        icon: Icons.save,
      ),
    );
  }

  void _calculateGoal() {
    if (_userProfile == null) return;

    final goal = WaterIntakeCalculator.calculateAdvancedIntake(
      _userProfile!,
      bodyFatPercentage: _bodyFatPercentage,
      muscleMass: _muscleMass,
      sleepHours: _sleepHours,
      stressLevel: _stressLevel,
      environmentalTemperature: _environmentalTemperature,
      humidity: _humidity,
      altitude: _altitude,
      isPreWorkout: _isPreWorkout,
      isPostWorkout: _isPostWorkout,
      caffeineIntake: _caffeineIntake,
      alcoholIntake: _alcoholIntake,
      climateZone: _climateZone,
      sweatRate: _sweatRate,
    );

    setState(() => _calculatedGoal = goal);
  }

  Future<void> _saveAdvancedGoal() async {
    try {
      // In a real implementation, this would save to storage and update the user profile
      // For now, just show a success message
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Advanced goal of ${_calculatedGoal}ml applied successfully!'),
          backgroundColor: AppColors.waterFull,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goal: $e')),
      );
    }
  }
}