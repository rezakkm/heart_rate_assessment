import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:developer' as developer;

import '../providers/heart_rate_provider.dart';
import '../widgets/heart_rate_display.dart';
import '../widgets/monitoring_control.dart';

/// Main screen for heart rate monitoring
class HeartRateScreen extends HookConsumerWidget {
  const HeartRateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building HeartRateScreen', name: 'HeartRateScreen');

    // Watch the heart rate stream
    final heartRateStream = ref.watch(heartRateStreamProvider);

    // Watch the monitoring state
    final isMonitoring = ref.watch(heartRateMonitoringProvider);

    // Get the notifier for controlling monitoring
    final monitoringController = ref.read(heartRateMonitoringProvider.notifier);

    // Use a hook to handle the initial start of monitoring
    useEffect(() {
      // Start monitoring when the screen is first shown
      Future.microtask(() async {
        await monitoringController.startMonitoring();
      });

      // Stop monitoring when the screen is disposed
      return () {
        monitoringController.stopMonitoring();
      };
    }, const []);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Heart Monitor',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              // Show info/help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Heart Monitor'),
                  content: const Text(
                    'This app monitors your heart rate in real-time. '
                    'The data is collected from your connected heart rate monitor device.',
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isMonitoring
                          ? Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.15)
                          : Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMonitoring
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMonitoring ? Icons.wifi : Icons.wifi_off,
                          color: isMonitoring
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isMonitoring
                              ? 'Monitoring Active'
                              : 'Monitoring Inactive',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isMonitoring
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Heart rate display widget
                  HeartRateDisplay(heartRateStream: heartRateStream),

                  const SizedBox(height: 32),

                  // Monitoring control widget (with updated design)
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monitoring Controls',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isMonitoring
                                      ? null
                                      : () {
                                          monitoringController
                                              .startMonitoring();
                                        },
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text('Start'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Theme.of(context)
                                        .colorScheme
                                        .tertiary
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: !isMonitoring
                                      ? null
                                      : () {
                                          monitoringController.stopMonitoring();
                                        },
                                  icon: const Icon(Icons.stop_rounded),
                                  label: const Text('Stop'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Force a restart of the monitoring
                                monitoringController.stopMonitoring().then((_) {
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    monitoringController.startMonitoring();
                                  });
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Refresh Connection'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
