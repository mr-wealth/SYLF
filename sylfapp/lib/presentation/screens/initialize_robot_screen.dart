import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../control/ble_manager.dart';
import '../../data/model/robot.dart';
import '../../data/repositories/robot_repository.dart';
import '../viewmodels/initialize_robot_view_model.dart';
import 'robot_control_screen.dart';

class InitializeRobotScreen extends StatelessWidget {
  final Robot robot;

  const InitializeRobotScreen({super.key, required this.robot});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InitializeRobotViewModel(RobotRepository(), robot),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1B3F3A),
          title: Text(
            'SYLF',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
          ),
        ),
        body: Consumer<InitializeRobotViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Robot Name as Title
                  Text(
                    robot.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Robot Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      size: 80,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CALIBRAR Button
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              final success = await viewModel.calibrateRobot();
                              if (context.mounted && success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Calibração concluída')),
                                );
                                // Navigate to robot control screen
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => RobotControlScreen(
                                      robot: robot,
                                      bleManager: BleManager(),
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5F5A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'CALIBRAR',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Max Values Section
                  Text(
                    'Valores de máximo:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: viewModel.maxLeftValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: viewModel.maxRightValueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Message
                  if (viewModel.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        viewModel.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
