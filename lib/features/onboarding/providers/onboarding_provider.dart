// lib/features/onboarding/providers/onboarding_provider.dart

import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  static const int totalPages = 10;
  final PageController pageController = PageController();
  int _currentPage = 1;

  int get currentPage => _currentPage;
  String get pageCounter => '$_currentPage of $totalPages';

  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
