import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/robot.dart';

class RobotPersistenceService {
  static const String _robotsKey = 'registered_robots';

  /// Save robots to local storage
  static Future<void> saveRobots(List<Robot> robots) async {
    final prefs = await SharedPreferences.getInstance();
    final robotsJson = robots.map((r) => _robotToJson(r)).toList();
    await prefs.setString(_robotsKey, jsonEncode(robotsJson));
  }

  /// Load robots from local storage
  static Future<List<Robot>> loadRobots() async {
    final prefs = await SharedPreferences.getInstance();
    final robotsString = prefs.getString(_robotsKey);
    if (robotsString == null) return [];
    
    try {
      final robotsList = jsonDecode(robotsString) as List;
      return robotsList.map((r) => _robotFromJson(r)).toList();
    } catch (e) {
      print('Error loading robots: $e');
      return [];
    }
  }

  /// Clear all saved robots
  static Future<void> clearRobots() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_robotsKey);
  }

  static Map<String, dynamic> _robotToJson(Robot robot) {
    return {
      'id': robot.id,
      'name': robot.name,
      'sensor': {
        'name': robot.sensor.name,
        'brand': robot.sensor.brand,
        'quantity': robot.sensor.quantity,
        'photoTransistorCount': robot.sensor.photoTransistorCount,
      },
      'motor': {
        'name': robot.motor.name,
        'brand': robot.motor.brand,
        'quantity': robot.motor.quantity,
        'driver': robot.motor.driver,
      },
      'microcontroller': {
        'name': robot.microcontroller.name,
        'brand': robot.microcontroller.brand,
      },
      'maxLeftValue': robot.maxLeftValue,
      'maxRightValue': robot.maxRightValue,
    };
  }

  static Robot _robotFromJson(dynamic json) {
    return Robot(
      id: json['id'] as String,
      name: json['name'] as String,
      sensor: RobotSensor(
        name: json['sensor']['name'] as String,
        brand: json['sensor']['brand'] as String,
        quantity: json['sensor']['quantity'] as int,
        photoTransistorCount: json['sensor']['photoTransistorCount'] as int,
      ),
      motor: RobotMotor(
        name: json['motor']['name'] as String,
        brand: json['motor']['brand'] as String,
        quantity: json['motor']['quantity'] as int,
        driver: json['motor']['driver'] as String,
      ),
      microcontroller: RobotMicrocontroller(
        name: json['microcontroller']['name'] as String,
        brand: json['microcontroller']['brand'] as String,
      ),
      maxLeftValue: json['maxLeftValue'] as int?,
      maxRightValue: json['maxRightValue'] as int?,
    );
  }
}
