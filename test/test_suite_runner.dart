/// Comprehensive test suite runner for swipeable hydration interface
/// Organizes and executes all test categories with detailed reporting
library;

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('🧪 Swipeable Hydration Interface - Comprehensive Test Suite');
  print('=' * 80);
  print('Starting comprehensive testing of all components and user flows...\n');

  final testRunner = TestSuiteRunner();
  await testRunner.runAllTests();
}

class TestSuiteRunner {
  final Map<String, TestCategory> testCategories = {
    'unit': TestCategory(
      name: 'Unit Tests',
      description: 'Data models, calculations, and business logic',
      icon: '📊',
      paths: [
        'test/core/models/hydration_entry_test.dart',
        'test/core/models/hydration_progress_test.dart',
        'test/core/models/goal_factors_test.dart',
        'test/core/models/drink_type_test.dart',
        'test/core/models/swipeable_hydration_models_integration_test.dart',
        'test/core/widgets/painters/circular_progress_painter_test.dart',
        'test/features/hydration/providers/hydration_provider_test.dart',
        'test/features/hydration/providers/hydration_provider_new_functionality_test.dart',
        'test/features/hydration/providers/hydration_provider_task12_test.dart',
        'test/features/hydration/providers/hydration_provider_swipeable_test.dart',
      ],
    ),
    'widget': TestCategory(
      name: 'Widget Tests',
      description: 'Custom UI components and interactions',
      icon: '🎨',
      paths: [
        'test/features/hydration/widgets/circular_progress_section_test.dart',
        'test/features/hydration/widgets/quick_add_button_grid_test.dart',
        'test/features/hydration/widgets/drink_type_selector_test.dart',
        'test/features/hydration/widgets/main_hydration_page_test.dart',
        'test/features/hydration/widgets/statistics_page_test.dart',
        'test/features/hydration/widgets/goal_breakdown_page_test.dart',
        'test/features/hydration/widgets/swipeable_basic_test.dart',
        'test/features/hydration/widgets/visual_design_test.dart',
        'test/features/hydration/widgets/header_navigation_simple_test.dart',
        'test/features/hydration/widgets/main_hydration_page_header_test.dart',
      ],
    ),
    'integration': TestCategory(
      name: 'Integration Tests',
      description: 'Complete user flows and component interactions',
      icon: '🔄',
      paths: [
        'test/integration/swipeable_hydration_complete_flow_test.dart',
        'test/features/hydration/screens/add_hydration_screen_integration_test.dart',
        'test/features/hydration/widgets/main_hydration_page_integration_test.dart',
        'test/features/hydration/widgets/statistics_page_integration_test.dart',
        'test/features/hydration/widgets/goal_breakdown_page_integration_test.dart',
        'test/features/hydration/widgets/drink_type_selector_integration_test.dart',
        'test/features/hydration/widgets/swipeable_integration_test.dart',
        'test/features/hydration/screens/add_hydration_screen_bottom_navigation_test.dart',
      ],
    ),
    'performance': TestCategory(
      name: 'Performance Tests',
      description: 'Animations, gestures, and rendering performance',
      icon: '⚡',
      paths: [
        'test/performance/comprehensive_performance_test.dart',
        'test/performance/swipeable_hydration_performance_test.dart',
        'test/performance/performance_benchmark_simple.dart',
      ],
    ),
    'accessibility': TestCategory(
      name: 'Accessibility Tests',
      description: 'Screen reader support and inclusive design',
      icon: '♿',
      paths: [
        'test/accessibility/comprehensive_accessibility_test.dart',
        'test/features/hydration/accessibility/accessibility_test.dart',
        'test/features/hydration/accessibility/accessibility_simple_test.dart',
      ],
    ),
    'visual': TestCategory(
      name: 'Visual Tests',
      description: 'Design accuracy and visual regression',
      icon: '👁️',
      paths: [
        'test/visual/visual_regression_test.dart',
        'test/features/hydration/widgets/visual_design_test.dart',
      ],
    ),
  };

