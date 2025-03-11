package com.example.heart_rate_assessment

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.example.heart_rate_assessment.models.ConnectionStatus
import com.example.heart_rate_assessment.models.DeviceAccuracy
import com.example.heart_rate_assessment.models.DeviceInfo
import com.example.heart_rate_assessment.utils.HeartRateGenerator
import io.flutter.plugin.common.EventChannel
import java.util.*
import kotlin.random.Random

/**
 * HeartRateModule that generates random heart rate values and simulates device connectivity
 */
class HeartRateModule : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var handler: Handler? = null
    private val runnable = Runnable { generateAndSendHeartRate() }
    
    // Configuration parameters
    private val updateIntervalMs = 5000L // 5 seconds
    
    // Heart rate generator
    private val heartRateGenerator = HeartRateGenerator()
    
    // Simulated device
    private var device = DeviceInfo.random()
    
    private val TAG = "HeartRateModule"
    
    /**
     * Set up the event sink when the stream is listened to
     */
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "onListen called, stream being listened to")
        eventSink = events
        startGeneratingHeartRateData()
    }
    
    /**
     * Clean up when the stream is cancelled
     */
    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "onCancel called, stream no longer being listened to")
        stopGeneratingHeartRateData()
        eventSink = null
    }
    
    /**
     * Start generating random heart rate data
     */
    fun startGeneratingHeartRateData() {
        Log.d(TAG, "startGeneratingHeartRateData called")
        stopGeneratingHeartRateData() // Ensure no duplicate timers
        
        handler = Handler(Looper.getMainLooper())
        handler?.postDelayed(runnable, updateIntervalMs)
        
        // Change device status to connected
        device = device.copy(connectionStatus = ConnectionStatus.CONNECTED)
        
        // Generate and send first value immediately
        generateAndSendHeartRate()
    }
    
    /**
     * Stop generating heart rate data
     */
    fun stopGeneratingHeartRateData() {
        Log.d(TAG, "stopGeneratingHeartRateData called")
        handler?.removeCallbacks(runnable)
        handler = null
        
        // Change device status to disconnected if it was previously connected
        if (device.connectionStatus == ConnectionStatus.CONNECTED || 
            device.connectionStatus == ConnectionStatus.READY) {
            device = device.copy(connectionStatus = ConnectionStatus.DISCONNECTED)
        }
    }
    
    /**
     * Generate a random heart rate value and send via eventSink
     */
    private fun generateAndSendHeartRate() {
        val heartRate = heartRateGenerator.generateHeartRateValue()
        
        // Occasionally update device status
        updateDeviceStatus()
        
        // Create a map with heart rate value and timestamp
        val heartRateData = HashMap<String, Any>()
        heartRateData["heartRate"] = heartRate
        heartRateData["timestamp"] = System.currentTimeMillis() / 1000.0
        
        // Add device info
        val deviceMap = HashMap<String, Any>()
        deviceMap["id"] = device.id
        deviceMap["name"] = device.name
        deviceMap["type"] = device.type
        deviceMap["manufacturer"] = device.manufacturer
        deviceMap["firmwareVersion"] = device.firmwareVersion
        deviceMap["batteryLevel"] = device.batteryLevel
        deviceMap["isLowBattery"] = device.batteryLevel < 30
        deviceMap["signalStrength"] = device.signalStrength
        deviceMap["connectionStatus"] = device.connectionStatus.toStringValue()
        deviceMap["accuracy"] = device.accuracy.toStringValue()
        deviceMap["signalQuality"] = device.getSignalStrengthDescription()
        
        heartRateData["device"] = deviceMap
        
        Log.d(TAG, "Generating heart rate: $heartRate BPM")
        
        // Send the heart rate data to Flutter
        eventSink?.let {
            Log.d(TAG, "Sending heart rate data to Flutter")
            it.success(heartRateData)
        } ?: run {
            Log.e(TAG, "EventSink is null, cannot send heart rate data")
        }
        
        // Schedule the next update
        handler?.postDelayed(runnable, updateIntervalMs)
    }
    
    /**
     * Update device status to simulate real-world behavior
     */
    private fun updateDeviceStatus() {
        // Occasionally update battery level (decreasing)
        if (Random.nextInt(10) == 0 && device.batteryLevel > 20) {
            device = device.copy(
                batteryLevel = device.batteryLevel - Random.nextInt(1, 4)
            )
            Log.d(TAG, "Battery level updated to ${device.batteryLevel}%")
        }
        
        // Occasionally fluctuate signal strength
        if (Random.nextInt(5) == 0) {
            val fluctuation = Random.nextInt(-5, 6)
            device = device.copy(
                signalStrength = (device.signalStrength + fluctuation).coerceIn(-95, -40)
            )
            Log.d(TAG, "Signal strength updated to ${device.signalStrength} dBm")
            
            // If signal is very weak, accuracy might decrease
            if (device.signalStrength < -85 && Random.nextInt(3) == 0) {
                device = device.copy(accuracy = DeviceAccuracy.POOR)
                Log.d(TAG, "Accuracy degraded to 'poor' due to weak signal")
            } else if (device.signalStrength > -70 && 
                      device.accuracy == DeviceAccuracy.POOR && 
                      Random.nextInt(3) == 0) {
                device = device.copy(accuracy = DeviceAccuracy.GOOD)
                Log.d(TAG, "Accuracy improved to 'good'")
            }
        }
        
        // Very rarely simulate connection issues
        if (Random.nextInt(100) == 0 && 
            device.connectionStatus == ConnectionStatus.CONNECTED) {
            
            // Save current status to restore later
            val previousStatus = device.connectionStatus
            
            // Change to unstable connection
            device = device.copy(connectionStatus = ConnectionStatus.ERROR)
            Log.d(TAG, "Connection became unstable")
            
            // Schedule return to normal after a short time
            Handler(Looper.getMainLooper()).postDelayed({
                device = device.copy(connectionStatus = previousStatus)
                Log.d(TAG, "Connection returned to normal")
            }, 10000) // 10 seconds later
        }
    }
    
    /**
     * Manually trigger an error for testing
     */
    fun sendError() {
        Log.e(TAG, "Manually sending error for testing")
        eventSink?.error(
            "HEART_RATE_ERROR",
            "Failed to generate heart rate data",
            null
        )
    }
} 