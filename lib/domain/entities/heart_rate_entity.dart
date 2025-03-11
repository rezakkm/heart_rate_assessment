// TODO: Re-implement with freezed after running code generation
// import 'package:freezed_annotation/freezed_annotation.dart';
// part 'heart_rate_entity.freezed.dart';

import 'dart:developer' as developer;

/// Entity representing heart rate data in the domain layer
class HeartRateEntity {
  final int heartRate;
  final DateTime timestamp;

  const HeartRateEntity({
    required this.heartRate,
    required this.timestamp,
  });

  /// Factory constructor to create a HeartRateEntity from raw data
  factory HeartRateEntity.fromMap(Map<String, dynamic> map) {
    developer.log('Creating HeartRateEntity from map: $map',
        name: 'HeartRateEntity');

    // Safely extract heartRate value - handle different number types
    final dynamic heartRateValue = map['heartRate'];
    final int heartRate;

    if (heartRateValue is int) {
      heartRate = heartRateValue;
    } else if (heartRateValue is double) {
      heartRate = heartRateValue.toInt();
    } else if (heartRateValue is String) {
      heartRate = int.tryParse(heartRateValue) ?? 0;
    } else {
      developer.log('Invalid heartRate type: ${heartRateValue.runtimeType}',
          name: 'HeartRateEntity',
          error: 'Expected number, got: $heartRateValue');
      heartRate = 0;
    }

    // Safely extract timestamp value
    final dynamic timestampValue = map['timestamp'];
    final DateTime timestamp;

    if (timestampValue is double) {
      timestamp =
          DateTime.fromMillisecondsSinceEpoch((timestampValue * 1000).toInt());
    } else if (timestampValue is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
    } else if (timestampValue is String) {
      final double? parsedTimestamp = double.tryParse(timestampValue);
      if (parsedTimestamp != null) {
        timestamp = DateTime.fromMillisecondsSinceEpoch(
            (parsedTimestamp * 1000).toInt());
      } else {
        timestamp = DateTime.now(); // Fallback to current time if parsing fails
      }
    } else {
      developer.log('Invalid timestamp type: ${timestampValue.runtimeType}',
          name: 'HeartRateEntity',
          error: 'Expected number, got: $timestampValue');
      timestamp = DateTime.now(); // Fallback to current time
    }

    developer.log(
        'Created HeartRateEntity: heartRate=$heartRate, timestamp=$timestamp',
        name: 'HeartRateEntity');

    return HeartRateEntity(
      heartRate: heartRate,
      timestamp: timestamp,
    );
  }
}
