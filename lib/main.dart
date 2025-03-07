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
          fontFamily: 'Nunito', // Updated to Nunito
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Nunito'),
            displayMedium: TextStyle(fontFamily: 'Nunito'),
            displaySmall: TextStyle(fontFamily: 'Nunito'),
            headlineLarge: TextStyle(fontFamily: 'Nunito'),
            headlineMedium: TextStyle(fontFamily: 'Nunito'),
            headlineSmall: TextStyle(fontFamily: 'Nunito'),
            titleLarge: TextStyle(fontFamily: 'Nunito'),
            titleMedium: TextStyle(fontFamily: 'Nunito'),
            titleSmall: TextStyle(fontFamily: 'Nunito'),
            bodyLarge: TextStyle(fontFamily: 'Nunito'),
            bodyMedium: TextStyle(fontFamily: 'Nunito'),
            bodySmall: TextStyle(fontFamily: 'Nunito'),
            labelLarge: TextStyle(fontFamily: 'Nunito'),
            labelMedium: TextStyle(fontFamily: 'Nunito'),
            labelSmall: TextStyle(fontFamily: 'Nunito'),
          ),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}