import Foundation
import Flutter
import os.log

/// HeartRateModule that generates random heart rate values and simulates device connectivity
class HeartRateModule: NSObject, FlutterStreamHandler {
    // Flutter event sink
    private var eventSink: FlutterEventSink?
    private var timer: Timer?
    
    // Configuration parameters
    private let updateIntervalSec = 5.0 // 5 seconds
    
    // Heart rate generator
    private let heartRateGenerator = HeartRateGenerator()
    
    // Simulated device
    private var device = DeviceInfo.random()
    
    private let logger = OSLog(subsystem: "com.example.heart_rate_assessment", category: "HeartRateModule")
    
    override init() {
        super.init()
        os_log("HeartRateModule initialized with device: %@", log: logger, type: .info, device.name)
    }
    
    // MARK: - FlutterStreamHandler protocol
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        os_log("Stream is being listened to", log: logger, type: .debug)
        eventSink = events
        startGeneratingHeartRateData()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        os_log("Stream is no longer being listened to", log: logger, type: .debug)
        stopGeneratingHeartRateData()
        eventSink = nil
        return nil
    }
    
    // MARK: - Public methods
    
    func startGeneratingHeartRateData() {
        os_log("Starting heart rate generation", log: logger, type: .debug)
        stopGeneratingHeartRateData() // Ensure no duplicate timers
        
        // Update device connection status
        device.connectionStatus = .connected
        
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
        os_log("Stopping heart rate generation", log: logger, type: .debug)
        timer?.invalidate()
        timer = nil
        
        // Update device connection status if it was previously connected
        if device.connectionStatus == .connected || device.connectionStatus == .ready {
            device.connectionStatus = .disconnected
        }
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
        
        let heartRate = heartRateGenerator.generateHeartRateValue()
        
        // Occasionally update device status to simulate real-world behavior
        updateDeviceStatus()
        
        // Create a dictionary with heart rate value, timestamp, and device info
        let heartRateData: [String: Any] = [
            "heartRate": heartRate,
            "timestamp": Date().timeIntervalSince1970,
            "device": device.toDictionary()
        ]
        
        os_log("Sending heart rate: %d BPM", log: logger, type: .debug, heartRate)
        sink(heartRateData)
    }
    
    private func updateDeviceStatus() {
        // Occasionally update battery level (decreasing)
        if Int.random(in: 0..<10) == 0 && device.batteryLevel > 20 {
            device.batteryLevel -= Int.random(in: 1...3)
            os_log("Battery level updated to %d%%", log: logger, type: .debug, device.batteryLevel)
        }
        
        // Occasionally fluctuate signal strength
        if Int.random(in: 0..<5) == 0 {
            let fluctuation = Int.random(in: -5...5)
            device.signalStrength = max(-95, min(-40, device.signalStrength + fluctuation))
            os_log("Signal strength updated to %d dBm", log: logger, type: .debug, device.signalStrength)
            
            // If signal is very weak, accuracy might decrease
            if device.signalStrength < -85 && Int.random(in: 0..<3) == 0 {
                device.accuracy = .poor
                os_log("Accuracy degraded to 'poor' due to weak signal", log: logger, type: .debug)
            } else if device.signalStrength > -70 && device.accuracy == .poor && Int.random(in: 0..<3) == 0 {
                device.accuracy = .good
                os_log("Accuracy improved to 'good'", log: logger, type: .debug)
            }
        }
        
        // Very rarely simulate connection issues
        if Int.random(in: 0..<100) == 0 && device.connectionStatus == .connected {
            // Save current status to restore later
            let previousStatus = device.connectionStatus
            
            // Change to error status
            device.connectionStatus = .error
            os_log("Connection became unstable", log: logger, type: .debug)
            
            // Schedule return to normal after a short time
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                guard let self = self else { return }
                self.device.connectionStatus = previousStatus
                os_log("Connection returned to normal", log: self.logger, type: .debug)
            }
        }
    }
    
    func simulateError() {
        os_log("Manually sending error for testing", log: logger, type: .error)
        eventSink?(FlutterError(code: "HEART_RATE_ERROR", 
                               message: "Failed to generate heart rate data", 
                               details: nil))
    }
} 