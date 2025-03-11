import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:heart_rate_assessment/data/datasources/heart_rate_data_source.dart';
import 'package:heart_rate_assessment/domain/entities/heart_rate_entity.dart';

/// A local implementation of HeartRateDataSource that generates fake data
/// This can be used for testing, development, or as a fallback when native sensors are unavailable
class LocalHeartRateDataSource implements HeartRateDataSource {
  final Random _random = Random();
  StreamController<Map<String, dynamic>>? _controller;
  Timer? _timer;
  bool _isMonitoring = false;

  // Parameters to control the heart rate generation
  final Duration updateInterval;
  final int minRate;
  final int maxRate;
  final bool simulateAbnormalReadings;
  final double abnormalReadingProbability;

  LocalHeartRateDataSource({
    this.updateInterval = const Duration(seconds: 1),
    this.minRate = 60,
    this.maxRate = 100,
    this.simulateAbnormalReadings = true,
    this.abnormalReadingProbability = 0.2,
  });

  @override
  Future<bool> checkHeartRateSensorAvailability() async {
    // Local data source is always available
    return true;
  }

  @override
  Stream<Map<String, dynamic>> getHeartRateStream() {
    developer.log('Getting local heart rate stream',
        name: 'LocalHeartRateDataSource');
    if (_controller == null || _controller!.isClosed) {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _controller!.stream;
  }

  @override
  Future<bool> startHeartRateMonitoring() async {
    developer.log('Starting local heart rate monitoring',
        name: 'LocalHeartRateDataSource');
    if (_isMonitoring) return true;

    _isMonitoring = true;
    _generateHeartRateData();
    return true;
  }

  @override
  Future<bool> stopHeartRateMonitoring() async {
    developer.log('Stopping local heart rate monitoring',
        name: 'LocalHeartRateDataSource');
    if (!_isMonitoring) return true;

    _isMonitoring = false;
    _timer?.cancel();
    _timer = null;

    // Do not close the controller here, as consumers might still be listening
    // Just stop adding new events
    return true;
  }

  // Generate fake heart rate data
  void _generateHeartRateData() {
    _timer?.cancel();

    _timer = Timer.periodic(updateInterval, (timer) {
      if (!_isMonitoring || _controller == null || _controller!.isClosed) {
        timer.cancel();
        return;
      }

      final heartRate = _generateHeartRateValue();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();

      final data = <String, dynamic>{
        'heartRate': heartRate,
        'timestamp': timestamp,
      };

      developer.log('Generated local heart rate: $heartRate',
          name: 'LocalHeartRateDataSource');
      _controller!.add(data);
    });
  }

  // Generate a heart rate value based on parameters
  int _generateHeartRateValue() {
    // Decide if we should generate an abnormal reading
    if (simulateAbnormalReadings &&
        _random.nextDouble() < abnormalReadingProbability) {
      // Generate an abnormal reading (either very low or very high)
      if (_random.nextBool()) {
        // Low heart rate (40-59)
        return 40 + _random.nextInt(20);
      } else {
        // Choose between elevated, high, or critical
        final abnormalCategory = _random.nextInt(3);
        if (abnormalCategory == 0) {
          // Elevated (101-130)
          return 101 + _random.nextInt(30);
        } else if (abnormalCategory == 1) {
          // High (131-180)
          return 131 + _random.nextInt(50);
        } else {
          // Critical (181-220)
          return 181 + _random.nextInt(40);
        }
      }
    } else {
      // Generate a normal heart rate within the specified range
      return minRate + _random.nextInt(maxRate - minRate + 1);
    }
  }
}
