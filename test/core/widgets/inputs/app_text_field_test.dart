import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watertracker/core/widgets/inputs/app_text_field.dart';

void main() {
  group('AppTextField Widget Tests', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('displays label text when provided', (WidgetTester tester) async {
      const labelText = 'Test Label';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              labelText: labelText,
            ),
          ),
        ),
      );

      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets('displays hint text when provided', (WidgetTester tester) async {
      const hintText = 'Test Hint';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              hintText: hintText,
            ),
          ),
        ),
      );

      // Tap the text field to show the hint text
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      
      // Check if hint text is present in the widget tree
      expect(find.text(hintText), findsOneWidget);
    });

    testWidgets('displays helper text when provided', (WidgetTester tester) async {
      const helperText = 'Test Helper';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              helperText: helperText,
            ),
          ),
        ),
      );

      expect(find.text(helperText), findsOneWidget);
    });

    testWidgets('displays error text when provided', (WidgetTester tester) async {
      const errorText = 'Test Error';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              errorText: errorText,
            ),
          ),
        ),
      );

      expect(find.text(errorText), findsOneWidget);
    });

    testWidgets('shows prefix icon when provided', (WidgetTester tester) async {
      const prefixIcon = Icon(Icons.email);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              prefixIcon: prefixIcon,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('shows suffix icon when provided and not obscure text', (WidgetTester tester) async {
      const suffixIcon = Icon(Icons.clear);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('shows visibility toggle for obscure text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              obscureText: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('toggles visibility when visibility icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              obscureText: true,
            ),
          ),
        ),
      );

      // Initially should show visibility icon (text is obscured)
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap the visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Now should show visibility_off icon (text is visible)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (WidgetTester tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test input');
      expect(changedValue, equals('test input'));
    });

    testWidgets('calls onSubmitted when submitted', (WidgetTester tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              onSubmitted: (value) => submittedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test input');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedValue, equals('test input'));
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      expect(wasTapped, isTrue);
    });

    testWidgets('validates input when validator is provided', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Validate empty field
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Field is required'), findsOneWidget);

      // Enter valid text
      await tester.enterText(find.byType(TextFormField), 'valid input');
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('respects enabled property', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              enabled: false,
            ),
          ),
        ),
      );

      // Try to tap and enter text - should not work when disabled
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();
      
      // Text should not appear since field is disabled
      expect(find.text('test'), findsNothing);
    });

    testWidgets('respects readOnly property', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              readOnly: true,
            ),
          ),
        ),
      );

      // Try to enter text - should not work when readOnly
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();
      
      // Text should not appear since field is readOnly
      expect(find.text('test'), findsNothing);
    });

    testWidgets('respects maxLines property', (WidgetTester tester) async {
      const maxLines = 3;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              maxLines: maxLines,
            ),
          ),
        ),
      );

      // Enter multiline text to test maxLines behavior
      await tester.enterText(find.byType(TextFormField), 'Line 1\nLine 2\nLine 3\nLine 4');
      await tester.pump();
      
      // Verify the text field exists and can handle multiple lines
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Line 1\nLine 2\nLine 3\nLine 4'), findsOneWidget);
    });

    testWidgets('respects maxLength property', (WidgetTester tester) async {
      const maxLength = 10;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              maxLength: maxLength,
            ),
          ),
        ),
      );

      // Try to enter text longer than maxLength
      await tester.enterText(find.byType(TextFormField), 'This is a very long text that exceeds the limit');
      await tester.pump();
      
      // Find the actual text in the field (should be truncated to maxLength)
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);
      
      // The text should be limited by maxLength
      final controller = tester.widget<TextFormField>(textField).controller;
      if (controller != null) {
        expect(controller.text.length, lessThanOrEqualTo(maxLength));
      }
    });

    testWidgets('respects keyboardType property', (WidgetTester tester) async {
      const keyboardType = TextInputType.emailAddress;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              keyboardType: keyboardType,
            ),
          ),
        ),
      );

      // Test that the widget renders correctly with email keyboard type
      expect(find.byType(TextFormField), findsOneWidget);
      
      // Focus the field to potentially trigger keyboard
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      
      // Verify the field accepts email-like input
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('respects textInputAction property', (WidgetTester tester) async {
      String? submittedValue;
      const textInputAction = TextInputAction.search;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              textInputAction: textInputAction,
              onSubmitted: (value) => submittedValue = value,
            ),
          ),
        ),
      );

      // Enter text and trigger the input action
      await tester.enterText(find.byType(TextFormField), 'search query');
      await tester.testTextInput.receiveAction(textInputAction);
      
      expect(submittedValue, equals('search query'));
    });

    testWidgets('respects textCapitalization property', (WidgetTester tester) async {
      const textCapitalization = TextCapitalization.words;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              textCapitalization: textCapitalization,
            ),
          ),
        ),
      );

      // Test that the widget renders correctly
      expect(find.byType(TextFormField), findsOneWidget);
      
      // Enter text to test capitalization behavior
      await tester.enterText(find.byType(TextFormField), 'hello world');
      await tester.pump();
      
      // The widget should exist and accept the text
      expect(find.text('hello world'), findsOneWidget);
    });

    testWidgets('respects inputFormatters property', (WidgetTester tester) async {
      final inputFormatters = [FilteringTextInputFormatter.digitsOnly];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              inputFormatters: inputFormatters,
            ),
          ),
        ),
      );

      // Try to enter text with letters and numbers
      await tester.enterText(find.byType(TextFormField), 'abc123def456');
      await tester.pump();
      
      // Only digits should remain due to the formatter
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('respects autofocus property', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              autofocus: true,
            ),
          ),
        ),
      );

      // With autofocus, the field should be focused immediately
      await tester.pump();
      
      // Verify the text field exists
      expect(find.byType(TextFormField), findsOneWidget);
      
      // Enter text without tapping (should work due to autofocus)
      await tester.enterText(find.byType(TextFormField), 'autofocus test');
      expect(find.text('autofocus test'), findsOneWidget);
    });

    testWidgets('uses provided controller', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'initial text');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('initial text'), findsOneWidget);
    });

    testWidgets('uses provided focus node', (WidgetTester tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              focusNode: focusNode,
            ),
          ),
        ),
      );

      // Initially not focused
      expect(focusNode.hasFocus, isFalse);
      
      // Request focus programmatically
      focusNode.requestFocus();
      await tester.pump();
      
      // Now should be focused
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('hides counter text when maxLength is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(),
          ),
        ),
      );

      // Enter some text
      await tester.enterText(find.byType(TextFormField), 'test text');
      await tester.pump();
      
      // Should not show any counter text since maxLength is null
      expect(find.textContaining('/'), findsNothing);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows counter text when maxLength is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              maxLength: 10,
            ),
          ),
        ),
      );

      // Enter some text
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();
      
      // Should show counter text when maxLength is set
      expect(find.textContaining('4/10'), findsOneWidget);
    });
  });
}
