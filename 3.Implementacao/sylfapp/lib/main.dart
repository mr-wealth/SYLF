import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {
  runApp(MaterialApp(home: RobotControlApp()));
}

class RobotControlApp extends StatefulWidget {
  @override
  _RobotControlAppState createState() => _RobotControlAppState();
}

class _RobotControlAppState extends State<RobotControlApp> {
  final flutterReactiveBle = FlutterReactiveBle();

  // Your ESP32 BLE Service and Characteristic UUIDs (must match ESP32 firmware).
  final Uuid serviceUuid = Uuid.parse("6c8efc7e-2877-453b-b989-701aa7daa2a6");
  final Uuid characteristicUuid = Uuid.parse("d6188064-6d49-4cbe-baa7-36efa04354c9");

  bool isScanning = false;
  List<DiscoveredDevice> scanResults = [];
  DiscoveredDevice? connectedDevice;
  QualifiedCharacteristic? robotCharacteristic;

  StreamSubscription<ConnectionStateUpdate>? connectionSubscription;
  StreamSubscription<List<int>>? notificationSubscription;

  String sensorData = "No sensor data";

  @override
  void dispose() {
    connectionSubscription?.cancel();
    notificationSubscription?.cancel();
    flutterReactiveBle.deinitialize();
    super.dispose();
  }

  // Start scanning for devices advertising your service UUID
  void startScan() {
    scanResults.clear();
    setState(() {
      isScanning = true;
    });

    flutterReactiveBle.scanForDevices(withServices: [serviceUuid]).listen((device) {
      if (!scanResults.any((d) => d.id == device.id)) {
        setState(() {
          scanResults.add(device);
        });
      }
    }, onError: (e) {
      print("Scan error: $e");
      setState(() {
        isScanning = false;
      });
    });

    // Stop scanning after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      flutterReactiveBle.deinitialize();
      setState(() {
        isScanning = false;
      });
    });
  }

  // Connect to the selected device and setup characteristic for comms
  void connect(DiscoveredDevice device) {
    connectionSubscription = flutterReactiveBle.connectToDevice(id: device.id).listen(
      (update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          setState(() {
            connectedDevice = device;
            robotCharacteristic = QualifiedCharacteristic(
              characteristicId: characteristicUuid,
              serviceId: serviceUuid,
              deviceId: device.id,
            );
          });
          subscribeSensorNotifications();
          print("Connected to device ${device.name}");
        } else if (update.connectionState == DeviceConnectionState.disconnected) {
          setState(() {
            connectedDevice = null;
            robotCharacteristic = null;
            sensorData = "No sensor data";
          });
          notificationSubscription?.cancel();
          print("Disconnected");
        }
      },
      onError: (error) {
        print("Connection error: $error");
        setState(() {
          connectedDevice = null;
          robotCharacteristic = null;
          sensorData = "No sensor data";
          notificationSubscription?.cancel();
        });
      },
    );
  }

  // Subscribe to notifications for sensor data from ESP32
  void subscribeSensorNotifications() {
    if (robotCharacteristic == null) return;

    notificationSubscription = flutterReactiveBle
        .subscribeToCharacteristic(robotCharacteristic!)
        .listen((data) {
      final decoded = utf8.decode(data);
      setState(() {
        sensorData = decoded;
      });
      print("Received sensor data: $decoded");
    }, onError: (error) {
      print("Notification error: $error");
    });
  }

  // Send a text command to ESP32 (e.g., "LED ON", "LED OFF")
  Future<void> sendCommand(String command) async {
    if (robotCharacteristic == null) return;

    try {
      final bytes = utf8.encode(command);
      await flutterReactiveBle.writeCharacteristicWithResponse(robotCharacteristic!, value: bytes);
      print("Sent command: $command");
    } catch (e) {
      print("Write error: $e");
    }
  }

  // Disconnect from current device
  void disconnect() {
    connectionSubscription?.cancel();
    notificationSubscription?.cancel();
    setState(() {
      connectedDevice = null;
      robotCharacteristic = null;
      sensorData = "No sensor data";
      scanResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ESP32 Robotics Control")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: connectedDevice == null ? buildScanUI() : buildControlUI(),
      ),
    );
  }

  // UI to scan and list nearby ESP32 devices advertising your service
  Widget buildScanUI() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isScanning ? null : startScan,
          child: Text(isScanning ? "Scanning..." : "Scan for Robot"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: scanResults.length,
            itemBuilder: (context, index) {
              final device = scanResults[index];
              return ListTile(
                title: Text(device.name.isNotEmpty ? device.name : "Unknown Device"),
                subtitle: Text(device.id),
                onTap: () => connect(device),
              );
            },
          ),
        ),
      ],
    );
  }

  // UI to control robot once connected: sensor data display and command buttons
  Widget buildControlUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Connected to: ${connectedDevice!.name}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 20),
        Text("Sensor Data:", style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        Text(sensorData, style: TextStyle(fontSize: 24, color: Colors.blueAccent)),
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => sendCommand("LED ON"), child: Text("Turn LED ON")),
            SizedBox(width: 20),
            ElevatedButton(onPressed: () => sendCommand("LED OFF"), child: Text("Turn LED OFF")),
          ],
        ),
        SizedBox(height: 40),
        ElevatedButton(onPressed: disconnect, child: Text("Disconnect")),
      ],
    );
  }
}
