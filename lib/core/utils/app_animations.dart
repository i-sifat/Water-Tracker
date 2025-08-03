import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:watertracker/core/design_system/app_colors.dart';

/// Animation utilities for consistent interactions across the app
class AppAnimations {
  // Animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Animation curves
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOut;
  static const Curve quick = Curves.easeIn;

  /// Subtle scale animation for button interactions
  static Widget scaleOnTap({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
    Duration duration = fast,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(onTapDown: (_) => onTap(), child: child),
        );
      },
      child: child,
    );
  }

  /// Card selection animation with border and scale
  static Widget selectableCard({
    required Widget child,
    required bool isSelected,
    required VoidCallback onTap,
    Color? selectedColor,
    Color? unselectedColor,
    Duration duration = normal,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: smooth,
      decoration: BoxDecoration(
        color:
            isSelected
                ? (selectedColor ?? AppColors.selectedShade)
                : (unselectedColor ?? Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected
                  ? (selectedColor ?? AppColors.selectedBorder)
                  : AppColors.unselectedBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: (selectedColor ?? AppColors.selectedBorder)
                        .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedScale(
            duration: duration,
            scale: isSelected ? 1.02 : 1.0,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Button press animation
  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    bool isEnabled = true,
    Duration duration = fast,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: smooth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedScale(
            duration: duration,
            scale: isEnabled ? 1.0 : 0.95,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Slide transition animation for page navigation
  static Widget slideTransition({
    required Widget child,
    required bool isForward,
    Duration duration = normal,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween(begin: Offset(isForward ? 1.0 : -1.0, 0), end: Offset.zero),
      curve: smooth,
      builder: (context, offset, child) {
        return Transform.translate(offset: offset, child: child);
      },
      child: child,
    );
  }

  /// Fade in animation for content
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = smooth,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0, end: 1),
      curve: curve,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }

  /// Pulse animation for loading states
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.8, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  /// Bounce animation for success states
  static Widget bounceAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0, end: 1),
      curve: bounce,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  /// Shake animation for error states
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        final shake = math.sin(value * 10) * 5;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: child,
    );
  }

  /// Progress bar animation
  static Widget animatedProgressBar({
    required double progress,
    required double height,
    Color? backgroundColor,
    Color? progressColor,
    Duration duration = normal,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0, end: progress),
      curve: smooth,
      builder: (context, value, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.unselectedBorder,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor ?? AppColors.waterFull,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Checkmark animation for completion
  static Widget animatedCheckmark({
    required bool isVisible,
    Duration duration = normal,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: smooth,
      width: isVisible ? 24 : 0,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.waterFull,
        shape: BoxShape.circle,
      ),
      child:
          isVisible
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
    );
  }

  /// Text typing animation
  static Widget typingAnimation({
    required String text,
    Duration duration = const Duration(milliseconds: 2000),
    TextStyle? style,
  }) {
    return TweenAnimationBuilder<int>(
      duration: duration,
      tween: Tween(begin: 0, end: text.length),
      builder: (context, value, child) {
        return Text(text.substring(0, value), style: style);
      },
    );
  }
}

/// Page transition animations
class PageTransitions {
  /// Slide from right to left (forward navigation)
  static Route<dynamic> slideFromRight(Widget page) {
    return PageRouteBuilder<dynamic>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1, 0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Slide from left to right (backward navigation)
  static Route<dynamic> slideFromLeft(Widget page) {
    return PageRouteBuilder<dynamic>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1, 0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Fade transition
  static Route<dynamic> fade(Widget page) {
    return PageRouteBuilder<dynamic>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
