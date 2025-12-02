class RobotSensor {
  final String name;
  final String brand;
  final int quantity;
  final int photoTransistorCount;

  RobotSensor({
    required this.name,
    required this.brand,
    required this.quantity,
    required this.photoTransistorCount,
  });

  RobotSensor copyWith({
    String? name,
    String? brand,
    int? quantity,
    int? photoTransistorCount,
  }) {
    return RobotSensor(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      photoTransistorCount: photoTransistorCount ?? this.photoTransistorCount,
    );
  }
}

class RobotMotor {
  final String name;
  final String brand;
  final int quantity;
  final String driver;

  RobotMotor({
    required this.name,
    required this.brand,
    required this.quantity,
    required this.driver,
  });

  RobotMotor copyWith({
    String? name,
    String? brand,
    int? quantity,
    String? driver,
  }) {
    return RobotMotor(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      driver: driver ?? this.driver,
    );
  }
}

class RobotMicrocontroller {
  final String name;
  final String brand;

  RobotMicrocontroller({
    required this.name,
    required this.brand,
  });

  RobotMicrocontroller copyWith({
    String? name,
    String? brand,
  }) {
    return RobotMicrocontroller(
      name: name ?? this.name,
      brand: brand ?? this.brand,
    );
  }
}

class Robot {
  final String id;
  final String name;
  final RobotSensor sensor;
  final RobotMotor motor;
  final RobotMicrocontroller microcontroller;
  final int? maxLeftValue;
  final int? maxRightValue;

  Robot({
    required this.id,
    required this.name,
    required this.sensor,
    required this.motor,
    required this.microcontroller,
    this.maxLeftValue,
    this.maxRightValue,
  });

  Robot copyWith({
    String? id,
    String? name,
    RobotSensor? sensor,
    RobotMotor? motor,
    RobotMicrocontroller? microcontroller,
    int? maxLeftValue,
    int? maxRightValue,
  }) {
    return Robot(
      id: id ?? this.id,
      name: name ?? this.name,
      sensor: sensor ?? this.sensor,
      motor: motor ?? this.motor,
      microcontroller: microcontroller ?? this.microcontroller,
      maxLeftValue: maxLeftValue ?? this.maxLeftValue,
      maxRightValue: maxRightValue ?? this.maxRightValue,
    );
  }
}
