import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

/// Interface for heart rate data source
abstract class HeartRateDataSource {
  /// Get a stream of heart rate data
  Stream<Map<String, dynamic>> getHeartRateStream();

  /// Start heart rate monitoring
  Future<bool> startHeartRateMonitoring();

  /// Stop heart rate monitoring
  Future<bool> stopHeartRateMonitoring();
}

/// Implementation of HeartRateDataSource that uses platform channels
class HeartRateDataSourceImpl implements HeartRateDataSource {
  /// Event channel for heart rate data
  final EventChannel _heartRateChannel =
      const EventChannel('com.example.heart_rate_assessment/heart_rate');

  /// Method channel for controlling heart rate monitoring
  final MethodChannel _heartRateControlChannel = const MethodChannel(
      'com.example.heart_rate_assessment/heart_rate_control');

  /// Stream controller for device status updates
  final _deviceStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of device status updates
  Stream<Map<String, dynamic>> get deviceStatusStream =>
      _deviceStatusController.stream;

  @override
  Stream<Map<String, dynamic>> getHeartRateStream() {
    developer.log('Starting heart rate stream', name: 'HeartRateDataSource');
    return _heartRateChannel.receiveBroadcastStream().map((dynamic event) {
      developer.log('Received data from native module: $event',
          name: 'HeartRateDataSource');

      // Properly convert the map instead of direct casting
      if (event is Map) {
        final convertedMap = <String, dynamic>{};
        event.forEach((key, value) {
          if (key is String) {
            convertedMap[key] = value;
          }
        });

        // Check if this is a heart rate or device status message
        final String? messageType = convertedMap['type'] as String?;

        // Forward device status messages to the status stream
        if (messageType == 'deviceStatus' || messageType == 'connectionIssue') {
          developer.log('Received device status: ${convertedMap['message']}',
              name: 'HeartRateDataSource');
          _deviceStatusController.add(convertedMap);

          // For connection issues, we'll also return them in the main stream
          // This allows the UI to react to connection problems
          if (messageType == 'connectionIssue') {
            developer.log('Forwarding connection issue to heart rate stream',
                name: 'HeartRateDataSource');
            return convertedMap;
          }

          // For regular device status updates, we filter them out of the main heart rate stream
          // We'll throw as a marker to filter this event
          throw const FormatException(
              'Status message - filter from heart rate stream');
        }

        // If it's a heart rate message or unknown type, forward it normally
        developer.log('Converted heart rate data: $convertedMap',
            name: 'HeartRateDataSource');
        return convertedMap;
      } else {
        throw FormatException('Received data is not a Map: $event');
      }
    }).handleError((error) {
      // Only forward real errors, not our filtering markers
      if (error is FormatException &&
          error.message.contains('Status message')) {
        // This is just a marker for filtering, not a real error
        developer.log('Filtering device status message from heart rate stream',
            name: 'HeartRateDataSource');
      } else {
        developer.log('Error in heart rate stream: $error',
            name: 'HeartRateDataSource', error: error);
        throw error;
      }
    }).where((event) {
      // Filter out non-heart rate events (those that don't have heart rate data)
      return event.containsKey('heartRate') ||
          (event['type'] == 'connectionIssue'); // Include connection issues
    });
  }

  @override
  Future<bool> startHeartRateMonitoring() async {
    try {
      developer.log('Starting heart rate monitoring',
          name: 'HeartRateDataSource');
      final result = await _heartRateControlChannel
          .invokeMethod<bool>('startHeartRateMonitoring');
      developer.log('Started heart rate monitoring: $result',
          name: 'HeartRateDataSource');
      return result ?? false;
    } on PlatformException catch (e) {
      developer.log('Platform error when starting monitoring: ${e.message}',
          name: 'HeartRateDataSource', error: e);
      return false;
    }
  }

  @override
  Future<bool> stopHeartRateMonitoring() async {
    try {
      developer.log('Stopping heart rate monitoring',
          name: 'HeartRateDataSource');
      final result = await _heartRateControlChannel
          .invokeMethod<bool>('stopHeartRateMonitoring');
      developer.log('Stopped heart rate monitoring: $result',
          name: 'HeartRateDataSource');
      return result ?? false;
    } on PlatformException catch (e) {
      developer.log('Platform error when stopping monitoring: ${e.message}',
          name: 'HeartRateDataSource', error: e);
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    _deviceStatusController.close();
  }
}
