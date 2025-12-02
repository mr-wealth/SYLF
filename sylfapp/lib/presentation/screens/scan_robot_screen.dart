import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../control/ble_manager.dart';
import '../../data/repositories/robot_repository.dart';
import '../../data/model/robot.dart';
import '../viewmodels/scan_robot_view_model.dart';
import 'initialize_robot_screen.dart';

class ScanRobotScreen extends StatelessWidget {
  final Robot registeredRobot;

  const ScanRobotScreen({super.key, required this.registeredRobot});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScanRobotViewModel>(
      create: (_) => ScanRobotViewModel(
        RobotRepository(),
        BleManager(),
        registeredRobot: registeredRobot,
      ),
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
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Consumer<ScanRobotViewModel>(
                builder: (context, viewModel, _) {
                  return ElevatedButton(
                    onPressed: viewModel.isScanning
                        ? () => viewModel.stopScan()
                        : () => viewModel.startScan(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5F5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      viewModel.isScanning ? 'PARAR' : 'ESCANEAR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Consumer<ScanRobotViewModel>(
          builder: (context, viewModel, _) {
            final results = viewModel.scanResults
              .where((r) {
                final name = r.device.name.isNotEmpty
                  ? r.device.name
                  : r.advertisementData.localName;
                return name.toLowerCase().contains(
                  viewModel.registeredRobot?.name.toLowerCase() ?? '');
              })
              .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Procurando por: ${registeredRobot.name}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bluetooth_searching,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                viewModel.isScanning
                                    ? 'Procurando dispositivos...'
                                    : 'Nenhum dispositivo encontrado',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final r = results[index];
                            final deviceName = r.device.name.isNotEmpty
                              ? r.device.name
                              : r.advertisementData.localName;
                            final id = r.device.id.id;
                            final services = r.advertisementData.serviceUuids;

                            final isSelected = viewModel.selectedResult == r;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                deviceName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'ID: $id',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: viewModel.isLoading
                                              ? null
                                              : () => viewModel.selectResult(r),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF2C5F5A),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            isSelected ? 'DETALHES' : 'VER',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'Service UUIDs: ${services.isNotEmpty ? services.join(', ') : 'Nenhum'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: viewModel.isLoading
                                                ? null
                                                : () async {
                                                    final success = await viewModel.connectToScanResult(r);
                                                    if (success && context.mounted) {
                                                      viewModel.stopScan();
                                                      Navigator.of(context).pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (context) => InitializeRobotScreen(robot: registeredRobot),
                                                        ),
                                                      );
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF2C5F5A),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: viewModel.isLoading
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<Color>(
                                                              Colors.white),
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(
                                                    'CONECTAR',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              viewModel.clearSelection();
                                            },
                                            child: const Text('FECHAR'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
