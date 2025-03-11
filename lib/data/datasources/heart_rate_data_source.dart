import 'dart:async';
import 'package:flutter/services.dart';

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
    return _heartRateChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event as Map<String, dynamic>);
  }

  @override
  Future<bool> startHeartRateMonitoring() async {
    try {
      final result = await _heartRateControlChannel
          .invokeMethod<bool>('startHeartRateMonitoring');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> stopHeartRateMonitoring() async {
    try {
      final result = await _heartRateControlChannel
          .invokeMethod<bool>('stopHeartRateMonitoring');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
