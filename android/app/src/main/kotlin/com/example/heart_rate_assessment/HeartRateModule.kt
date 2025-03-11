package com.example.heart_rate_assessment

import android.os.Handler
import android.os.Looper
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
    
    private val minHeartRate = 60
    private val maxHeartRate = 100
    private val updateIntervalMs = 5000L // 5 seconds
    
    /**
     * Set up the event sink when the stream is listened to
     */
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startGeneratingHeartRateData()
    }
    
    /**
     * Clean up when the stream is cancelled
     */
    override fun onCancel(arguments: Any?) {
        stopGeneratingHeartRateData()
        eventSink = null
    }
    
    /**
     * Start generating random heart rate data every 5 seconds
     */
    fun startGeneratingHeartRateData() {
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
        handler?.removeCallbacks(runnable)
        handler = null
    }
    
    /**
     * Generate a random heart rate value and send via eventSink
     */
    private fun generateAndSendHeartRate() {
        val randomHeartRate = Random.nextInt(minHeartRate, maxHeartRate + 1)
        
        // Create a map with heart rate value and timestamp
        val heartRateData = HashMap<String, Any>()
        heartRateData["heartRate"] = randomHeartRate
        heartRateData["timestamp"] = System.currentTimeMillis() / 1000.0
        
        // Send the heart rate data to Flutter
        eventSink?.success(heartRateData)
        
        // Schedule the next update
        handler?.postDelayed(runnable, updateIntervalMs)
    }
    
    /**
     * Manually trigger an error for testing
     */
    fun sendError() {
        eventSink?.error(
            "HEART_RATE_ERROR",
            "Failed to generate heart rate data",
            null
        )
    }
} 