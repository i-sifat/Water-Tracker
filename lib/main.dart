import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/providers/locale_provider.dart';
import 'package:watertracker/core/providers/theme_provider.dart';
import 'package:watertracker/core/theme/app_theme.dart';
import 'package:watertracker/features/home/home_screen.dart';
import 'package:watertracker/features/hydration/providers/hydration_provider.dart';
import 'package:watertracker/features/onboarding/screens/welcome_screen.dart';
import 'package:watertracker/features/premium/providers/premium_provider.dart';
import 'package:watertracker/features/premium/screens/donation_info_screen.dart';
import 'package:watertracker/features/premium/screens/donation_proof_screen.dart';
import 'package:watertracker/features/premium/screens/premium_success_screen.dart';
import 'package:watertracker/features/premium/screens/unlock_code_screen.dart';
import 'package:watertracker/features/settings/providers/settings_provider.dart';
import 'package:watertracker/features/settings/screens/settings_screen.dart';
import 'package:watertracker/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HydrationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initialize()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Water Tracker',
            
            // Localization support
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: localeProvider.locale,
            
            // Theme with accessibility support
            theme: themeProvider.isInitialized 
                ? AppTheme.lightTheme(
                    accessibilityService: themeProvider.accessibilityService,
                    textScaleFactor: themeProvider.textScaleFactor,
                  )
                : AppTheme.legacyLightTheme,
            darkTheme: themeProvider.isInitialized
                ? AppTheme.darkTheme(
                    accessibilityService: themeProvider.accessibilityService,
                    textScaleFactor: themeProvider.textScaleFactor,
                  )
                : AppTheme.legacyDarkTheme,
            themeMode: themeProvider.themeMode,
            
            // Accessibility settings
            debugShowCheckedModeBanner: false,
            
            home: const InitialScreen(),
            routes: {
              DonationInfoScreen.routeName: (context) => const DonationInfoScreen(),
              DonationProofScreen.routeName: (context) => const DonationProofScreen(),
              UnlockCodeScreen.routeName: (context) => const UnlockCodeScreen(),
              PremiumSuccessScreen.routeName: (context) => const PremiumSuccessScreen(),
              SettingsScreen.routeName: (context) => const SettingsScreen(),
            },
          );
        },
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
