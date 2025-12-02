import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../control/ble_manager.dart';
import '../../data/repositories/robot_repository.dart';
import '../../data/model/robot.dart';

class ScanRobotViewModel extends ChangeNotifier {
  final RobotRepository _repository;
  final BleManager _bleManager;
  final Robot? registeredRobot;

  List<Robot> _availableRobots = [];
  List<ScanResult> _scanResults = [];
  ScanResult? _selectedResult;
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<ScanResult>>? _scanSub;

  ScanRobotViewModel(this._repository, this._bleManager, {this.registeredRobot}) {
    _loadAvailableRobots();
    _loadRobotsAsync();
  }

  /// Load robots asynchronously without blocking initialization
  void _loadRobotsAsync() {
    _repository.ensureLoaded();
  }

  List<Robot> get availableRobots => _availableRobots;
  List<ScanResult> get scanResults => _scanResults;
  ScanResult? get selectedResult => _selectedResult;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _loadAvailableRobots() {
    _availableRobots = _repository.getRobots();
    notifyListeners();
  }

  /// Start scanning using the BleManager. Results are delivered via the
  /// BleManager.scanResults() stream and stored here for the UI.
  void startScan() {
    _errorMessage = null;
    _isScanning = true;
    notifyListeners();

    _scanSub?.cancel();
    _scanSub = _bleManager.scanResults().listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    _bleManager.startScan();
  }

  void stopScan() {
    _bleManager.stopScan();
    _scanSub?.cancel();
    _scanSub = null;
    _isScanning = false;
    notifyListeners();
  }

  void selectResult(ScanResult result) {
    _selectedResult = result;
    notifyListeners();
  }

  Future<bool> connectToScanResult(ScanResult result) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _bleManager.connectToDevice(result.device);
      _connectedDevice = result.device;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to connect: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearSelection() {
    _selectedResult = null;
    _connectedDevice = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    super.dispose();
  }
}
