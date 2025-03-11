// TODO: Re-implement with freezed after running code generation
// import 'package:freezed_annotation/freezed_annotation.dart';
// part 'heart_rate_entity.freezed.dart';

import 'dart:developer' as developer;
import 'package:heart_rate_assessment/domain/entities/device_info_entity.dart';

/// Entity representing heart rate data with device information
class HeartRateEntity {
  final int heartRate;
  final DateTime timestamp;
  final DeviceInfoEntity? deviceInfo;

  HeartRateEntity({
    required this.heartRate,
    required this.timestamp,
    this.deviceInfo,
  });

  /// Create a HeartRateEntity from a map received from the platform channel
  factory HeartRateEntity.fromMap(Map<String, dynamic> map) {
    developer.log('Creating HeartRateEntity from map: $map',
        name: 'HeartRateEntity');

    // Extract heart rate
    int heartRate = 0;
    if (map['heartRate'] is int) {
      heartRate = map['heartRate'] as int;
    } else if (map['heartRate'] is double) {
      heartRate = (map['heartRate'] as double).toInt();
    } else if (map['heartRate'] is String) {
      heartRate = int.tryParse(map['heartRate'] as String) ?? 0;
    }

    // Extract timestamp
    DateTime timestamp = DateTime.now();
    if (map['timestamp'] is double) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(
        ((map['timestamp'] as double) * 1000).toInt(),
      );
    } else if (map['timestamp'] is int) {
      timestamp =
          DateTime.fromMillisecondsSinceEpoch((map['timestamp'] as int) * 1000);
    } else if (map['timestamp'] is String) {
      final milliseconds =
          (double.tryParse(map['timestamp'] as String) ?? 0) * 1000;
      timestamp = DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt());
    }

    // Extract device info if present
    DeviceInfoEntity? deviceInfo;
    if (map['device'] is Map) {
      deviceInfo = DeviceInfoEntity.fromMap(
          Map<String, dynamic>.from(map['device'] as Map));
    }

    developer.log(
        'Created HeartRateEntity: heartRate=$heartRate, timestamp=$timestamp, deviceInfo=${deviceInfo != null}',
        name: 'HeartRateEntity');

    return HeartRateEntity(
      heartRate: heartRate,
      timestamp: timestamp,
      deviceInfo: deviceInfo,
    );
  }
}

/// Entity representing a heart rate monitoring device
class DeviceEntity {
  final String id;
  final String name;
  final String type;
  final String manufacturer;
  final String firmwareVersion;
  final int batteryLevel;
  final int signalStrength;

  DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.manufacturer,
    this.firmwareVersion = '',
    this.batteryLevel = 100,
    this.signalStrength = 100,
  });

  factory DeviceEntity.fromMap(Map<String, dynamic> map) {
    return DeviceEntity(
      id: map['id']?.toString() ?? 'unknown',
      name: map['name']?.toString() ?? 'Unknown Device',
      type: map['type']?.toString() ?? 'Unknown Type',
      manufacturer: map['manufacturer']?.toString() ?? 'Unknown Manufacturer',
      firmwareVersion: map['firmwareVersion']?.toString() ?? '',
      batteryLevel: map['batteryLevel'] is int
          ? map['batteryLevel'] as int
          : ((map['batteryLevel'] as num?)?.toInt() ?? 100),
      signalStrength: map['signalStrength'] is int
          ? map['signalStrength'] as int
          : ((map['signalStrength'] as num?)?.toInt() ?? 100),
    );
  }

  /// Get a user-friendly description of the signal strength
  String get signalQualityDescription {
    if (signalStrength > 80) {
      return 'Excellent';
    } else if (signalStrength > 60) {
      return 'Good';
    } else if (signalStrength > 40) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }
}

/// Entity representing device connection status updates
class DeviceStatusEntity {
  final String status;
  final String message;
  final DeviceEntity? device;

  DeviceStatusEntity({
    required this.status,
    required this.message,
    this.device,
  });

  factory DeviceStatusEntity.fromMap(Map<String, dynamic> map) {
    DeviceEntity? device;
    if (map.containsKey('device') && map['device'] is Map) {
      try {
        device = DeviceEntity.fromMap(
            Map<String, dynamic>.from(map['device'] as Map));
      } catch (e) {
        developer.log('Error parsing device data in status: $e',
            name: 'DeviceStatusEntity');
      }
    }

    return DeviceStatusEntity(
      status: map['status']?.toString() ?? 'UNKNOWN',
      message: map['message']?.toString() ?? 'Unknown status',
      device: device,
    );
  }
}
