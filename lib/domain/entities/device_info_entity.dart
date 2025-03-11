import 'dart:developer' as developer;

class DeviceInfoEntity {
  final String id;
  final String name;
  final String type;
  final String manufacturer;
  final String firmwareVersion;
  final int batteryLevel;
  final bool isLowBattery;
  final int signalStrength;
  final String connectionStatus;
  final String accuracy;
  final String signalQuality;

  DeviceInfoEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.manufacturer,
    required this.firmwareVersion,
    required this.batteryLevel,
    required this.isLowBattery,
    required this.signalStrength,
    required this.connectionStatus,
    required this.accuracy,
    required this.signalQuality,
  });

  factory DeviceInfoEntity.fromMap(Map<String, dynamic> map) {
    developer.log('Creating DeviceInfoEntity from map',
        name: 'DeviceInfoEntity');

    return DeviceInfoEntity(
      id: map['id']?.toString() ?? 'unknown',
      name: map['name']?.toString() ?? 'Unknown Device',
      type: map['type']?.toString() ?? 'Unknown Type',
      manufacturer: map['manufacturer']?.toString() ?? 'Unknown Manufacturer',
      firmwareVersion: map['firmwareVersion']?.toString() ?? 'Unknown',
      batteryLevel: map['batteryLevel'] is int
          ? map['batteryLevel'] as int
          : map['batteryLevel'] is double
              ? (map['batteryLevel'] as double).toInt()
              : 0,
      isLowBattery: map['isLowBattery'] is bool
          ? map['isLowBattery'] as bool
          : map['isLowBattery'] is String
              ? map['isLowBattery'] == 'true'
              : false,
      signalStrength: map['signalStrength'] is int
          ? map['signalStrength'] as int
          : map['signalStrength'] is double
              ? (map['signalStrength'] as double).toInt()
              : 0,
      connectionStatus: map['connectionStatus']?.toString() ?? 'unknown',
      accuracy: map['accuracy']?.toString() ?? 'unknown',
      signalQuality: map['signalQuality']?.toString() ?? 'unknown',
    );
  }
}
