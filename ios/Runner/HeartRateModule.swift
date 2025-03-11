import Flutter
import UIKit

// Heart Rate Module that generates random heart rate values
class HeartRateModule: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var timer: Timer?
    private let minHeartRate = 60
    private let maxHeartRate = 100
    
    // Set up the event sink when the stream is listened to
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startGeneratingHeartRateData()
        return nil
    }
    
    // Clean up when the stream is cancelled
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopGeneratingHeartRateData()
        eventSink = nil
        return nil
    }
    
    // Start generating random heart rate data every 5 seconds
    func startGeneratingHeartRateData() {
        stopGeneratingHeartRateData() // Ensure no duplicate timers
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.generateAndSendHeartRate()
        }
        
        // Generate and send first value immediately
        generateAndSendHeartRate()
    }
    
    // Stop generating heart rate data
    func stopGeneratingHeartRateData() {
        timer?.invalidate()
        timer = nil
    }
    
    // Generate a random heart rate value and send via eventSink
    private func generateAndSendHeartRate() {
        guard let eventSink = eventSink else { return }
        
        let randomHeartRate = Int.random(in: minHeartRate...maxHeartRate)
        
        // Create a dictionary with heart rate value and timestamp
        let heartRateData: [String: Any] = [
            "heartRate": randomHeartRate,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Send the heart rate data to Flutter
        eventSink(heartRateData)
    }
    
    // Manually trigger an error for testing
    func sendError() {
        guard let eventSink = eventSink else { return }
        eventSink(FlutterError(code: "HEART_RATE_ERROR", 
                              message: "Failed to generate heart rate data",
                              details: nil))
    }
} 