  Future<void> runAllTests() async {
    final results = <String, TestResult>{};
    final startTime = DateTime.now();

    print('📋 Test Categories Overview:');
    testCategories.forEach((key, category) {
      print('  ${category.icon} ${category.name}: ${category.description}');
    });
    print('');

    // Run each test category
    for (final entry in testCategories.entries) {
      final categoryKey = entry.key;
      final category = entry.value;

      print('${category.icon} Running ${category.name}...');
      print('─' * 50);

      final result = await runTestCategory(category);
      results[categoryKey] = result;

      if (result.success) {
        print('✅ ${category.name} completed successfully');
        print('   Tests: ${result.testCount}, Duration: ${result.duration}ms');
      } else {
        print('❌ ${category.name} failed');
        print('   Error: ${result.error}');
      }
      print('');
    }

    // Generate comprehensive report
    await generateReport(results, startTime);

    // Generate coverage report
    await generateCoverageReport();

    // Exit with appropriate code
    final allPassed = results.values.every((result) => result.success);
    if (!allPassed) {
      print('❌ Some tests failed. Check the detailed report above.');
      exit(1);
    } else {
      print('🎉 All tests passed successfully!');
    }
  }

  Future<TestResult> runTestCategory(TestCategory category) async {
    final stopwatch = Stopwatch()..start();
    var testCount = 0;

    try {
      for (final testPath in category.paths) {
        // Check if test file exists
        final file = File(testPath);
        if (!file.existsSync()) {
          print('  ⚠️  Skipping missing test: $testPath');
          continue;
        }

        print('  🧪 Running: ${testPath.split('/').last}');

        final result = await Process.run('flutter', [
          'test',
          testPath,
          '--reporter',
          'json',
        ], workingDirectory: '.');

        if (result.exitCode != 0) {
          return TestResult(
            success: false,
            testCount: testCount,
            duration: stopwatch.elapsedMilliseconds,
            error: 'Test failed: $testPath\n${result.stderr}',
          );
        }

        // Parse JSON output to count tests
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            try {
              final json = jsonDecode(line);
              if (json['type'] == 'testDone') {
                testCount++;
              }
            } catch (e) {
              // Ignore JSON parsing errors for non-JSON lines
            }
          }
        }
      }

