// Animation file for hydration tracker
// This file contains all the animation logic separated from the UI components

import 'package:flutter/material.dart';

// Class to manage all animations for the hydration screen
class HydrationAnimations {
  // Animation controller that coordinates all animations
  late AnimationController _controller;

  // Scale animation for the circle
  late Animation<double> circleAnimation;

  // Slide animations for the buttons in each row
  late Animation<Offset> firstRowLeftSlideAnimation;
  late Animation<Offset> firstRowRightSlideAnimation;
  late Animation<Offset> secondRowLeftSlideAnimation;
  late Animation<Offset> secondRowRightSlideAnimation;

  // Constructor needs a TickerProvider (usually the State object with SingleTickerProviderStateMixin)
  HydrationAnimations({required TickerProvider vsync}) {
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    // Set up the animations
    _setupAnimations();
  }

  // Configure all the animations
  void _setupAnimations() {
    // Circle animation that scales up the progress indicator
    circleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Slide animations for the first row buttons
    firstRowLeftSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Start from left outside the screen
      end: Offset.zero, // End at normal position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.3,
          0.7,
          curve: Curves.easeOut,
        ), // Animate in specific time interval
      ),
    );

    firstRowRightSlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0), // Start from right outside the screen
      end: Offset.zero, // End at normal position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.3,
          0.7,
          curve: Curves.easeOut,
        ), // Animate in specific time interval
      ),
    );

    // Slide animations for the second row buttons
    secondRowLeftSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Start from left outside the screen
      end: Offset.zero, // End at normal position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.5,
          0.9,
          curve: Curves.easeOut,
        ), // Animate slightly later
      ),
    );

    secondRowRightSlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0), // Start from right outside the screen
      end: Offset.zero, // End at normal position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.5,
          0.9,
          curve: Curves.easeOut,
        ), // Animate slightly later
      ),
    );
  }

  // Start all animations
  void startAnimations() {
    _controller.forward();
  }

  // Clean up resources when no longer needed
  void dispose() {
    _controller.dispose();
  }
}
