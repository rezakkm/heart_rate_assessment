package com.example.heart_rate_assessment

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.util.*
import kotlin.random.Random

/**
 * HeartRateModule that simulates connection to an external heart rate monitoring device
 * This module handles the simulated device discovery, connection, and data transmission
 */
class HeartRateModule : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var handler: Handler? = null
    private val runnable = Runnable { generateAndSendHeartRate() }
    
    // Default heart rate range
    private val normalMinHeartRate = 60
    private val normalMaxHeartRate = 100
    
    // Categories of abnormal heart rates
    private val lowHeartRateRange = 40..59
    private val elevatedHeartRateRange = 101..130
    private val highHeartRateRange = 131..180
    private val criticalHeartRateRange = 181..220
    
    // Configuration parameters
    private val updateIntervalMs = 3000L // 3 seconds
    private val abnormalProbability = 0.2 // 20% chance of abnormal reading
    
    // Simulated device data
    private var connectedDevice: DeviceInfo? = null
    private var deviceStatus = DeviceStatus.DISCONNECTED
    private var connectionQuality = 100 // 0-100%, will fluctuate over time
    
    private val TAG = "HeartRateModule"
    
    /**
     * Set up the event sink when the stream is listened to
     */
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "onListen called, stream being listened to")
        eventSink = events
        simulateDeviceDiscovery()
    }
    
    /**
     * Clean up when the stream is cancelled
     */
    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "onCancel called, stream no longer being listened to")
        stopGeneratingHeartRateData()
        simulateDeviceDisconnection()
        eventSink = null
    }
    
    /**
     * Simulate the process of discovering a heart rate monitoring device
     */
    private fun simulateDeviceDiscovery() {
        Log.d(TAG, "Starting device discovery")
        deviceStatus = DeviceStatus.DISCOVERING
        
        // Generate a synthetic device if none exists
        if (connectedDevice == null) {
            createRandomDevice()
        }
        
        // Send device discovery event
        sendDeviceStatusUpdate("Device found: ${connectedDevice?.name}")
        
        // After a short delay, connect to the device
        Handler(Looper.getMainLooper()).postDelayed({
            simulateDeviceConnection()
        }, 1500) // 1.5 second delay to simulate discovery time
    }
    
    /**
     * Create a random heart rate monitoring device
     */
    private fun createRandomDevice() {
        val random = Random
        
        // Select random device type
        val deviceModels = listOf(
            DeviceInfo("BeatMaster Pro", "CardioTech", "3.1.4", "Chest Strap"),
            DeviceInfo("HeartSense Ultra", "FitLife", "2.8.0", "Wristband"),
            DeviceInfo("PulseTrack Elite", "SportMedix", "4.2.1", "Chest Strap"),
            DeviceInfo("CardioRhythm X2", "HealthSystems", "5.0.3", "Medical Monitor"),
            DeviceInfo("VitalPulse Watch", "WearTech", "1.9.7", "Smartwatch")
        )
        
        val selectedDevice = deviceModels[random.nextInt(deviceModels.size)]
        
        // Create a unique device ID
        val deviceId = "HR-${random.nextInt(999999).toString().padStart(6, '0')}"
        
        // Random battery level (20-100%)
        val batteryLevel = 20 + random.nextInt(81)
        
        // Random signal strength (60-95%)
        val signalStrength = 60 + random.nextInt(36)
        
        connectedDevice = selectedDevice.copy(
            id = deviceId,
            batteryLevel = batteryLevel,
            signalStrength = signalStrength
        )
        
        Log.d(TAG, "Created random device: ${connectedDevice?.name} (${connectedDevice?.id})")
    }
    
    /**
     * Simulate connecting to the heart rate device
     */
    private fun simulateDeviceConnection() {
        if (connectedDevice == null) {
            Log.e(TAG, "No device available for connection")
            sendDeviceStatusUpdate("Error: No device found")
            deviceStatus = DeviceStatus.ERROR
            return
        }
        
        Log.d(TAG, "Connecting to device: ${connectedDevice?.name}")
        deviceStatus = DeviceStatus.CONNECTING
        sendDeviceStatusUpdate("Connecting to ${connectedDevice?.name}...")
        
        // Simulate connection process with a delay
        Handler(Looper.getMainLooper()).postDelayed({
            // 90% chance of successful connection
            if (Random.nextDouble() < 0.9) {
                deviceStatus = DeviceStatus.CONNECTED
                Log.d(TAG, "Successfully connected to ${connectedDevice?.name}")
                sendDeviceStatusUpdate("Connected to ${connectedDevice?.name}")
                
                // Start sending heart rate data
                startGeneratingHeartRateData()
            } else {
                // Simulate a connection failure
                deviceStatus = DeviceStatus.ERROR
                Log.e(TAG, "Failed to connect to ${connectedDevice?.name}")
                sendDeviceStatusUpdate("Error: Connection failed")
            }
        }, 2000) // 2 second delay to simulate connection time
    }
    
    /**
     * Simulate disconnecting from the heart rate device
     */
    private fun simulateDeviceDisconnection() {
        if (deviceStatus == DeviceStatus.CONNECTED || deviceStatus == DeviceStatus.MONITORING) {
            Log.d(TAG, "Disconnecting from device: ${connectedDevice?.name}")
            deviceStatus = DeviceStatus.DISCONNECTING
            sendDeviceStatusUpdate("Disconnecting from ${connectedDevice?.name}...")
            
            // Simulate disconnection process
            Handler(Looper.getMainLooper()).postDelayed({
                deviceStatus = DeviceStatus.DISCONNECTED
                Log.d(TAG, "Disconnected from ${connectedDevice?.name}")
                sendDeviceStatusUpdate("Disconnected from ${connectedDevice?.name}")
            }, 1000)
        }
    }
    
    /**
     * Send device status update to Flutter
     */
    private fun sendDeviceStatusUpdate(message: String) {
        val statusData = HashMap<String, Any>()
        statusData["type"] = "deviceStatus"
        statusData["message"] = message
        statusData["status"] = deviceStatus.name
        
        connectedDevice?.let {
            statusData["device"] = mapOf(
                "id" to it.id,
                "name" to it.name,
                "manufacturer" to it.manufacturer,
                "firmwareVersion" to it.firmwareVersion,
                "type" to it.type,
                "batteryLevel" to it.batteryLevel,
                "signalStrength" to it.signalStrength
            )
        }
        
        eventSink?.let {
            Log.d(TAG, "Sending device status update to Flutter")
            it.success(statusData)
        }
    }
    
    /**
     * Start generating random heart rate data every 5 seconds
     */
    fun startGeneratingHeartRateData() {
        Log.d(TAG, "startGeneratingHeartRateData called")
        deviceStatus = DeviceStatus.MONITORING
        stopGeneratingHeartRateData() // Ensure no duplicate timers
        
        handler = Handler(Looper.getMainLooper())
        handler?.postDelayed(runnable, updateIntervalMs)
        
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
    }
    
    /**
     * Generate a random heart rate value and send via eventSink
     */
    private fun generateAndSendHeartRate() {
        if (deviceStatus != DeviceStatus.MONITORING || connectedDevice == null) {
            Log.d(TAG, "Not in monitoring state, won't generate heart rate")
            return
        }
        
        // Update connection quality (will fluctuate slightly)
        updateConnectionQuality()
        
        // Check if we should simulate a connection issue
        if (connectionQuality < 30) {
            simulateConnectionIssue()
            return
        }
        
        // Get the adjusted heart rate based on device accuracy and connection quality
        val heartRate = generateHeartRateValue()
        val timestamp = System.currentTimeMillis() / 1000.0
        
        // Create a map with heart rate value, timestamp, and device info
        val heartRateData = HashMap<String, Any>()
        heartRateData["type"] = "heartRate"
        heartRateData["heartRate"] = heartRate
        heartRateData["timestamp"] = timestamp
        heartRateData["connectionQuality"] = connectionQuality
        
        // Include device information
        connectedDevice?.let {
            heartRateData["device"] = mapOf(
                "id" to it.id,
                "name" to it.name,
                "manufacturer" to it.manufacturer,
                "type" to it.type,
                "batteryLevel" to it.batteryLevel,
                "signalStrength" to it.signalStrength
            )
        }
        
        Log.d(TAG, "Generating heart rate: $heartRate BPM, quality: $connectionQuality%")
        
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
     * Update the connection quality to simulate real-world fluctuations
     */
    private fun updateConnectionQuality() {
        val random = Random
        
        // Simulate signal fluctuation
        val fluctuation = random.nextInt(11) - 5 // -5 to +5 change
        connectionQuality += fluctuation
        
        // Ensure quality stays within bounds
        connectionQuality = connectionQuality.coerceIn(0, 100)
        
        // Update device signal strength occasionally
        if (random.nextInt(10) == 0) { // 10% chance
            connectedDevice?.let {
                val newSignalStrength = it.signalStrength + random.nextInt(11) - 5
                connectedDevice = it.copy(signalStrength = newSignalStrength.coerceIn(0, 100))
            }
        }
        
        // Update device battery level occasionally (should decrease slowly)
        if (random.nextInt(20) == 0) { // 5% chance
            connectedDevice?.let {
                val newBatteryLevel = it.batteryLevel - 1
                connectedDevice = it.copy(batteryLevel = newBatteryLevel.coerceAtLeast(0))
                
                // If battery gets low, send a warning
                if (newBatteryLevel <= 20 && newBatteryLevel % 5 == 0) {
                    sendDeviceStatusUpdate("Warning: ${it.name} battery low (${newBatteryLevel}%)")
                }
            }
        }
    }
    
    /**
     * Simulate a connection issue with the device
     */
    private fun simulateConnectionIssue() {
        Log.d(TAG, "Simulating connection issue, quality: $connectionQuality%")
        
        // Create status data
        val statusData = HashMap<String, Any>()
        statusData["type"] = "connectionIssue"
        statusData["message"] = "Weak signal from ${connectedDevice?.name}"
        statusData["connectionQuality"] = connectionQuality
        
        // Send to Flutter
        eventSink?.success(statusData)
        
        // We'll still try to schedule the next update
        handler?.postDelayed(runnable, updateIntervalMs)
    }
    
    /**
     * Generate a heart rate value with potential for abnormal readings
     * Adjusts based on device accuracy and connection quality
     */
    private fun generateHeartRateValue(): Int {
        val baseRate = if (Random.nextDouble() < abnormalProbability) {
            // Generate an abnormal reading
            when (Random.nextInt(4)) {
                0 -> lowHeartRateRange.random() // Low heart rate
                1 -> elevatedHeartRateRange.random() // Elevated heart rate
                2 -> highHeartRateRange.random() // High heart rate
                else -> criticalHeartRateRange.random() // Critical heart rate
            }.also {
                Log.d(TAG, "Generated abnormal heart rate: $it BPM")
            }
        } else {
            // Generate a normal heart rate
            Random.nextInt(normalMinHeartRate, normalMaxHeartRate + 1).also {
                Log.d(TAG, "Generated normal heart rate: $it BPM")
            }
        }
        
        // If connection quality or device accuracy is low, add some noise to the reading
        val deviceAccuracy = connectedDevice?.accuracy ?: 100
        val noiseLevel = (100 - ((connectionQuality + deviceAccuracy) / 2)) / 10
        
        // Add random noise based on the calculated noise level
        val noise = if (noiseLevel > 0) Random.nextInt(-noiseLevel, noiseLevel + 1) else 0
        
        return (baseRate + noise).coerceIn(30, 230) // Keep within physiological limits
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
    
    /**
     * Data class to store information about a heart rate monitoring device
     */
    data class DeviceInfo(
        val name: String,
        val manufacturer: String,
        val firmwareVersion: String,
        val type: String,
        val id: String = "",
        val batteryLevel: Int = 100,
        val signalStrength: Int = 100,
        val accuracy: Int = 95
    )
    
    /**
     * Enum describing the possible states of the device connection
     */
    enum class DeviceStatus {
        DISCONNECTED,   // No device connected
        DISCOVERING,    // Searching for devices
        CONNECTING,     // Attempting to connect
        CONNECTED,      // Connected but not yet monitoring
        MONITORING,     // Connected and actively monitoring
        DISCONNECTING,  // In the process of disconnecting
        ERROR           // An error occurred
    }
} 