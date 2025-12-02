import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Manages Bluetooth Low Energy connections and communication with ESP32 robot.
class BleManager {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? commandCharacteristic;
  List<BluetoothService>? discoveredServices;

  // Stream of scanned devices
  Stream<List<ScanResult>> scanResults() => FlutterBluePlus.scanResults;

  // Start scanning for devices
  void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  // Stop scanning
  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  /// Connect to device and auto-discover a writable characteristic.
  /// Attempts to find the first writable characteristic to use for commands.
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(license: License.free);
    connectedDevice = device;

    // Discover services and characteristics
    discoveredServices = await device.discoverServices();
    
    // Auto-detect a writable characteristic for commands
    for (var service in discoveredServices!) {
      for (var char in service.characteristics) {
        // Prioritize characteristics that support write operations
        if (char.properties.write || char.properties.writeWithoutResponse) {
          commandCharacteristic = char;
          // Try to enable notifications if the characteristic supports it
          if (char.properties.notify) {
            try {
              await commandCharacteristic!.setNotifyValue(true);
            } catch (e) {
              // Ignore if notifications aren't supported
            }
          }
          return; // Use the first writable characteristic found
        }
      }
    }
    
    // If no writable characteristic found, log a warning
    print('Warning: No writable characteristic found on device');
  }

  /// Get list of discovered service UUIDs (for debugging/matching)
  List<String>? getDiscoveredServiceUuids() {
    if (discoveredServices == null) return null;
    return discoveredServices!.map((s) => s.uuid.toString()).toList();
  }

  /// Disconnect device
  Future<void> disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      commandCharacteristic = null;
      discoveredServices = null;
    }
  }

  /// Write command to the discovered characteristic
  /// Returns true if write was successful, false otherwise
  Future<bool> writeCommand(List<int> data) async {
    if (commandCharacteristic == null) {
      print('Error: No command characteristic available');
      return false;
    }
    try {
      await commandCharacteristic!.write(data, withoutResponse: false);
      return true;
    } catch (e) {
      print('Error writing command: $e');
      return false;
    }
  }

  /// Check if a device is currently connected
  bool get isConnected => connectedDevice != null;

  /// Get the currently connected device
  BluetoothDevice? get getConnectedDevice => connectedDevice;
}
