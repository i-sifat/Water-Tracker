import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/features/hydration/widgets/main_hydration_page.dart';

void main() {
  group('MainHydrationPage Unit Tests', () {
    test('can be instantiated with default parameters', () {
      const widget = MainHydrationPage();

      expect(widget.currentPage, 1);
      expect(widget.totalPages, 3);
    });

    test('can be instantiated with custom parameters', () {
      const widget = MainHydrationPage(currentPage: 2, totalPages: 5);

      expect(widget.currentPage, 2);
      expect(widget.totalPages, 5);
    });

    test('creates state correctly', () {
      const widget = MainHydrationPage();
      final state = widget.createState();

      expect(state, isNotNull);
    });
  });
}
