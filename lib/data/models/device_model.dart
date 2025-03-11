import 'dart:math';

/// Model representing a heart rate monitoring device
class DeviceModel {
  final String id;
  final String name;
  final String type;
  final String manufacturer;
  final String firmwareVersion;
  final int batteryLevel;
  final bool isLowBattery;

  /// Signal strength in dBm, typically between -100 (very weak) and 0 (excellent)
  final int signalStrength;

  /// Device connection status
  final DeviceConnectionStatus connectionStatus;

  /// Heart rate measurement accuracy
  final DeviceAccuracy accuracy;

  DeviceModel({
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
  });

  /// Create a copy of this device with updated properties
  DeviceModel copyWith({
    String? id,
    String? name,
    String? type,
    String? manufacturer,
    String? firmwareVersion,
    int? batteryLevel,
    bool? isLowBattery,
    int? signalStrength,
    DeviceConnectionStatus? connectionStatus,
    DeviceAccuracy? accuracy,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      manufacturer: manufacturer ?? this.manufacturer,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isLowBattery: isLowBattery ?? this.isLowBattery,
      signalStrength: signalStrength ?? this.signalStrength,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  /// Return user-friendly signal strength description
  String get signalStrengthDescription {
    if (signalStrength > -60) {
      return 'Excellent';
    } else if (signalStrength > -70) {
      return 'Good';
    } else if (signalStrength > -80) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  /// Create a factory method to generate a random device model for simulation
  factory DeviceModel.random() {
    final random = Random();

    // Create a random device ID
    final deviceId = 'HR-${random.nextInt(999999).toString().padLeft(6, '0')}';

    // Select from pre-defined device models
    final deviceTypes = [
      {
        'name': 'BeatMaster Pro',
        'type': 'HR Monitor',
        'manufacturer': 'CardioTech',
        'firmware': '3.1.4',
      },
      {
        'name': 'HeartSense Ultra',
        'type': 'HR Monitor',
        'manufacturer': 'FitLife',
        'firmware': '2.8.0',
      },
      {
        'name': 'PulseTrack Elite',
        'type': 'HR Chest Strap',
        'manufacturer': 'SportMedix',
        'firmware': '4.2.1',
      },
      {
        'name': 'CardioRhythm X2',
        'type': 'Medical HR Monitor',
        'manufacturer': 'HealthSystems',
        'firmware': '5.0.3',
      },
      {
        'name': 'VitalPulse Watch',
        'type': 'Smartwatch',
        'manufacturer': 'WearTech',
        'firmware': '1.9.7',
      },
    ];

    final selectedDevice = deviceTypes[random.nextInt(deviceTypes.length)];

    // Generate random battery level (20-100%)
    final batteryLevel = 20 + random.nextInt(81);

    // Generate random signal strength (-95 to -40 dBm)
    final signalStrength = -95 + random.nextInt(56);

    // Determine initial connection status (usually discovered or ready to connect)
    final initialStatus = random.nextBool()
        ? DeviceConnectionStatus.discovered
        : DeviceConnectionStatus.ready;

    // Simulate device accuracy (most should be good or excellent, fewer poor)
    final accuracyRoll = random.nextInt(10);
    DeviceAccuracy accuracy;
    if (accuracyRoll < 7) {
      accuracy = DeviceAccuracy.excellent;
    } else if (accuracyRoll < 9) {
      accuracy = DeviceAccuracy.good;
    } else {
      accuracy = DeviceAccuracy.poor;
    }

    return DeviceModel(
      id: deviceId,
      name: selectedDevice['name']!,
      type: selectedDevice['type']!,
      manufacturer: selectedDevice['manufacturer']!,
      firmwareVersion: selectedDevice['firmware']!,
      batteryLevel: batteryLevel,
      isLowBattery: batteryLevel < 30,
      signalStrength: signalStrength,
      connectionStatus: initialStatus,
      accuracy: accuracy,
    );
  }
}

/// Possible connection states for a device
enum DeviceConnectionStatus {
  discovered, // Device found but not yet connected
  connecting, // Connection attempt in progress
  connected, // Connection established
  ready, // Connected and ready to use
  disconnecting, // Disconnection in progress
  disconnected, // Device was connected but now disconnected
  error, // Error occurred during connection or operation
}

/// Device measurement accuracy
enum DeviceAccuracy {
  poor, // Low accuracy, measurements may be off
  good, // Good accuracy, measurements mostly reliable
  excellent, // High accuracy, measurements very reliable
}
