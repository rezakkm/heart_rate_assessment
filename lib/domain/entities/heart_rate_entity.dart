// TODO: Re-implement with freezed after running code generation
// import 'package:freezed_annotation/freezed_annotation.dart';
// part 'heart_rate_entity.freezed.dart';

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
    return HeartRateEntity(
      heartRate: map['heartRate'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestamp'] as double).toInt() * 1000,
      ),
    );
  }
}
