import Foundation

/// Model representing a heart rate monitoring device
struct DeviceInfo {
    let id: String
    let name: String
    let type: String
    let manufacturer: String
    let firmwareVersion: String
    var batteryLevel: Int
    var signalStrength: Int
    var connectionStatus: ConnectionStatus
    var accuracy: DeviceAccuracy
    
    /// Calculate if the battery is low
    var isLowBattery: Bool {
        return batteryLevel < 30
    }
    
    /// Return user-friendly signal strength description
    var signalStrengthDescription: String {
        if signalStrength > -60 {
            return "Excellent"
        } else if signalStrength > -70 {
            return "Good"
        } else if signalStrength > -80 {
            return "Fair"
        } else {
            return "Poor"
        }
    }
    
    /// Create a dictionary representation for Flutter
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "type": type,
            "manufacturer": manufacturer,
            "firmwareVersion": firmwareVersion,
            "batteryLevel": batteryLevel,
            "isLowBattery": isLowBattery,
            "signalStrength": signalStrength,
            "connectionStatus": connectionStatus.rawValue,
            "accuracy": accuracy.rawValue,
            "signalQuality": signalStrengthDescription
        ]
    }
    
    /// Generate a random device for simulation
    static func random() -> DeviceInfo {
        // Create a random device ID
        let randomNum = Int.random(in: 0..<999999)
        let deviceId = String(format: "HR-%06d", randomNum)
        
        // Select from pre-defined device models
        let deviceTypes = [
            [
                "name": "BeatMaster Pro",
                "type": "HR Monitor",
                "manufacturer": "CardioTech",
                "firmware": "3.1.4"
            ],
            [
                "name": "HeartSense Ultra",
                "type": "HR Monitor",
                "manufacturer": "FitLife",
                "firmware": "2.8.0"
            ],
            [
                "name": "PulseTrack Elite",
                "type": "HR Chest Strap",
                "manufacturer": "SportMedix",
                "firmware": "4.2.1"
            ],
            [
                "name": "CardioRhythm X2",
                "type": "Medical HR Monitor",
                "manufacturer": "HealthSystems",
                "firmware": "5.0.3"
            ],
            [
                "name": "VitalPulse Watch",
                "type": "Smartwatch",
                "manufacturer": "WearTech",
                "firmware": "1.9.7"
            ]
        ]
        
        let selectedDevice = deviceTypes[Int.random(in: 0..<deviceTypes.count)]
        
        // Generate random battery level (20-100%)
        let batteryLevel = Int.random(in: 20...100)
        
        // Generate random signal strength (-95 to -40 dBm)
        let signalStrength = Int.random(in: -95 ... -40)
        
        // Determine initial connection status
        let initialStatus: ConnectionStatus = Bool.random() ? .connected : .ready
        
        // Simulate device accuracy
        let accuracyRoll = Int.random(in: 0..<10)
        let accuracy: DeviceAccuracy
        if accuracyRoll < 7 {
            accuracy = .excellent
        } else if accuracyRoll < 9 {
            accuracy = .good
        } else {
            accuracy = .poor
        }
        
        return DeviceInfo(
            id: deviceId,
            name: selectedDevice["name"] as! String,
            type: selectedDevice["type"] as! String,
            manufacturer: selectedDevice["manufacturer"] as! String,
            firmwareVersion: selectedDevice["firmware"] as! String,
            batteryLevel: batteryLevel,
            signalStrength: signalStrength,
            connectionStatus: initialStatus,
            accuracy: accuracy
        )
    }
}

/// Possible connection states for a device
enum ConnectionStatus: String {
    case discovered = "discovered"   // Device found but not yet connected
    case connecting = "connecting"   // Connection attempt in progress
    case connected = "connected"     // Connection established
    case ready = "ready"             // Connected and ready to use
    case disconnecting = "disconnecting" // Disconnection in progress
    case disconnected = "disconnected" // Device was connected but now disconnected
    case error = "error"             // Error occurred during connection or operation
}

/// Device measurement accuracy
enum DeviceAccuracy: String {
    case poor = "poor"           // Low accuracy, measurements may be off
    case good = "good"           // Good accuracy, measurements mostly reliable
    case excellent = "excellent" // High accuracy, measurements very reliable
} 