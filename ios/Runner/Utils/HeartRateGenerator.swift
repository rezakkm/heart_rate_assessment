import Foundation
import os.log

/// Utility class to generate simulated heart rate values
class HeartRateGenerator {
    // Heart rate ranges
    private let normalMinHeartRate = 60
    private let normalMaxHeartRate = 100
    
    // Categories of abnormal heart rates
    private let lowHeartRateRange = 40...59
    private let elevatedHeartRateRange = 101...130
    private let highHeartRateRange = 131...180
    private let criticalHeartRateRange = 181...220
    
    // Configuration parameters
    private let abnormalProbability = 0.3 // 30% chance of abnormal reading
    
    private let logger = OSLog(subsystem: "com.example.heart_rate_assessment", category: "HeartRateGenerator")
    
    /// Generate a heart rate value with potential for abnormal readings
    func generateHeartRateValue() -> Int {
        // Decide if we should generate an abnormal reading
        if Double.random(in: 0..<1) < abnormalProbability {
            // Generate an abnormal reading
            let abnormalType = Int.random(in: 0..<4)
            var heartRate: Int
            
            switch abnormalType {
            case 0:
                // Low heart rate
                heartRate = Int.random(in: lowHeartRateRange)
                os_log("Generated abnormal LOW heart rate: %d", log: logger, type: .debug, heartRate)
            case 1:
                // Elevated heart rate
                heartRate = Int.random(in: elevatedHeartRateRange)
                os_log("Generated abnormal ELEVATED heart rate: %d", log: logger, type: .debug, heartRate)
            case 2:
                // High heart rate
                heartRate = Int.random(in: highHeartRateRange)
                os_log("Generated abnormal HIGH heart rate: %d", log: logger, type: .debug, heartRate)
            default:
                // Critical heart rate
                heartRate = Int.random(in: criticalHeartRateRange)
                os_log("Generated abnormal CRITICAL heart rate: %d", log: logger, type: .debug, heartRate)
            }
            
            return heartRate
        } else {
            // Generate a normal heart rate
            let heartRate = Int.random(in: normalMinHeartRate...normalMaxHeartRate)
            os_log("Generated normal heart rate: %d", log: logger, type: .debug, heartRate)
            return heartRate
        }
    }
} 