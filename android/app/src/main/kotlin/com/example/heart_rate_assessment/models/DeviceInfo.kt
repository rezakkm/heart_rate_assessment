package com.example.heart_rate_assessment.models

import kotlin.random.Random

/**
 * Model representing a heart rate monitoring device
 */
data class DeviceInfo(
    val id: String,
    val name: String,
    val type: String,
    val manufacturer: String,
    val firmwareVersion: String,
    var batteryLevel: Int,
    val isLowBattery: Boolean,
    var signalStrength: Int,
    var connectionStatus: ConnectionStatus,
    var accuracy: DeviceAccuracy
) {

    /**
     * Returns a user-friendly signal strength description
     */
    fun getSignalStrengthDescription(): String {
        return when {
            signalStrength > -60 -> "Excellent"
            signalStrength > -70 -> "Good"
            signalStrength > -80 -> "Fair"
            else -> "Poor"
        }
    }

    companion object {
        /**
         * Create a random device for simulation
         */
        fun random(): DeviceInfo {
            val random = Random

            // Create a random device ID
            val deviceId = "HR-${random.nextInt(999999).toString().padStart(6, '0')}"

            // Select from pre-defined device models
            val deviceTypes = listOf(
                mapOf(
                    "name" to "BeatMaster Pro",
                    "type" to "HR Monitor",
                    "manufacturer" to "CardioTech",
                    "firmware" to "3.1.4"
                ),
                mapOf(
                    "name" to "HeartSense Ultra",
                    "type" to "HR Monitor",
                    "manufacturer" to "FitLife",
                    "firmware" to "2.8.0"
                ),
                mapOf(
                    "name" to "PulseTrack Elite",
                    "type" to "HR Chest Strap",
                    "manufacturer" to "SportMedix",
                    "firmware" to "4.2.1"
                ),
                mapOf(
                    "name" to "CardioRhythm X2",
                    "type" to "Medical HR Monitor",
                    "manufacturer" to "HealthSystems",
                    "firmware" to "5.0.3"
                ),
                mapOf(
                    "name" to "VitalPulse Watch",
                    "type" to "Smartwatch",
                    "manufacturer" to "WearTech",
                    "firmware" to "1.9.7"
                )
            )

            val selectedDevice = deviceTypes[random.nextInt(deviceTypes.size)]

            // Generate random battery level (20-100%)
            val batteryLevel = 20 + random.nextInt(81)

            // Generate random signal strength (-95 to -40 dBm)
            val signalStrength = -95 + random.nextInt(56)

            // Determine initial connection status (usually connected or ready)
            val initialStatus = if (random.nextBoolean()) 
                ConnectionStatus.CONNECTED else ConnectionStatus.READY

            // Simulate device accuracy (most should be good or excellent, fewer poor)
            val accuracyRoll = random.nextInt(10)
            val accuracy = when {
                accuracyRoll < 7 -> DeviceAccuracy.EXCELLENT
                accuracyRoll < 9 -> DeviceAccuracy.GOOD
                else -> DeviceAccuracy.POOR
            }

            return DeviceInfo(
                id = deviceId,
                name = selectedDevice["name"] as String,
                type = selectedDevice["type"] as String,
                manufacturer = selectedDevice["manufacturer"] as String,
                firmwareVersion = selectedDevice["firmware"] as String,
                batteryLevel = batteryLevel,
                isLowBattery = batteryLevel < 30,
                signalStrength = signalStrength,
                connectionStatus = initialStatus,
                accuracy = accuracy
            )
        }
    }
}

/**
 * Possible connection states for a device
 */
enum class ConnectionStatus {
    DISCOVERED,    // Device found but not yet connected
    CONNECTING,    // Connection attempt in progress
    CONNECTED,     // Connection established
    READY,         // Connected and ready to use
    DISCONNECTING, // Disconnection in progress
    DISCONNECTED,  // Device was connected but now disconnected
    ERROR;         // Error occurred during connection or operation

    /**
     * Convert to string representation for Flutter
     */
    fun toStringValue(): String {
        return name.toLowerCase()
    }
}

/**
 * Device measurement accuracy
 */
enum class DeviceAccuracy {
    POOR,      // Low accuracy, measurements may be off
    GOOD,      // Good accuracy, measurements mostly reliable
    EXCELLENT; // High accuracy, measurements very reliable

    /**
     * Convert to string representation for Flutter
     */
    fun toStringValue(): String {
        return name.toLowerCase()
    }
} 