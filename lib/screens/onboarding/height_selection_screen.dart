import 'package:flutter/material.dart';
import 'package:watertracker/screens/onboarding/custom-button.dart';

class HeightSelectionScreen extends StatefulWidget {
  const HeightSelectionScreen({Key? key}) : super(key: key);

  @override
  State<HeightSelectionScreen> createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Height Selection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Height Selection Screen'),
            CustomButton(
              text: 'Continue',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WeatherSelectionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
