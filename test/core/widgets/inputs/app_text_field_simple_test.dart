import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/inputs/app_text_field.dart';

void main() {
  group('AppTextField Simple Tests', () {
    testWidgets('renders basic widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppTextField())),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('displays label text', (WidgetTester tester) async {
      const labelText = 'Test Label';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppTextField(labelText: labelText)),
        ),
      );

      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets('handles text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppTextField())),
      );

      await tester.enterText(find.byType(TextFormField), 'test input');
      expect(find.text('test input'), findsOneWidget);
    });
  });
}
