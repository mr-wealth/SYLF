import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../control/ble_manager.dart';
import '../../data/model/robot.dart';
import '../viewmodels/robot_control_view_model.dart';

class RobotControlScreen extends StatelessWidget {
  final Robot robot;
  final BleManager bleManager;

  const RobotControlScreen({
    super.key,
    required this.robot,
    required this.bleManager,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RobotControlViewModel(bleManager),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1B3F3A),
          title: Text(
            'Controlando: ${robot.name}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
          ),
        ),
        body: Consumer<RobotControlViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Robot Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações do Robô',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Nome:', robot.name),
                          _buildInfoRow('Motor:', robot.motor.name),
                          _buildInfoRow('Sensor:', robot.sensor.name),
                          _buildInfoRow(
                            'Microcontroller:',
                            robot.microcontroller.name,
                          ),
                          if (robot.maxLeftValue != null)
                            _buildInfoRow(
                              'Max Esq:',
                              robot.maxLeftValue.toString(),
                            ),
                          if (robot.maxRightValue != null)
                            _buildInfoRow(
                              'Max Dir:',
                              robot.maxRightValue.toString(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Control Section
                  Text(
                    'Controlar Robô',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Direction Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDirectionButton(
                        context,
                        'Frente',
                        Icons.arrow_upward,
                        viewModel.isLoading,
                        () => viewModel.moveForward(),
                      ),
                      _buildDirectionButton(
                        context,
                        'Trás',
                        Icons.arrow_downward,
                        viewModel.isLoading,
                        () => viewModel.moveBackward(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDirectionButton(
                        context,
                        'Esquerda',
                        Icons.arrow_back,
                        viewModel.isLoading,
                        () => viewModel.moveLeft(),
                      ),
                      _buildDirectionButton(
                        context,
                        'Direita',
                        Icons.arrow_forward,
                        viewModel.isLoading,
                        () => viewModel.moveRight(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Start/Stop Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => viewModel.startRobot(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'INICIAR',
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => viewModel.stopRobot(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'PARAR',
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
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status/Error Messages
                  if (viewModel.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
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
                  if (viewModel.lastCommand != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Último comando: ${viewModel.lastCommand}',
                        style: TextStyle(color: Colors.blue.shade700),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDirectionButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isLoading,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C5F5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
