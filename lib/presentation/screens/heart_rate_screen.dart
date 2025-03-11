import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/heart_rate_provider.dart';
import '../widgets/heart_rate_display.dart';
import '../widgets/monitoring_control.dart';
import '../../core/error/failures.dart';

/// Main screen for heart rate monitoring
class HeartRateScreen extends HookConsumerWidget {
  const HeartRateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the heart rate stream
    final heartRateStream = ref.watch(heartRateStreamProvider);

    // Watch the monitoring state
    final isMonitoring = ref.watch(heartRateMonitoringProvider);

    // Get the notifier for controlling monitoring
    final monitoringController = ref.read(heartRateMonitoringProvider.notifier);

    // Use a hook to handle the initial start of monitoring
    useEffect(() {
      // Start monitoring when the screen is first shown
      monitoringController.startMonitoring();

      // Stop monitoring when the screen is disposed
      return () {
        monitoringController.stopMonitoring();
      };
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heart rate display widget
            HeartRateDisplay(heartRateStream: heartRateStream),

            const SizedBox(height: 40),

            // Monitoring control widget
            MonitoringControl(
              isMonitoring: isMonitoring,
              onStartMonitoring: monitoringController.startMonitoring,
              onStopMonitoring: monitoringController.stopMonitoring,
            ),
          ],
        ),
      ),
    );
  }
}
