import 'package:flutter/material.dart';
import '../../data/repositories/robot_repository.dart';
import '../../data/model/robot.dart';

class RegisterRobotViewModel extends ChangeNotifier {
  final RobotRepository _repository;

  late TextEditingController robotNameController;
  late TextEditingController sensorNameController;
  late TextEditingController sensorQuantityController;
  late TextEditingController photoTransistorController;
  late TextEditingController motorNameController;
  late TextEditingController motorQuantityController;
  late TextEditingController motorDriverController;
  late TextEditingController microcontrollerNameController;

  bool _isLoading = false;
  String? _errorMessage;

  RegisterRobotViewModel(this._repository) {
    _initializeControllers();
    _loadRobotsAsync();
  }

  /// Initialize controllers synchronously to avoid LateInitializationError
  void _initializeControllers() {
    robotNameController = TextEditingController();
    sensorNameController = TextEditingController();
    sensorQuantityController = TextEditingController();
    photoTransistorController = TextEditingController();
    motorNameController = TextEditingController();
    motorQuantityController = TextEditingController();
    motorDriverController = TextEditingController();
    microcontrollerNameController = TextEditingController();
  }

  /// Load robots asynchronously without blocking initialization
  void _loadRobotsAsync() {
    _repository.ensureLoaded();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool _validateInputs() {
    if (robotNameController.text.isEmpty) {
      _errorMessage = 'Please enter robot name';
      return false;
    }
    if (sensorNameController.text.isEmpty) {
      _errorMessage = 'Please enter sensor name';
      return false;
    }
    if (sensorQuantityController.text.isEmpty ||
        int.tryParse(sensorQuantityController.text) == null) {
      _errorMessage = 'Please enter valid sensor quantity';
      return false;
    }
    if (photoTransistorController.text.isEmpty ||
        int.tryParse(photoTransistorController.text) == null) {
      _errorMessage = 'Please enter valid phototransistor count';
      return false;
    }
    if (motorNameController.text.isEmpty) {
      _errorMessage = 'Please enter motor name';
      return false;
    }
    if (motorQuantityController.text.isEmpty ||
        int.tryParse(motorQuantityController.text) == null) {
      _errorMessage = 'Please enter valid motor quantity';
      return false;
    }
    if (motorDriverController.text.isEmpty) {
      _errorMessage = 'Please enter motor driver';
      return false;
    }
    if (microcontrollerNameController.text.isEmpty) {
      _errorMessage = 'Please enter microcontroller name';
      return false;
    }
    return true;
  }

  Future<Robot?> registerRobot() async {
    _errorMessage = null;
    notifyListeners();

    if (!_validateInputs()) {
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final robot = Robot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: robotNameController.text,
        sensor: RobotSensor(
          name: sensorNameController.text,
          brand: sensorNameController.text,
          quantity: int.parse(sensorQuantityController.text),
          photoTransistorCount: int.parse(photoTransistorController.text),
        ),
        motor: RobotMotor(
          name: motorNameController.text,
          brand: motorNameController.text,
          quantity: int.parse(motorQuantityController.text),
          driver: motorDriverController.text,
        ),
        microcontroller: RobotMicrocontroller(
          name: microcontrollerNameController.text,
          brand: microcontrollerNameController.text,
        ),
      );

      await _repository.addRobot(robot);
      _isLoading = false;
      notifyListeners();
      return robot;
    } catch (e) {
      _errorMessage = 'Error registering robot: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearForm() {
    robotNameController.clear();
    sensorNameController.clear();
    sensorQuantityController.clear();
    photoTransistorController.clear();
    motorNameController.clear();
    motorQuantityController.clear();
    motorDriverController.clear();
    microcontrollerNameController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    robotNameController.dispose();
    sensorNameController.dispose();
    sensorQuantityController.dispose();
    photoTransistorController.dispose();
    motorNameController.dispose();
    motorQuantityController.dispose();
    motorDriverController.dispose();
    microcontrollerNameController.dispose();
    super.dispose();
  }
}
