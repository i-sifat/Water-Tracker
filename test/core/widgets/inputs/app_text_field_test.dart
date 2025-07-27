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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.hintText, equals(hintText));
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.helperText, equals(helperText));
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.errorText, equals(errorText));
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
      bool wasTapped = false;

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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.readOnly, isTrue);
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.maxLines, equals(maxLines));
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.maxLength, equals(maxLength));
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.keyboardType, equals(keyboardType));
    });

    testWidgets('respects textInputAction property', (WidgetTester tester) async {
      const textInputAction = TextInputAction.search;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              textInputAction: textInputAction,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.textInputAction, equals(textInputAction));
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.textCapitalization, equals(textCapitalization));
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.inputFormatters, equals(inputFormatters));
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.autofocus, isTrue);
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.focusNode, equals(focusNode));
    });

    testWidgets('hides counter text when maxLength is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.counterText, equals(''));
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

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.counterText, isNull); // Default behavior when maxLength is set
    });
  });
}