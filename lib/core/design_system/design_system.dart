/// Comprehensive design system for the Water Tracker app
///
/// This file exports all design system components for easy importing
/// throughout the application. It provides consistent colors, typography,
/// spacing, and other design tokens.
///
/// Usage:
/// ```dart
/// import 'package:watertracker/core/design_system/design_system.dart';
///
/// // Use design system tokens
/// Text('Hello', style: AppTypography.headlineMedium);
/// Container(color: AppColors.primary);
/// SizedBox(height: AppSpacing.md);
///
/// // Use design system components
/// AppButton.primary(onPressed: () {}, child: Text('Click me'));
/// AppText.headline('Welcome');
/// AppCard.padded(child: Text('Content'));
/// ```

library design_system;

// Design tokens
export 'app_colors.dart';
export 'app_spacing.dart';
export 'app_theme.dart';
export 'app_typography.dart';

// Components
export 'components/accessible_hydration_button.dart';
export 'components/accessible_navigation.dart';
export 'components/app_button.dart';
export 'components/app_card.dart';
export 'components/app_text.dart';
export 'components/loading_states.dart';

// Animations
export 'animations/micro_interactions.dart';

// Accessibility
export 'accessibility/accessibility_helper.dart';

// Utils
export 'utils/haptic_feedback_utils.dart';
