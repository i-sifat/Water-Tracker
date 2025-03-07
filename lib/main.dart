import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/onboarding/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HydrationProvider(),
      child: MaterialApp(
        title: 'Water Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily:
              'Poppins', // Make sure you have this font or replace with your app font
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
