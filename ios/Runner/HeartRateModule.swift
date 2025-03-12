import Foundation
import Flutter
import os.log

/// HeartRateModule that generates random heart rate values and simulates device connectivity
class HeartRateModule: NSObject, FlutterStreamHandler {
    // Flutter channels
    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    
    // Flutter event sink
    private var eventSink: FlutterEventSink?
    private var timer: Timer?
    
    // Configuration parameters
    private let updateIntervalSec = 1.0 // 1 second
    
    // Heart rate ranges
    private let normalRange = 60...100
    private let lowRange = 40..<60
    private let elevatedRange = 101...120
    private let highRange = 121...140
    private let criticalRange = 141...180
    
    // Current simulation state
    private var currentHeartRate = 75
    private var heartRateCategory = "NORMAL"
    private var abnormalReadingProbability = 0.05
    
    // Simulated device
    private var device = DeviceInfo.random()
    private var deviceUpdateCounter = 0
    
    private let logger = OSLog(subsystem: "com.example.heart_rate_assessment", category: "HeartRateModule")
    
    init(messenger: FlutterBinaryMessenger) {
        // Initialize channels
        methodChannel = FlutterMethodChannel(
            name: "com.example.heart_rate_assessment/heart_rate_method",
            binaryMessenger: messenger
        )
        
        eventChannel = FlutterEventChannel(
            name: "com.example.heart_rate_assessment/heart_rate_stream",
            binaryMessenger: messenger
        )
        
        super.init()
        
        // Set up method channel handlers
        setupMethodChannel()
        
        // Set up event channel
        eventChannel.setStreamHandler(self)
        
        os_log("HeartRateModule initialized with device: %@", log: logger, type: .info, device.name)
    }
    
    private func setupMethodChannel() {
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "startHeartRateMonitoring":
                self.startHeartRateMonitoring()
                result(true)
            case "stopHeartRateMonitoring":
                self.stopHeartRateMonitoring()
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - FlutterStreamHandler protocol
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        os_log("Stream is being listened to", log: logger, type: .debug)
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        os_log("Stream is no longer being listened to", log: logger, type: .debug)
        stopHeartRateMonitoring()
        eventSink = nil
        return nil
    }
    
    // MARK: - Public methods
    
