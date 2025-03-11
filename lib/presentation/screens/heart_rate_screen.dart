import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:developer' as developer;

import '../providers/heart_rate_provider.dart';
import '../widgets/heart_rate_display.dart';
import '../widgets/monitoring_control.dart';
import '../../core/error/failures.dart';

/// Main screen for heart rate monitoring
class HeartRateScreen extends HookConsumerWidget {
  const HeartRateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building HeartRateScreen', name: 'HeartRateScreen');

    // Watch the heart rate stream
    final heartRateStream = ref.watch(heartRateStreamProvider);
    developer.log(
        'Heart rate stream state: ${heartRateStream.valueOrNull != null ? "has value" : "no value yet"}',
        name: 'HeartRateScreen');

    // Watch the monitoring state
    final isMonitoring = ref.watch(heartRateMonitoringProvider);
    developer.log('Monitoring state: $isMonitoring', name: 'HeartRateScreen');

    // Get the notifier for controlling monitoring
    final monitoringController = ref.read(heartRateMonitoringProvider.notifier);

    // Use a hook to handle the initial start of monitoring
    useEffect(() {
      developer.log('HeartRateScreen mounted, starting monitoring',
          name: 'HeartRateScreen');

      // Start monitoring when the screen is first shown
      Future.microtask(() async {
        developer.log('Starting heart rate monitoring (screen init)',
            name: 'HeartRateScreen');
        await monitoringController.startMonitoring();
        developer.log('Monitoring started from screen init',
            name: 'HeartRateScreen');
      });

      // Stop monitoring when the screen is disposed
      return () {
        developer.log('HeartRateScreen disposing, stopping monitoring',
            name: 'HeartRateScreen');
        monitoringController.stopMonitoring();
      };
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Diagnostic info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          'Monitoring Status: ${isMonitoring ? "Active" : "Inactive"}',
                          style: TextStyle(
                            color: isMonitoring ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stream Status: ${heartRateStream.valueOrNull != null ? "Receiving Data" : "Awaiting Data"}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Heart rate display widget
                HeartRateDisplay(heartRateStream: heartRateStream),

                const SizedBox(height: 40),

                // Monitoring control widget
                MonitoringControl(
                  isMonitoring: isMonitoring,
                  onStartMonitoring: () {
                    developer.log('Start monitoring button pressed',
                        name: 'HeartRateScreen');
                    monitoringController.startMonitoring();
                  },
                  onStopMonitoring: () {
                    developer.log('Stop monitoring button pressed',
                        name: 'HeartRateScreen');
                    monitoringController.stopMonitoring();
                  },
                ),

                const SizedBox(height: 20),

                // Manual refresh button
                ElevatedButton.icon(
                  onPressed: () {
                    developer.log('Manual refresh requested',
                        name: 'HeartRateScreen');
                    // Force a restart of the monitoring
                    monitoringController.stopMonitoring().then((_) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        monitoringController.startMonitoring();
                      });
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Force Refresh'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
