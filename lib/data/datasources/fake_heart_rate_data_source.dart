import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'heart_rate_data_source.dart';

/// Implementation of HeartRateDataSource that generates fake data within Flutter
/// without relying on platform channels
class FakeHeartRateDataSource implements HeartRateDataSource {
  // Heart rate ranges
  static const int minNormalHeartRate = 60;
  static const int maxNormalHeartRate = 100;

  // Add abnormal ranges
  static const int minLowHeartRate = 40;
  static const int maxLowHeartRate = 59;
  static const int minElevatedHeartRate = 101;
  static const int maxElevatedHeartRate = 130;
  static const int minHighHeartRate = 131;
  static const int maxHighHeartRate = 180;

  // Update interval
  static const int updateIntervalMs = 3000; // 3 seconds

  StreamController<Map<String, dynamic>>? _streamController;
  Timer? _timer;
  bool _isMonitoring = false;

  // Heart rate distribution for generating realistic data
  // We'll mostly generate normal heart rates, with occasional abnormal values
  final List<_HeartRateRange> _heartRateDistribution = [
    _HeartRateRange(
        minLowHeartRate, maxLowHeartRate, 0.1), // 10% chance of low heart rate
    _HeartRateRange(minNormalHeartRate, maxNormalHeartRate,
        0.6), // 60% chance of normal heart rate
    _HeartRateRange(minElevatedHeartRate, maxElevatedHeartRate,
        0.2), // 20% chance of elevated heart rate
    _HeartRateRange(minHighHeartRate, maxHighHeartRate,
        0.1), // 10% chance of high heart rate
  ];

  @override
  Stream<Map<String, dynamic>> getHeartRateStream() {
    developer.log('Starting fake heart rate stream',
        name: 'FakeHeartRateDataSource');

    if (_streamController == null || _streamController!.isClosed) {
      _streamController = StreamController<Map<String, dynamic>>.broadcast(
        onListen: () {
          developer.log('Stream now has listeners',
              name: 'FakeHeartRateDataSource');
          if (!_isMonitoring) {
            startHeartRateMonitoring();
          }
        },
        onCancel: () {
          developer.log('Stream has no more listeners',
              name: 'FakeHeartRateDataSource');
          stopHeartRateMonitoring();
        },
      );
    }

    return _streamController!.stream;
  }

  @override
  Future<bool> startHeartRateMonitoring() async {
    developer.log('Starting fake heart rate monitoring',
        name: 'FakeHeartRateDataSource');

    if (_isMonitoring) {
      return true; // Already monitoring
    }

    _isMonitoring = true;

    // Generate initial heart rate immediately
    _generateAndSendHeartRate();

    // Start timer for periodic updates
    _timer = Timer.periodic(
      const Duration(milliseconds: updateIntervalMs),
      (_) => _generateAndSendHeartRate(),
    );

    return true;
  }

  @override
  Future<bool> stopHeartRateMonitoring() async {
    developer.log('Stopping fake heart rate monitoring',
        name: 'FakeHeartRateDataSource');

    _isMonitoring = false;
    _timer?.cancel();
    _timer = null;

    return true;
  }

  void _generateAndSendHeartRate() {
    if (_streamController == null ||
        _streamController!.isClosed ||
        !_isMonitoring) {
      return;
    }

    // Generate a heart rate according to our distribution
    final heartRate = _getRandomHeartRateFromDistribution();

    // Create the data package like the native modules would
    final heartRateData = <String, dynamic>{
      'heartRate': heartRate,
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
    };

    developer.log('Generated fake heart rate: $heartRate BPM',
        name: 'FakeHeartRateDataSource');

    // Send the data
    _streamController!.add(heartRateData);
  }

  int _getRandomHeartRateFromDistribution() {
    // Choose a range based on probability
    final random = Random();
    double cumulativeProbability = 0.0;
    final randomValue = random.nextDouble();

    for (final range in _heartRateDistribution) {
      cumulativeProbability += range.probability;
      if (randomValue <= cumulativeProbability) {
        // Generate a value within this range
        return range.min + random.nextInt(range.max - range.min + 1);
      }
    }

    // Fallback to normal range
    return minNormalHeartRate +
        random.nextInt(maxNormalHeartRate - minNormalHeartRate + 1);
  }

  // For testing - simulate an error
  void simulateError() {
    developer.log('Simulating error in heart rate monitoring',
        name: 'FakeHeartRateDataSource');
    if (_streamController != null && !_streamController!.isClosed) {
      _streamController!.addError(Exception('Simulated heart rate error'));
    }
  }
}

/// Helper class for creating heart rate ranges with probability weights
class _HeartRateRange {
  final int min;
  final int max;
  final double probability;

  _HeartRateRange(this.min, this.max, this.probability);
}