    func startHeartRateMonitoring() {
        os_log("Starting heart rate monitoring", log: logger, type: .debug)
        stopHeartRateMonitoring() // Ensure no duplicate timers
        
        // Reset device if needed
        device = DeviceInfo.random()
        
        // Generate and send first value immediately
        generateAndSendHeartRate()
        
        // Schedule periodic updates
        timer = Timer.scheduledTimer(
            timeInterval: updateIntervalSec,
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopHeartRateMonitoring() {
        os_log("Stopping heart rate monitoring", log: logger, type: .debug)
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private methods
    
    @objc private func timerFired() {
        generateAndSendHeartRate()
    }
    
    private func generateAndSendHeartRate() {
        guard let sink = eventSink else {
            os_log("EventSink is nil, cannot send heart rate data", log: logger, type: .error)
            return
        }
        
        // Update device status occasionally
        deviceUpdateCounter += 1
        if deviceUpdateCounter >= 5 {
            updateDeviceStatus()
            deviceUpdateCounter = 0
        }
        
        // Generate a heart rate value
        let useAbnormalReading = Double.random(in: 0...1) < abnormalReadingProbability
        
        if useAbnormalReading {
            // Generate an abnormal reading occasionally
            let abnormalCategories = ["LOW", "ELEVATED", "HIGH", "CRITICAL"]
            heartRateCategory = abnormalCategories.randomElement() ?? "ELEVATED"
            
            switch heartRateCategory {
            case "LOW":
                currentHeartRate = Int.random(in: lowRange)
            case "ELEVATED":
                currentHeartRate = Int.random(in: elevatedRange)
            case "HIGH":
                currentHeartRate = Int.random(in: highRange)
            case "CRITICAL":
                currentHeartRate = Int.random(in: criticalRange)
            default:
                currentHeartRate = Int.random(in: normalRange)
            }
        } else {
            // Most of the time, generate values within normal range
            heartRateCategory = "NORMAL"
            
            // Small random fluctuation around the current value
            let fluctuation = Int.random(in: -5...5)
            currentHeartRate += fluctuation
            
            // Ensure it stays within normal range
            if currentHeartRate < normalRange.lowerBound {
                currentHeartRate = normalRange.lowerBound + Int.random(in: 0...5)
            } else if currentHeartRate > normalRange.upperBound {
                currentHeartRate = normalRange.upperBound - Int.random(in: 0...5)
            }
        }
        
        // Create the heart rate data
        let timestamp = Date().timeIntervalSince1970 * 1000
        
        var heartRateData: [String: Any] = [
            "heartRate": currentHeartRate,
            "timestamp": timestamp
        ]
        
        // Add device info
        heartRateData["device"] = device.toDictionary()
        
        os_log("Sending heart rate: %d BPM", log: logger, type: .debug, currentHeartRate)
        sink(heartRateData)
    }
    
    private func updateDeviceStatus() {
        // Update battery level - slowly decrease
        if device.batteryLevel > 10 {
            device.batteryLevel -= Int.random(in: 1...3)
            if device.batteryLevel < 0 {
                device.batteryLevel = 0
            }
        }
        
        // Update signal strength - fluctuate
        let signalChange = Int.random(in: -1...1)
        device.signalStrength += signalChange
        if device.signalStrength < 1 {
            device.signalStrength = 1
        } else if device.signalStrength > 5 {
            device.signalStrength = 5
        }
        
        // Simulate occasional connection issues
        if Double.random(in: 0...1) < 0.05 {
            device.connectionStatus = ["CONNECTED", "CONNECTING", "UNSTABLE"].randomElement() ?? "CONNECTED"
        } else {
            device.connectionStatus = "CONNECTED"
        }
    }
}

// MARK: - Device Info Model
struct DeviceInfo {
    var id: String
    var name: String
    var type: String
    var manufacturer: String
    var firmwareVersion: String
    var batteryLevel: Int
    var signalStrength: Int
    var connectionStatus: String
    var accuracy: String
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "type": type,
            "manufacturer": manufacturer,
            "firmwareVersion": firmwareVersion,
            "batteryLevel": batteryLevel,
            "signalStrength": signalStrength,
            "connectionStatus": connectionStatus,
            "accuracy": accuracy,
            "signalDescription": getSignalDescription()
        ]
    }
    
    func getSignalDescription() -> String {
        switch signalStrength {
        case 1:
            return "Very Weak"
        case 2:
            return "Weak"
        case 3:
            return "Moderate"
        case 4:
            return "Good"
        case 5:
            return "Excellent"
        default:
            return "Unknown"
        }
    }
    
    static func random() -> DeviceInfo {
        let deviceNames = ["HeartSense Pro", "CardioMonitor X2", "BeatMaster Plus", "PulseTrack Elite", "VitalScan Ultra"]
        let deviceTypes = ["PPG Sensor", "ECG Monitor", "Dual Mode Sensor", "Multi-Parameter Monitor"]
        let manufacturers = ["HealthTech", "CardioInnovations", "MedSense", "VitalMetrics", "BioTech Solutions"]
        let accuracyLevels = ["High", "Medical Grade", "Consumer", "Research Grade", "Clinical"]
        
        return DeviceInfo(
            id: UUID().uuidString,
            name: deviceNames.randomElement() ?? "HeartSense Pro",
            type: deviceTypes.randomElement() ?? "PPG Sensor",
            manufacturer: manufacturers.randomElement() ?? "HealthTech",
            firmwareVersion: "v\(Int.random(in: 1...5)).\(Int.random(in: 0...9)).\(Int.random(in: 0...9))",
            batteryLevel: Int.random(in: 50...100),
            signalStrength: Int.random(in: 3...5),
            connectionStatus: "CONNECTED",
            accuracy: accuracyLevels.randomElement() ?? "High"
        )
    }
} 