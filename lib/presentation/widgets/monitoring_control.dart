import 'package:flutter/material.dart';

/// Widget to control heart rate monitoring
class MonitoringControl extends StatelessWidget {
  final bool isMonitoring;
  final VoidCallback onStartMonitoring;
  final VoidCallback onStopMonitoring;

  const MonitoringControl({
    Key? key,
    required this.isMonitoring,
    required this.onStartMonitoring,
    required this.onStopMonitoring,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isMonitoring ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isMonitoring ? onStopMonitoring : onStartMonitoring,
          style: ElevatedButton.styleFrom(
            backgroundColor: isMonitoring ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMonitoring ? Icons.stop : Icons.play_arrow,
              ),
              const SizedBox(width: 8),
              Text(
                isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
