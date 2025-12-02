import '../model/robot.dart';
import '../services/robot_persistence_service.dart';

/// Simple in-memory singleton repository for Robots with persistence.
/// Using a singleton makes it easy to share registered robots
/// across screens without wiring an application-level provider yet.
class RobotRepository {
  RobotRepository._internal();

  static final RobotRepository _instance = RobotRepository._internal();

  factory RobotRepository() => _instance;

  final List<Robot> _robots = [];
  bool _loaded = false;

  /// Load robots from local storage if not already loaded
  Future<void> ensureLoaded() async {
    if (!_loaded) {
      _robots.addAll(await RobotPersistenceService.loadRobots());
      _loaded = true;
    }
  }

  List<Robot> getRobots() => List.unmodifiable(_robots);

  Future<void> addRobot(Robot robot) async {
    await ensureLoaded();
    _robots.add(robot);
    await RobotPersistenceService.saveRobots(_robots);
  }

  Future<Robot?> getRobotById(String id) async {
    await ensureLoaded();
    try {
      return _robots.firstWhere((robot) => robot.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateRobot(Robot robot) async {
    await ensureLoaded();
    final index = _robots.indexWhere((r) => r.id == robot.id);
    if (index != -1) {
      _robots[index] = robot;
      await RobotPersistenceService.saveRobots(_robots);
    }
  }

  Future<void> deleteRobot(String id) async {
    await ensureLoaded();
    _robots.removeWhere((robot) => robot.id == id);
    await RobotPersistenceService.saveRobots(_robots);
  }

  Future<void> clearRobots() async {
    _robots.clear();
    await RobotPersistenceService.clearRobots();
  }
}
