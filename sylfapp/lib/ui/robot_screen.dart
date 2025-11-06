import 'package:flutter/material.dart';
import '../ble/ble_manager.dart';

class RobotScreen extends StatelessWidget{
  final BleManager bleManager;

  const RobotScreen({super.key, required this.bleManager});

  void sendStartCommand(){
    //example command bytes; modify to robot's protocol
    bleManager.writeCommand([0x01]); //start
  }

  void sendStopCommand(){
    bleManager.writeCommand(([0x00])); //stop
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Robot Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: sendStartCommand, child: Text('Start Robot'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: sendStopCommand,
            child: Text('Stop Robot'),
            ),
          ],
        ),
      ),
    );
  }
}