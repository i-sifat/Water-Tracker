#!/bin/bash

# Add newlines to test files that need them
test_files=(
    "test/core/models/hydration_data_comprehensive_test.dart"
    "test/core/models/hydration_data_simple_test.dart"
    "test/core/models/hydration_data_test.dart"
    "test/core/models/user_profile_test.dart"
    "test/core/services/device_service_test.dart"
    "test/core/services/notification_service_comprehensive_test.dart"
    "test/core/services/notification_service_test.dart"
    "test/core/services/premium_service_test.dart"
    "test/core/services/storage_service_comprehensive_test.dart"
    "test/core/services/storage_service_test.dart"
    "test/core/services/water_intake_calculator_test.dart"
    "test/core/widgets/animations/celebration_animation_test.dart"
    "test/core/widgets/animations/micro_interactions_test.dart"
    "test/core/widgets/animations/water_animation_test.dart"
    "test/core/widgets/buttons/continue_button_test.dart"
    "test/core/widgets/buttons/prefer_not_to_answer_button_test.dart"
    "test/core/widgets/buttons/primary_button_test.dart"
    "test/core/widgets/buttons/secondary_button_test.dart"
    "test/core/widgets/cards/app_card_test.dart"
    "test/core/widgets/cards/large_selection_box_test.dart"
    "test/core/widgets/cards/selection_box_test.dart"
    "test/core/widgets/common/accessible_button_test.dart"
    "test/core/widgets/common/empty_state_widget_test.dart"
    "test/core/widgets/common/loading_widget_test.dart"
    "test/core/widgets/common/premium_gate_test.dart"
    "test/core/widgets/custom_bottom_navigation_bar_test.dart"
    "test/core/widgets/custom_ruler_picker_test.dart"
    "test/core/widgets/inputs/app_text_field_comprehensive_test.dart"
    "test/core/widgets/inputs/app_text_field_simple_test.dart"
    "test/core/widgets/inputs/app_text_field_test.dart"
    "test/features/analytics/providers/analytics_provider_comprehensive_test.dart"
    "test/features/hydration/providers/hydration_provider_comprehensive_test.dart"
    "test/features/hydration/providers/hydration_provider_simple_test.dart"
    "test/features/hydration/providers/hydration_provider_test.dart"
    "test/features/hydration/screens/add_hydration_screen_test.dart"
    "test/features/onboarding/screens/age_selection_screen_test.dart"
    "test/features/onboarding/widgets/onboarding_progress_indicator_test.dart"
    "test/features/premium/providers/premium_provider_comprehensive_test.dart"
    "test/features/premium/providers/premium_provider_test.dart"
    "test/features/premium/screens/donation_info_screen_test.dart"
    "test/features/premium/widgets/premium_status_indicator_test.dart"
    "test/features/settings/screens/settings_screen_test.dart"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo "" >> "$file"
        echo "Added newline to $file"
    fi
done