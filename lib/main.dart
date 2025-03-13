import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/onboarding/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HydrationProvider())],
      child: MaterialApp(
        title: 'Water Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Nunito',
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
        home: const InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!mounted) return;

    if (onboardingCompleted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
      );
    } else {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
