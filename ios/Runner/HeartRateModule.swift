import Foundation
import Flutter

// Heart Rate Module that generates random heart rate values
class HeartRateModule: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var timer: Timer?
    
    // Heart rate ranges
    private let normalMinHeartRate = 60
    private let normalMaxHeartRate = 100
    
    // Categories of abnormal heart rates
    private let lowHeartRateRange = 40...59
    private let elevatedHeartRateRange = 101...130
    private let highHeartRateRange = 131...180
    private let criticalHeartRateRange = 181...220
    
    // Configuration parameters
    private let updateIntervalSec = 5.0 // 5 seconds
    private let abnormalProbability = 0.3 // 30% chance of abnormal reading
    
    // Device simulation properties
    private var deviceName: String = ""
    private var deviceId: String = ""
    private var deviceType: String = ""
    private var manufacturer: String = ""
    private var firmwareVersion: String = ""
    private var batteryLevel: Int = 0
    private var signalStrength: Int = 0
    private var connectionStatus: String = "connected"
    private var accuracy: String = "good"
    
    override init() {
        super.init()
        generateDeviceInfo()
        NSLog("HeartRateModule initialized with device: \(deviceName)")
    }
    
    // MARK: - FlutterStreamHandler protocol
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        NSLog("HeartRateModule: Stream is being listened to")
        eventSink = events
        startGeneratingHeartRateData()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NSLog("HeartRateModule: Stream is no longer being listened to")
        stopGeneratingHeartRateData()
        eventSink = nil
        return nil
    }
    
    // MARK: - Public methods
    
    func startGeneratingHeartRateData() {
        NSLog("HeartRateModule: Starting heart rate generation")
        stopGeneratingHeartRateData() // Ensure no duplicate timers
        
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
    
    func stopGeneratingHeartRateData() {
        NSLog("HeartRateModule: Stopping heart rate generation")
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private methods
    
    @objc private func timerFired() {
        generateAndSendHeartRate()
    }
    
    private func generateAndSendHeartRate() {
        guard let sink = eventSink else {
            NSLog("HeartRateModule: EventSink is nil, cannot send heart rate data")
            return
        }
        
        let heartRate = generateHeartRateValue()
        
        // Occasionally update device status to simulate real-world behavior
        updateDeviceStatus()
        
        // Create a dictionary with heart rate value, timestamp, and device info
        let heartRateData: [String: Any] = [
            "heartRate": heartRate,
            "timestamp": Date().timeIntervalSince1970,
            "device": [
                "id": deviceId,
                "name": deviceName,
                "type": deviceType,
                "manufacturer": manufacturer,
                "firmwareVersion": firmwareVersion,
                "batteryLevel": batteryLevel,
                "isLowBattery": batteryLevel < 30,
                "signalStrength": signalStrength,
                "connectionStatus": connectionStatus,
                "accuracy": accuracy
            ]
        ]
        
        NSLog("HeartRateModule: Generating heart rate: \(heartRate) BPM")
        sink(heartRateData)
    }
    
    private func generateHeartRateValue() -> Int {
        // Decide if we should generate an abnormal reading
        if Double.random(in: 0..<1) < abnormalProbability {
            // Generate an abnormal reading
            let abnormalType = Int.random(in: 0..<4)
            var heartRate: Int
            
            switch abnormalType {
            case 0:
                // Low heart rate
                heartRate = Int.random(in: lowHeartRateRange)
                NSLog("HeartRateModule: Generated abnormal LOW heart rate: \(heartRate)")
            case 1:
                // Elevated heart rate
                heartRate = Int.random(in: elevatedHeartRateRange)
                NSLog("HeartRateModule: Generated abnormal ELEVATED heart rate: \(heartRate)")
            case 2:
                // High heart rate
                heartRate = Int.random(in: highHeartRateRange)
                NSLog("HeartRateModule: Generated abnormal HIGH heart rate: \(heartRate)")
            default:
                // Critical heart rate
                heartRate = Int.random(in: criticalHeartRateRange)
                NSLog("HeartRateModule: Generated abnormal CRITICAL heart rate: \(heartRate)")
            }
            
            return heartRate
        } else {
            // Generate a normal heart rate
            let heartRate = Int.random(in: normalMinHeartRate...normalMaxHeartRate)
            NSLog("HeartRateModule: Generated normal heart rate: \(heartRate)")
            return heartRate
        }
    }
    
    private func generateDeviceInfo() {
        // Create random device ID
        let randomNum = Int.random(in: 0..<999999)
        deviceId = String(format: "HR-%06d", randomNum)
        
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
        deviceName = selectedDevice["name"] as! String
        deviceType = selectedDevice["type"] as! String
        manufacturer = selectedDevice["manufacturer"] as! String
        firmwareVersion = selectedDevice["firmware"] as! String
        
        // Generate random battery level (20-100%)
        batteryLevel = Int.random(in: 20...100)
        
        // Generate random signal strength (-95 to -40 dBm)
        signalStrength = Int.random(in: -95 ... -40)
        
        // Initial connection status and accuracy
        connectionStatus = "connected"
        
        // Simulate device accuracy
        let accuracyRoll = Int.random(in: 0..<10)
        if accuracyRoll < 7 {
            accuracy = "excellent"
        } else if accuracyRoll < 9 {
            accuracy = "good"
        } else {
            accuracy = "poor"
        }
    }
    
    private func updateDeviceStatus() {
        // Occasionally update battery level (decreasing)
        if Int.random(in: 0..<10) == 0 && batteryLevel > 20 {
            batteryLevel -= Int.random(in: 1...3)
            NSLog("HeartRateModule: Battery level updated to \(batteryLevel)%")
        }
        
        // Occasionally fluctuate signal strength
        if Int.random(in: 0..<5) == 0 {
            let fluctuation = Int.random(in: -5...5)
            signalStrength = max(-95, min(-40, signalStrength + fluctuation))
            NSLog("HeartRateModule: Signal strength updated to \(signalStrength) dBm")
            
            // If signal is very weak, accuracy might decrease
            if signalStrength < -85 && Int.random(in: 0..<3) == 0 {
                accuracy = "poor"
                NSLog("HeartRateModule: Accuracy degraded to 'poor' due to weak signal")
            } else if signalStrength > -70 && accuracy == "poor" && Int.random(in: 0..<3) == 0 {
                accuracy = "good"
                NSLog("HeartRateModule: Accuracy improved to 'good'")
            }
        }
        
        // Very rarely simulate connection issues
        if Int.random(in: 0..<100) == 0 {
            let tempStatus = connectionStatus
            connectionStatus = "unstable"
            NSLog("HeartRateModule: Connection became unstable")
            
            // Schedule return to normal after a short time
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                guard let self = self else { return }
                self.connectionStatus = tempStatus
                NSLog("HeartRateModule: Connection returned to normal")
            }
        }
    }
    
    func simulateError() {
        NSLog("HeartRateModule: Manually sending error for testing")
        eventSink?(FlutterError(code: "HEART_RATE_ERROR", 
                               message: "Failed to generate heart rate data", 
                               details: nil))
    }
} 