import 'package:flutter/material.dart';
import '../../data/repositories/robot_repository.dart';
import '../../data/model/robot.dart';

class InitializeRobotViewModel extends ChangeNotifier {
  final RobotRepository _repository;

  Robot? _robot;
  late TextEditingController maxLeftValueController;
  late TextEditingController maxRightValueController;
  bool _isLoading = false;
  String? _errorMessage;

  InitializeRobotViewModel(this._repository, Robot initialRobot) {
    _robot = initialRobot;
    _initializeControllers();
  }

  void _initializeControllers() {
    maxLeftValueController = TextEditingController();
    maxRightValueController = TextEditingController();
  }

  Robot? get robot => _robot;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool _validateInputs() {
    if (maxLeftValueController.text.isEmpty ||
        int.tryParse(maxLeftValueController.text) == null) {
      _errorMessage = 'Please enter valid max left value';
      return false;
    }
    if (maxRightValueController.text.isEmpty ||
        int.tryParse(maxRightValueController.text) == null) {
      _errorMessage = 'Please enter valid max right value';
      return false;
    }
    return true;
  }

  Future<bool> calibrateRobot() async {
    _errorMessage = null;
    notifyListeners();

    if (!_validateInputs()) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_robot == null) {
        _errorMessage = 'No robot selected';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedRobot = _robot!.copyWith(
        maxLeftValue: int.parse(maxLeftValueController.text),
        maxRightValue: int.parse(maxRightValueController.text),
      );

      await _repository.updateRobot(updatedRobot);
      _robot = updatedRobot;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error calibrating robot: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setRobot(Robot robot) {
    _robot = robot;
    notifyListeners();
  }

  @override
  void dispose() {
    maxLeftValueController.dispose();
    maxRightValueController.dispose();
    super.dispose();
  }
}
