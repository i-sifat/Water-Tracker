import 'package:flutter/material.dart';
import 'package:watertracker/core/utils/app_animations.dart';

class PageTransitions {
  // Slide transition from right
  static Route<T> slideFromRight<T extends Object?>(Widget page) {
    return AppAnimations.slideTransition<T>(
      page,
    );
  }

  // Slide transition from left
  static Route<T> slideFromLeft<T extends Object?>(Widget page) {
    return AppAnimations.slideTransition<T>(
      page,
      begin: const Offset(-1, 0),
    );
  }

  // Slide transition from bottom
  static Route<T> slideFromBottom<T extends Object?>(Widget page) {
    return AppAnimations.slideTransition<T>(
      page,
      begin: const Offset(0, 1),
    );
  }

  // Fade transition
  static Route<T> fade<T extends Object?>(Widget page) {
    return AppAnimations.fadeTransition<T>(page);
  }

  // Scale transition with bounce
  static Route<T> scaleWithBounce<T extends Object?>(Widget page) {
    return AppAnimations.scaleTransition<T>(
      page,
    );
  }

  // Custom transition for onboarding screens
  static Route<T> onboardingTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Combine slide and fade
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1, curve: Curves.easeIn),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

// Extension to make navigation easier
extension NavigationExtensions on NavigatorState {
  Future<T?> pushWithSlideFromRight<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.slideFromRight<T>(page));
  }

  Future<T?> pushWithSlideFromLeft<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.slideFromLeft<T>(page));
  }

  Future<T?> pushWithSlideFromBottom<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.slideFromBottom<T>(page));
  }

  Future<T?> pushWithFade<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.fade<T>(page));
  }

  Future<T?> pushWithScale<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.scaleWithBounce<T>(page));
  }

  Future<T?> pushOnboarding<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.onboardingTransition<T>(page));
  }

  Future<T?> pushReplacementWithSlideFromRight<T extends Object?, TO extends Object?>(Widget page) {
    return pushReplacement<T, TO>(PageTransitions.slideFromRight<T>(page));
  }

  Future<T?> pushReplacementWithFade<T extends Object?, TO extends Object?>(Widget page) {
    return pushReplacement<T, TO>(PageTransitions.fade<T>(page));
  }
}