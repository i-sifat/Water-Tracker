import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watertracker/bloc/water_bloc.dart';
import 'package:watertracker/ui/widgets/primary_button.dart';
import 'package:watertracker/ui/widgets/secondary_button.dart';

class ConsumptionDialog extends StatefulWidget {
  const ConsumptionDialog({super.key});

  @override
  ConsumptionDialogState createState() => ConsumptionDialogState();
}

class ConsumptionDialogState extends State<ConsumptionDialog> {
  final _form = GlobalKey<FormState>();
  String? _text;

  String? _validateText(String? value) {
    if (value == null || value.isEmpty) {
      return "2000 ml minimum";
    }

    final number = int.tryParse(value);
    if (number != null && number >= 2000) {
      return null;
    }

    return "2000 ml minimum";
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WaterBloc>();
    return AlertDialog(
      title: const Text(
        "Daily consumption",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Change your daily water consumption goal, in milliliters.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextFormField(
              maxLength: 4,
              initialValue: bloc.state.recommendedMilliliters.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _text = value,
              validator: _validateText,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                hintText: "2000 ml",
                counterText: "",
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () {
                if (_form.currentState?.validate() ?? false) {
                  _form.currentState?.save();
                  FocusScope.of(context).unfocus();
                  if (_text != null) {
                    context.read<WaterBloc>().setRecommendedMilliliters(
                          int.parse(_text!),
                        );
                  }
                  Navigator.of(context).pop();
                }
              },
              title: "Confirm",
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              onPressed: () => Navigator.of(context).pop(),
              title: "Cancel",
            ),
          ],
        ),
      ),
    );
  }
}