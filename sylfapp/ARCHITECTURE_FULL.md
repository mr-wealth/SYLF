# SYLF App - Complete Architecture Diagram

## Full App MVVM Flow with All Screens

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           <<main.dart>>                                         │
│                              MyApp                                              │
│                    (Provider setup + routing)                                   │
└──────────────────────────────┬──────────────────────────────────────────────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
                ▼                             ▼
        ┌──────────────────┐        ┌─────────────────────┐
        │  WelcomeScreen   │        │ WelcomeViewModel    │
        │   (splash)       │◄──────►│  (initialization)   │
        └────────┬─────────┘        └─────────────────────┘
                 │
                 │ Navigate to RegisterRobotScreen
                 ▼
        ┌──────────────────────────────┐        ┌──────────────────────────┐
        │  RegisterRobotScreen         │        │ RegisterRobotViewModel   │
        │  (form: name, sensor,        │◄──────►│  (form validation,       │
        │   motor, microcontroller)    │        │   robot creation)        │
        └────────┬─────────────────────┘        └────────┬─────────────────┘
                 │                                       │
                 │ passes Robot object                   │
                 │                                       ▼
                 │                            ┌─────────────────────────┐
                 │                            │  RobotRepository        │
                 │                            │  (singleton, caching)   │
                 │                            └────────┬────────────────┘
                 │                                     │
                 │                                     ▼
                 │                            ┌─────────────────────────┐
                 │                            │RobotPersistenceService  │
                 │                            │ (JSON ↔ SharedPrefs)    │
                 │                            └─────────────────────────┘
                 │
                 ▼
        ┌──────────────────────────────┐        ┌──────────────────────────┐
        │  ScanRobotScreen             │        │ ScanRobotViewModel       │
        │  (BLE device scan/filter)    │◄──────►│  (scan mgmt, filtering)  │
        └────────┬─────────────────────┘        └────────┬─────────────────┘
                 │                                       │
                 │ passes Robot & selected device        │
                 │                                       ▼
                 │                            ┌─────────────────────────┐
                 │                            │     BleManager          │
                 │                            │  (scan, connect,        │
                 │                            │   write commands,       │
                 │                            │   characteristic        │
                 │                            │   discovery)            │
                 │                            └─────────────────────────┘
                 │                                     ▲ ▲
                 │                                     │ │
                 │                    ┌────────────────┘ │
                 │                    │                  │
                 ▼                    │                  │
        ┌──────────────────────────────────────────────┐ │
        │  InitializeRobotScreen                       │ │
        │  (calibration: max left/right values)        │─┘
        └────────┬─────────────────────────────────────┘
                 │
                 │ passes Robot with calibration data
                 │
                 ▼
        ┌──────────────────────────────┐        ┌──────────────────────────┐
        │  RobotControlScreen          │        │ RobotControlViewModel    │
        │  (forward/back/left/right,   │◄──────►│  (movement commands,     │
        │   start/stop)                │        │   start/stop logic)      │
        └──────────────────────────────┘        └────────┬─────────────────┘
                        ▲                               │
                        │                               │
                        └───────────────────────────────┘
                                   (uses BleManager 
                                   to send commands 
                                   to ESP32)


┌─────────────────────────────────────────────────────────────────────────────────┐
│                          CONTROL LAYER & DATA LAYER                             │
└─────────────────────────────────────────────────────────────────────────────────┘

                            ┌──────────────────────┐
                            │   BleManager         │
                            │ (lib/control/)       │
                            │                      │
                            │ • startScan()        │
                            │ • stopScan()         │
                            │ • connectToDevice()  │
                            │ • writeCommand()     │
                            │ • disconnect()       │
                            │ • scanResults()      │
                            │   (stream)           │
                            └──────────────────────┘
                                     ▲
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
                    ▼                                 ▼
           ┌─────────────────────┐         ┌─────────────────────┐
           │  ScanRobotViewModel │         │RobotControlViewModel│
           │  (listens to scan   │         │  (sends movement    │
           │   results)          │         │   commands)         │
           └─────────────────────┘         └─────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────┐
│                              DATA PERSISTENCE FLOW                              │
└─────────────────────────────────────────────────────────────────────────────────┘

           ┌─────────────────────────────────────────────────────┐
           │          RobotRepository (Singleton)                │
           │  • getRobots()                                      │
           │  • addRobot(Robot)                                  │
           │  • updateRobot(Robot)                               │
           │  • deleteRobot(id)                                  │
           │  • ensureLoaded()                                   │
           └──────────────────┬──────────────────────────────────┘
                              │
                              ▼
           ┌──────────────────────────────────────────┐
           │  RobotPersistenceService (Static)        │
           │  • saveRobots(List<Robot>)               │
           │  • loadRobots() -> List<Robot>           │
           │  • clearRobots()                         │
           │  (JSON serialization)                    │
           └──────────────────┬───────────────────────┘
                              │
                              ▼
           ┌──────────────────────────────────────────┐
           │   SharedPreferences (Device Storage)     │
           │   (JSON string @ key: 'registered_robots')
           └──────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────┐
