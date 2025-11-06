import 'package:flutter/material.dart';
import 'bleControl/ble_manager.dart';
import 'ui/scan_screen.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  final BleManager bleManager = BleManager();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE Robot Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScanScreen(bleManager: bleManager),
    );
  }
}