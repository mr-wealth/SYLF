import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../ble/ble_manager.dart';
import 'robot_screen.dart';

class ScanScreen extends StatefulWidget {
  final BleManager bleManager;

   const ScanScreen({super.key, required this.bleManager});

  @override
  _ScanScreenState createState()=> _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> devices = [];

  @override
  void initState(){
    super.initState();
    widget.bleManager.startScan();
    widget.bleManager.scanResults().listen((results){
      setState(() {
        devices = results;
      });
    });
  }

  @override
  void dispose(){
    widget.bleManager.stopScan();
    super.dispose();
  }

  void connectDevice(ScanResult result) async {
    await widget.bleManager.connectToDevice(result.device);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RobotScreen(bleManager: widget.bleManager)),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Scan BLE Devices')),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index){
          var device = devices[index].device;
          return ListTile(
            title: Text(device.platformName.isNotEmpty ? device.platformName : 'Unknown Device'),
            subtitle: Text(device.remoteId.str),
            onTap: () => connectDevice(devices[index]),
          );
        },
        ),
    );
  }
}