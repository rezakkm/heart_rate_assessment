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

  @override
  Stream<Map<String, dynamic>> getHeartRateStream() {
    developer.log('Starting heart rate stream', name: 'HeartRateDataSource');
    return _heartRateChannel.receiveBroadcastStream().map((dynamic event) {
      developer.log('Received heart rate data: $event',
          name: 'HeartRateDataSource');

      // Properly convert the map instead of direct casting
      if (event is Map) {
        final convertedMap = <String, dynamic>{};
        event.forEach((key, value) {
          if (key is String) {
            convertedMap[key] = value;
          }
        });
        developer.log('Converted map: $convertedMap',
            name: 'HeartRateDataSource');
        return convertedMap;
      } else {
        throw FormatException('Received data is not a Map: $event');
      }
    }).handleError((error) {
      developer.log('Error in heart rate stream: $error',
          name: 'HeartRateDataSource', error: error);
      throw error;
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
}
