import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sylfapp/data/model/robot.dart';
import 'package:sylfapp/data/services/robot_persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Ensure SharedPreferences is mocked for tests
    SharedPreferences.setMockInitialValues({});
  });

  test('Robot copyWith updates specific fields and preserves others', () {
    final sensor = RobotSensor(
      name: 'SensorA',
      brand: 'BrandX',
      quantity: 4,
      photoTransistorCount: 4,
    );

    final motor = RobotMotor(
      name: 'MotorA',
      brand: 'MotorBrand',
      quantity: 2,
      driver: 'L298',
    );

    final mcu = RobotMicrocontroller(name: 'ESP32', brand: 'Espressif');

    final robot = Robot(
      id: 'r1',
      name: 'SYLF',
      sensor: sensor,
      motor: motor,
      microcontroller: mcu,
    );

    final updated = robot.copyWith(name: 'SYLF v2', maxLeftValue: 200);

    expect(updated.name, equals('SYLF v2'));
    expect(updated.id, equals(robot.id));
    expect(updated.sensor.name, equals(sensor.name));
    expect(updated.maxLeftValue, equals(200));
  });

  test('RobotPersistenceService saves and loads robots (roundtrip)', () async {
    final sensor = RobotSensor(
      name: 'SensorA',
      brand: 'BrandX',
      quantity: 4,
      photoTransistorCount: 4,
    );

    final motor = RobotMotor(
      name: 'MotorA',
      brand: 'MotorBrand',
      quantity: 2,
      driver: 'L298',
    );

    final mcu = RobotMicrocontroller(name: 'ESP32', brand: 'Espressif');

    final robot = Robot(
      id: 'r2',
      name: 'TestBot',
      sensor: sensor,
      motor: motor,
      microcontroller: mcu,
      maxLeftValue: 123,
      maxRightValue: 456,
    );

    // Save
    await RobotPersistenceService.saveRobots([robot]);

    // Load
    final loaded = await RobotPersistenceService.loadRobots();

    expect(loaded, isNotNull);
    expect(loaded.length, equals(1));
    final r = loaded.first;
    expect(r.id, equals(robot.id));
    expect(r.name, equals(robot.name));
    expect(r.maxLeftValue, equals(123));
    expect(r.maxRightValue, equals(456));
    expect(r.sensor.photoTransistorCount, equals(sensor.photoTransistorCount));
  });
}
