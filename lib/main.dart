import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watertracker/core/providers/locale_provider.dart';
import 'package:watertracker/core/providers/theme_provider.dart';
import 'package:watertracker/core/services/performance_service.dart';
import 'package:watertracker/core/theme/app_theme.dart';
import 'package:watertracker/core/utils/image_optimization.dart';
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

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize performance monitoring
  PerformanceService().initialize();
  
  // Initialize image optimization
  ImageOptimization.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Optimize system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
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
            onGenerateRoute: (settings) {
              // Use optimized transitions for better performance
              switch (settings.name) {
                case DonationInfoScreen.routeName:
                  return PageRouteBuilder<void>(
                    settings: settings,
                    pageBuilder: (context, animation, secondaryAnimation) => const DonationInfoScreen(),
                    transitionDuration: const Duration(milliseconds: 200),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: child,
                      );
                    },
                  );
                case DonationProofScreen.routeName:
                case UnlockCodeScreen.routeName:
                case PremiumSuccessScreen.routeName:
                  return PageRouteBuilder<void>(
                    settings: settings,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      switch (settings.name) {
                        case DonationProofScreen.routeName:
                          return const DonationProofScreen();
                        case UnlockCodeScreen.routeName:
                          return const UnlockCodeScreen();
                        case PremiumSuccessScreen.routeName:
                          return const PremiumSuccessScreen();
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                    transitionDuration: const Duration(milliseconds: 250),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return ScaleTransition(
                        scale: animation.drive(
                          Tween(begin: 0.8, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeOutBack)),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                  );
                case SettingsScreen.routeName:
                  return PageRouteBuilder<void>(
                    settings: settings,
                    pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
                    transitionDuration: const Duration(milliseconds: 150),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
                        child: child,
                      );
                    },
                  );
                default:
                  return null;
              }
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

class _InitialScreenState extends State<InitialScreen> with PerformanceMonitorMixin {
  @override
  void initState() {
    super.initState();
    startPerformanceTimer('app_startup');
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      // Use cached SharedPreferences instance if available
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (!mounted) return;

      endPerformanceTimer('app_startup');

      // Use immediate navigation without animation for faster startup
      if (onboardingCompleted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during app startup: $e');
      // Fallback to welcome screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