│                               MODEL (DATA CLASSES)                              │
└─────────────────────────────────────────────────────────────────────────────────┘

        ┌──────────────────────────────────────────────────────┐
        │              Robot (lib/data/model/)                 │
        │  • id: String                                        │
        │  • name: String                                      │
        │  • sensor: RobotSensor                               │
        │  • motor: RobotMotor                                 │
        │  • microcontroller: RobotMicrocontroller             │
        │  • maxLeftValue: int?                                │
        │  • maxRightValue: int?                               │
        │  • copyWith(): Robot (immutability support)          │
        └──────────────────┬───────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┬────────────────┐
        │                  │                  │                │
        ▼                  ▼                  ▼                ▼
   ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐
   │RobotSensor  │  │RobotMotor    │  │RobotMicrocontro-│
   │             │  │              │  │ller              │
   │ • name      │  │ • name       │  │ • name           │
   │ • brand     │  │ • brand      │  │ • brand          │
   │ • quantity  │  │ • quantity   │  │                  │
   │ • photoTx   │  │ • driver     │  │                  │
   │   Count     │  │              │  │                  │
   │ • copyWith()│  │ • copyWith() │  │ • copyWith()     │
   └─────────────┘  └──────────────┘  └──────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────┐
│                            FOLDER STRUCTURE SUMMARY                             │
└─────────────────────────────────────────────────────────────────────────────────┘

lib/
├── main.dart                          # App entry, routing setup
├── core/
│   └── theme.dart                     # Centralized styling
├── control/
│   └── ble_manager.dart               # BLE scanning, connection, commands
├── data/
│   ├── model/
│   │   └── robot.dart                 # Robot, RobotSensor, RobotMotor,
│   │                                  # RobotMicrocontroller (immutable models)
│   ├── repositories/
│   │   └── robot_repository.dart      # Singleton repository (caching + CRUD)
│   └── services/
│       └── robot_persistence_service.dart  # SharedPreferences JSON serialization
└── presentation/
    ├── screens/
    │   ├── welcome_screen.dart
    │   ├── register_robot_screen.dart
    │   ├── scan_robot_screen.dart
    │   ├── initialize_robot_screen.dart
    │   └── robot_control_screen.dart
    ├── viewmodels/
    │   ├── welcome_view_model.dart
    │   ├── register_robot_view_model.dart
    │   ├── scan_robot_view_model.dart
    │   ├── initialize_robot_view_model.dart
    │   └── robot_control_view_model.dart
    └── widgets/
        └── sylf_logo.dart              # Custom logo widget


┌─────────────────────────────────────────────────────────────────────────────────┐
│                              DEPENDENCY INJECTION                               │
└─────────────────────────────────────────────────────────────────────────────────┘

Each screen creates its ViewModel(s) via Provider.ChangeNotifierProvider:

  WelcomeScreen
    └─► create: WelcomeViewModel()

  RegisterRobotScreen
    └─► create: RegisterRobotViewModel(RobotRepository())

  ScanRobotScreen
    └─► create: ScanRobotViewModel(RobotRepository(), BleManager(), 
                                   registeredRobot: Robot)

  InitializeRobotScreen
    └─► create: InitializeRobotViewModel(RobotRepository(), robot: Robot)

  RobotControlScreen
    └─► create: RobotControlViewModel(BleManager(), robot: Robot)


┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DATA FLOW EXAMPLE: REGISTER FLOW                      │
└─────────────────────────────────────────────────────────────────────────────────┘

1. User fills form in RegisterRobotScreen
   ↓
2. Taps CADASTRAR button → RegisterRobotViewModel.registerRobot()
   ↓
3. ViewModel validates input
   ↓
4. ViewModel creates Robot object with form data
   ↓
5. ViewModel calls RobotRepository.addRobot(robot)
   ↓
6. Repository stores robot in memory (_robots list)
   ↓
7. Repository calls RobotPersistenceService.saveRobots(_robots)
   ↓
8. Service serializes Robot → JSON via copyWith() pattern
   ↓
9. Service saves JSON string to SharedPreferences
   ↓
10. ViewModel navigates to ScanRobotScreen with Robot object
    ↓
11. User searches for device and connects via BleManager
    ↓
12. On successful connection, navigate to InitializeRobotScreen
    ↓
13. User enters calibration values, ViewModel updates Robot via copyWith()
    ↓
14. ViewModel calls RobotRepository.updateRobot(calibratedRobot)
    ↓
15. Repository persists updated Robot to SharedPreferences
    ↓
16. Navigate to RobotControlScreen for movement/control


┌─────────────────────────────────────────────────────────────────────────────────┐
│                         KEY ARCHITECTURAL DECISIONS                             │
└─────────────────────────────────────────────────────────────────────────────────┘

✓ MVVM Pattern
  - Clean separation: View (screens) ↔ ViewModel (logic) ↔ Model (data)
  - Each screen has a dedicated ViewModel for state & business logic

✓ Singleton Repository
  - RobotRepository as singleton ensures single source of truth
  - Cached in memory; persisted to SharedPreferences

✓ Immutable Models (copyWith)
  - Robot & component models are immutable (final fields)
  - copyWith() provides clean way to create modified instances
  - Predictable state updates (no accidental mutations)

✓ Provider for State Management
  - ChangeNotifier + Provider enables reactive UI updates
  - Scoped to each screen via ChangeNotifierProvider
  - Clean dependency injection

✓ BleManager as Control Layer
  - Separates BLE logic from UI (screens) and business logic (viewmodels)
  - Provides high-level API: scan, connect, writeCommand
  - Auto-discovers writable characteristics (no hardcoding)

✓ JSON Persistence
  - SharedPreferences for lightweight, offline-first storage
  - Manual JSON serialization via copyWith-friendly format
  - Easy migration path to ORM (Hive, Drift) later if needed

