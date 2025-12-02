import 'package:flutter/material.dart';

class WelcomeViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> initiateApp() async {
    _isLoading = true;
    notifyListeners();

    // Simulate initialization delay
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }
}
