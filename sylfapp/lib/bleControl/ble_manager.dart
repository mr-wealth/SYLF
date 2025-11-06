import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleManager {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? commandCharacteristic;

  // Stream of scanned devices
  Stream<List<ScanResult>> scanResults() => FlutterBluePlus.scanResults;

  // Start scanning for devices
  void startScan() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
  }

  // Stop scanning
  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // Connect to device by deviceId
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(license: License.free);
    connectedDevice = device;

    // Discover services and find the command characteristic UUID (replace with your own)
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var char in service.characteristics) {
        // Use your characteristic UUID for robot commands here
        if (char.uuid.toString() == "12846e86-430a-45e8-890b-ae81d3bc49d3") {
          commandCharacteristic = char;
          await commandCharacteristic!.setNotifyValue(true); // Enables notifications if needed
        }
      }
    }
  }

  // Disconnect device
  Future<void> disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      commandCharacteristic = null;
    }
  }

  // Write command to characteristic (e.g., start/stop robot)
  Future<void> writeCommand(List<int> data) async {
    if (commandCharacteristic != null) {
      await commandCharacteristic!.write(data, withoutResponse: false);
    }
  }
}
