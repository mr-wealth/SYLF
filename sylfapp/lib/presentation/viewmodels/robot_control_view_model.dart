import 'package:flutter/material.dart';
import '../../control/ble_manager.dart';

class RobotControlViewModel extends ChangeNotifier {
  final BleManager _bleManager;

  bool _isLoading = false;
  String? _errorMessage;
  String? _lastCommand;

  RobotControlViewModel(this._bleManager);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastCommand => _lastCommand;

  /// Command codes (customize these based on your ESP32 protocol)
  static const int cmdStart = 0x01;
  static const int cmdStop = 0x00;
  static const int cmdForward = 0x10;
  static const int cmdBackward = 0x11;
  static const int cmdLeft = 0x12;
  static const int cmdRight = 0x13;

  Future<void> _sendCommand(List<int> data, String label) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _bleManager.writeCommand(data);
      if (success) {
        _lastCommand = label;
      } else {
        _errorMessage = 'Falha ao enviar comando: $label';
      }
    } catch (e) {
      _errorMessage = 'Erro: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startRobot() async {
    await _sendCommand([cmdStart], 'Iniciar');
  }

  Future<void> stopRobot() async {
    await _sendCommand([cmdStop], 'Parar');
  }

  Future<void> moveForward() async {
    await _sendCommand([cmdForward], 'Frente');
  }

  Future<void> moveBackward() async {
    await _sendCommand([cmdBackward], 'Trás');
  }

  Future<void> moveLeft() async {
    await _sendCommand([cmdLeft], 'Esquerda');
  }

  Future<void> moveRight() async {
    await _sendCommand([cmdRight], 'Direita');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