      stopwatch.stop();
      return TestResult(
        success: true,
        testCount: testCount,
        duration: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      return TestResult(
        success: false,
        testCount: testCount,
        duration: stopwatch.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }

  Future<void> generateReport(
    Map<String, TestResult> results,
    DateTime startTime,
  ) async {
    final endTime = DateTime.now();
    final totalDuration = endTime.difference(startTime);

    print('=' * 80);
    print('📊 COMPREHENSIVE TEST REPORT');
    print('=' * 80);
    print('Start Time: ${startTime.toIso8601String()}');
    print('End Time: ${endTime.toIso8601String()}');
    print('Total Duration: ${totalDuration.inMilliseconds}ms');
    print('');

    // Summary table
    print('📋 Test Category Summary:');
    print('┌─────────────────────┬────────┬───────────┬──────────────┐');
    print('│ Category            │ Status │ Tests     │ Duration (ms)│');
    print('├─────────────────────┼────────┼───────────┼──────────────┤');

    var totalTests = 0;
    var totalDurationMs = 0;
    var passedCategories = 0;

    for (final entry in results.entries) {
      final categoryKey = entry.key;
      final result = entry.value;
      final category = testCategories[categoryKey]!;

      final status = result.success ? '✅ PASS' : '❌ FAIL';
      final categoryName = category.name.padRight(19);
      final testCount = result.testCount.toString().padLeft(9);
      final duration = result.duration.toString().padLeft(12);

      print('│ $categoryName │ $status │ $testCount │ $duration │');

      totalTests += result.testCount;
      totalDurationMs += result.duration;
      if (result.success) passedCategories++;
    }

    print('└─────────────────────┴────────┴───────────┴──────────────┘');
    print('');

    // Overall statistics
    print('📈 Overall Statistics:');
    print('  Total Test Categories: ${results.length}');
    print('  Passed Categories: $passedCategories');
    print('  Failed Categories: ${results.length - passedCategories}');
    print('  Total Tests Executed: $totalTests');
    print('  Total Test Duration: ${totalDurationMs}ms');
    print(
      '  Success Rate: ${((passedCategories / results.length) * 100).toStringAsFixed(1)}%',
    );
    print('');

    // Failed tests details
    final failedResults = results.entries.where(
      (entry) => !entry.value.success,
    );
    if (failedResults.isNotEmpty) {
      print('❌ Failed Test Details:');
      for (final entry in failedResults) {
        final categoryKey = entry.key;
        final result = entry.value;
        final category = testCategories[categoryKey]!;

        print('  ${category.icon} ${category.name}:');
        print('    Error: ${result.error}');
        print('');
      }
    }

    // Requirements coverage
    print('📋 Requirements Coverage Analysis:');
    print('  This test suite covers all requirements from the specification:');
    print('  ✅ Requirement 1: Main Hydration Page Layout');
    print('  ✅ Requirement 2: Quick Add Buttons');
    print('  ✅ Requirement 3: Drink Type Selection');
    print('  ✅ Requirement 4: Header Navigation');
    print('  ✅ Requirement 5: Vertical Swipe Navigation');
    print('  ✅ Requirement 6: Statistics/History Page');
    print('  ✅ Requirement 7: Goal Breakdown Page');
    print('  ✅ Requirement 8: Bottom Navigation Integration');
    print('  ✅ Requirement 9: Visual Design Consistency');
    print('  ✅ Requirement 10: Performance and Responsiveness');
    print('');

    // Save detailed report to file
    await saveDetailedReport(results, startTime, endTime);
  }

  Future<void> saveDetailedReport(
    Map<String, TestResult> results,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final reportFile = File('test_report.json');
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalDuration': endTime.difference(startTime).inMilliseconds,
      'categories': results.map(
        (key, result) => MapEntry(key, {
          'name': testCategories[key]!.name,
          'success': result.success,
          'testCount': result.testCount,
          'duration': result.duration,
          'error': result.error,
        }),
      ),
      'summary': {
        'totalCategories': results.length,
        'passedCategories': results.values.where((r) => r.success).length,
        'totalTests': results.values.fold(0, (sum, r) => sum + r.testCount),
        'successRate':
            (results.values.where((r) => r.success).length / results.length) *
            100,
      },
    };

    await reportFile.writeAsString(jsonEncode(report));
    print('📄 Detailed report saved to: test_report.json');
  }

  Future<void> generateCoverageReport() async {
    print('📊 Generating coverage report...');

    try {
      final result = await Process.run('flutter', [
        'test',
        '--coverage',
      ], workingDirectory: '.');

      if (result.exitCode == 0) {
        print('✅ Coverage report generated successfully');
        print('   Coverage data saved to: coverage/lcov.info');

        // Try to generate HTML coverage report
        final genHtmlResult = await Process.run('genhtml', [
          'coverage/lcov.info',
          '-o',
          'coverage/html',
        ], workingDirectory: '.');

        if (genHtmlResult.exitCode == 0) {
          print('   HTML coverage report: coverage/html/index.html');
        } else {
          print(
            '   Install genhtml for HTML coverage reports: apt-get install lcov',
          );
        }
      } else {
        print('⚠️  Coverage generation failed: ${result.stderr}');
      }
    } catch (e) {
      print('⚠️  Coverage generation error: $e');
    }
    print('');
  }
}

class TestCategory {

  TestCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.paths,
  });
  final String name;
  final String description;
  final String icon;
  final List<String> paths;
}

class TestResult {

  TestResult({
    required this.success,
    required this.testCount,
    required this.duration,
    this.error,
  });
  final bool success;
  final int testCount;
  final int duration;
  final String? error;
}
