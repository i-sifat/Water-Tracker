# Integration Tests

This directory contains comprehensive integration tests for the Water Tracker app.

## Test Files

1. **app_test.dart** - Complete user flow from onboarding to tracking
2. **premium_unlock_test.dart** - Premium unlock process and feature access
3. **data_persistence_test.dart** - Data persistence and synchronization
4. **notification_test.dart** - Notification functionality
5. **offline_online_test.dart** - Offline/online behavior transitions
6. **all_tests.dart** - Test runner for all integration tests

## Running Tests

### Prerequisites
- Connected device or emulator
- Flutter SDK installed
- App dependencies installed (`flutter pub get`)

### Run Individual Tests
```bash
flutter test integration_test/app_test.dart
flutter test integration_test/premium_unlock_test.dart
flutter test integration_test/data_persistence_test.dart
flutter test integration_test/notification_test.dart
flutter test integration_test/offline_online_test.dart
```

### Run All Integration Tests
```bash
flutter test integration_test/all_tests.dart
```

### Run with Device
```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
```

## Test Coverage

### Complete User Flows
- ✅ Onboarding flow completion
- ✅ Water intake tracking
- ✅ Navigation between screens
- ✅ Settings configuration

### Premium Unlock Process
- ✅ Premium feature access gates
- ✅ Donation info display
- ✅ Device code generation
- ✅ Unlock code validation
- ✅ Premium status persistence

### Data Persistence
- ✅ Water intake data persistence
- ✅ User profile data persistence
- ✅ Theme and settings persistence
- ✅ Data backup and restore
- ✅ Data migration on updates

### Notification Functionality
- ✅ Notification permission requests
- ✅ Reminder setup and management
- ✅ Smart reminder functionality
- ✅ Notification customization
- ✅ Background behavior

### Offline/Online Behavior
- ✅ Core functionality offline
- ✅ Data queuing and sync
- ✅ Conflict resolution
- ✅ Premium features offline
- ✅ Network state changes
- ✅ Graceful degradation

## Requirements Coverage

These integration tests cover the following requirements:

- **8.1** - Offline core functionality
- **8.2** - Automatic sync when connected
- **8.3** - Intelligent conflict resolution
- **8.4** - Local storage management
- **8.5** - Sync failure handling

## Notes

- Tests use `SharedPreferences.setMockInitialValues()` for setup
- Mock data is used for testing scenarios
- Tests verify UI state changes and user interactions
- Network behavior is simulated for offline/online testing
- Premium features are tested with mock unlock codes