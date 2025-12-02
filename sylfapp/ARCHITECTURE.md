# SYLF App - MVVM Architecture Implementation

## Overview

The SYLF (See Your Line Follower) app has been built following the **MVVM (Model-View-ViewModel)** architecture pattern, which is the recommended approach for Flutter applications. This architecture provides better separation of concerns, improved testability, and easier maintenance.

## Architecture Structure

```
lib/
├── core/
│   └── theme.dart                    # Centralized theme configuration
├── data/
│   ├── robot.dart                    # Data models (Robot, Sensor, Motor, Microcontroller)
│   └── repositories/
│       └── robot_repository.dart     # Data access layer for robots
├── presentation/
│   ├── screens/
│   │   ├── welcome_screen.dart       # Welcome/Splash screen
│   │   ├── register_robot_screen.dart # Robot registration screen
│   │   ├── initialize_robot_screen.dart # Robot calibration screen
│   │   └── scan_robot_screen.dart    # Robot scanning/connection screen
│   ├── viewmodels/
│   │   ├── welcome_view_model.dart
│   │   ├── register_robot_view_model.dart
│   │   ├── initialize_robot_view_model.dart
│   │   └── scan_robot_view_model.dart
│   └── widgets/                      # Reusable UI components (future expansion)
└── main.dart
```

## MVVM Pattern Explanation

### 1. **Model Layer** (`data/`)

**Models** represent the data structure of your application.

- **Robot.dart**: Contains data classes for:
  - `Robot`: Main robot entity with properties like name, sensor, motor, microcontroller, and calibration values
  - `RobotSensor`: Sensor specifications (name, brand, quantity, phototransistor count)
  - `RobotMotor`: Motor specifications (name, brand, quantity, driver)
  - `RobotMicrocontroller`: Microcontroller specifications (name, brand)

Each model includes:
- Constructor with required parameters
- `copyWith()` method for creating modified copies (immutability pattern)

**Repository Pattern**: `RobotRepository` provides an abstraction layer for data access:
- `addRobot()`: Register a new robot
- `getRobotById()`: Fetch a specific robot
- `updateRobot()`: Update robot data
- `deleteRobot()`: Remove a robot
- `getRobots()`: Get all registered robots

### 2. **ViewModel Layer** (`presentation/viewmodels/`)

**ViewModels** contain business logic and state management for the UI. They:
- Extend `ChangeNotifier` for reactive state management
- Handle user interactions
- Communicate with repositories
- Provide data and methods to the UI layer
- Notify listeners when state changes

#### Key ViewModels:

**WelcomeViewModel**
- Handles app initialization
- Manages loading state

**RegisterRobotViewModel**
- Manages robot registration form state
- TextEditingControllers for all input fields
- Input validation logic
- Communicates with repository to save robot data

**InitializeRobotViewModel**
- Handles robot calibration
- Manages max left/right value inputs
- Updates robot with calibration data

**ScanRobotViewModel**
- Manages available robots list
- Handles robot connection attempts
- Manages scanning state

### 3. **View Layer** (`presentation/screens/`)

**Screens** (Views) display the UI and respond to user interactions:

**WelcomeScreen**
- Displays SYLF logo and tagline
- INICIAR button navigates to registration

**RegisterRobotScreen**
- Form for entering robot details
- Input fields organized by section (Sensor, Motor, Microcontroller)
- Form validation with error messaging
- CADASTRAR button triggers registration

**InitializeRobotScreen**
- Displays robot name
- Calibration section with max value inputs
- CALIBRAR button initiates calibration
- Progress feedback for user actions

**ScanRobotScreen**
- Lists available robots
- CONECTAR button for each robot
- ESCANEAR button to refresh the list
- PRÓXIMO button to proceed (enabled when robot is connected)

## Key Design Patterns

### 1. **Provider Pattern for State Management**
- Uses the `provider` package for reactive state management
- `ChangeNotifier` base classes notify UI of state changes
- `Consumer` widgets rebuild when ViewModel state changes

### 2. **Repository Pattern**
- Abstracts data access logic
- Makes it easy to switch between different data sources
- Provides clean API for ViewModels

### 3. **Immutability**
- Models use `copyWith()` for creating new instances instead of modifying existing ones
- Prevents unintended side effects

### 4. **Separation of Concerns**
- UI logic (Screens) is separate from business logic (ViewModels)
- Business logic is separate from data access (Repository)
- Easy to test each layer independently

## Navigation Flow

1. **Welcome Screen** → "INICIAR" button
2. **Register Robot Screen** → "CADASTRAR" button (after validation)
3. **Initialize Robot Screen** → "CALIBRAR" button (after entering max values)
4. **Scan Robot Screen** → Select and connect to a robot → "PRÓXIMO" button

## Theme System

**`core/theme.dart`** provides centralized theme configuration:
- Primary color: `#4DB8A8` (teal)
- Primary dark color: `#2C5F5A` (dark teal)
- Background color: `#1B3F3A` (dark slate)

Benefits:
- Consistent styling across the app
- Easy color scheme updates
- Centralized button, input, and AppBar styling

## State Management with Provider

### How it Works:

1. **Creating a ViewModel**:
```dart
ChangeNotifierProvider(
  create: (_) => RegisterRobotViewModel(RobotRepository()),
  child: RegisterRobotScreen(),
)
```

2. **Consuming ViewModel in UI**:
```dart
Consumer<RegisterRobotViewModel>(
  builder: (context, viewModel, _) {
    return TextField(
      controller: viewModel.robotNameController,
    );
  },
)
```

3. **Notifying Changes**:
When data changes, the ViewModel calls `notifyListeners()` to trigger UI rebuilds.

## Next Steps for Enhancement

1. **Add BLE Integration**: Connect `ScanRobotViewModel` to actual BLE scanning
2. **Create Control Screen**: Add a new screen for robot control (after connection)
3. **Add Persistence**: Integrate SQLite or SharedPreferences for local storage
4. **Error Handling**: Implement comprehensive error handling and user feedback
5. **Unit Tests**: Add tests for each ViewModel
6. **UI Widgets**: Create reusable custom widgets in `presentation/widgets/`

## Running the App

```bash
flutter pub get
flutter run
```

## Dependencies

- `flutter`: Core framework
- `provider`: ^6.0.0 - State management
- `flutter_blue_plus`: ^2.0.0 - Bluetooth connectivity
- `cupertino_icons`: ^1.0.8 - Icon library

---

**Created**: December 2, 2025
**Pattern**: MVVM with Provider
**Status**: Initial implementation complete, ready for enhancement
