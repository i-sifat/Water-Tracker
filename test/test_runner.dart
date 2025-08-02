/// Comprehensive test runner for the swipeable hydration interface
/// This script organizes and runs all test categories systematically
library;

import 'dart:io';

void main() async {
  print(
    '🧪 Starting Comprehensive Test Suite for Swipeable Hydration Interface',
  );
  print('=' * 70);

  final testResults = <String, bool>{};

  // 1. Unit Tests - Data models and calculations
  print('\n📊 Running Unit Tests...');
  testResults['Unit Tests'] = await runTestCategory('unit', [
    'test/core/models/',
    'test/core/services/',
    'test/features/hydration/providers/',
  ]);

  // 2. Widget Tests - Custom components
  print('\n🎨 Running Widget Tests...');
  testResults['Widget Tests'] = await runTestCategory('widget', [
    'test/core/widgets/',
    'test/features/hydration/widgets/',
  ]);

  // 3. Integration Tests - Complete user flows
  print('\n🔄 Running Integration Tests...');
  testResults['Integration Tests'] = await runTestCategory('integration', [
    'test/features/hydration/screens/',
    'test/core/models/swipeable_hydration_models_integration_test.dart',
  ]);

  // 4. Performance Tests - Animations and gestures
  print('\n⚡ Running Performance Tests...');
  testResults['Performance Tests'] = await runTestCategory('performance', [
    'test/performance/',
  ]);

  // 5. Accessibility Tests - Inclusive design
  print('\n♿ Running Accessibility Tests...');
  testResults['Accessibility Tests'] = await runTestCategory('accessibility', [
    'test/features/hydration/accessibility/',
  ]);

  // 6. Visual Tests - Design accuracy
  print('\n👁️ Running Visual Tests...');
  testResults['Visual Tests'] = await runTestCategory('visual', [
    'test/features/hydration/widgets/visual_design_test.dart',
  ]);

  // Print summary
  print('\n${'=' * 70}');
  print('📋 Test Suite Summary:');
  print('=' * 70);

  var allPassed = true;
  for (final entry in testResults.entries) {
    final status = entry.value ? '✅ PASSED' : '❌ FAILED';
    print('${entry.key.padRight(20)}: $status');
    if (!entry.value) allPassed = false;
  }

  print(
    '\n🎯 Overall Result: ${allPassed ? "✅ ALL TESTS PASSED" : "❌ SOME TESTS FAILED"}',
  );

  if (!allPassed) {
    exit(1);
  }
}

Future<bool> runTestCategory(String category, List<String> testPaths) async {
  try {
    for (final path in testPaths) {
      final result = await Process.run('flutter', [
        'test',
        path,
        '--tags',
        category,
      ], workingDirectory: '.');

      if (result.exitCode != 0) {
        print('❌ Failed: $path');
        print(result.stderr);
        return false;
      } else {
        print('✅ Passed: $path');
      }
    }
    return true;
  } catch (e) {
    print('❌ Error running $category tests: $e');
    return false;
  }
}
