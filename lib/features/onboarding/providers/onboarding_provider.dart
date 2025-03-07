import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  static const int totalPages = 17;
  int _currentPage = 1;

  int get currentPage => _currentPage;
  String get pageCounter => '$_currentPage of $totalPages';

  void setPage(int page) {
    if (page != _currentPage && page > 0 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }
}