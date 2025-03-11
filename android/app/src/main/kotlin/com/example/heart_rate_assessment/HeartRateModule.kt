package com.example.heart_rate_assessment

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.util.*
import kotlin.random.Random

/**
 * HeartRateModule that generates random heart rate values
 * This is the Android equivalent of the iOS HeartRateModule
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
    private val updateIntervalMs = 5000L // 5 seconds
    private val abnormalProbability = 0.3 // 30% chance of abnormal reading
    
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
     * Start generating random heart rate data every 5 seconds
     */
    fun startGeneratingHeartRateData() {
        Log.d(TAG, "startGeneratingHeartRateData called")
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
        val heartRate = generateHeartRateValue()
        
        // Create a map with heart rate value and timestamp
        val heartRateData = HashMap<String, Any>()
        heartRateData["heartRate"] = heartRate
        heartRateData["timestamp"] = System.currentTimeMillis() / 1000.0
        
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
     * Generate a heart rate value with potential for abnormal readings
     */
    private fun generateHeartRateValue(): Int {
        // Decide if we should generate an abnormal reading
        return if (Random.nextDouble() < abnormalProbability) {
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