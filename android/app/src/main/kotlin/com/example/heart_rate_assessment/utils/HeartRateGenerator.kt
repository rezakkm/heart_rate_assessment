package com.example.heart_rate_assessment.utils

import android.util.Log
import kotlin.random.Random

/**
 * Utility class to generate simulated heart rate values
 */
class HeartRateGenerator {
    // Default heart rate range
    private val normalMinHeartRate = 60
    private val normalMaxHeartRate = 100
    
    // Categories of abnormal heart rates
    private val lowHeartRateRange = 40..59
    private val elevatedHeartRateRange = 101..130
    private val highHeartRateRange = 131..180
    private val criticalHeartRateRange = 181..220
    
    // Configuration parameters
    private val abnormalProbability = 0.3 // 30% chance of abnormal reading
    
    private val TAG = "HeartRateGenerator"
    
    /**
     * Generate a heart rate value with potential for abnormal readings
     */
    fun generateHeartRateValue(): Int {
        // Decide if we should generate an abnormal reading
        return if (Random.nextDouble() < abnormalProbability) {
            // Generate an abnormal reading
            when (Random.nextInt(4)) {
                0 -> lowHeartRateRange.random().also {
                    Log.d(TAG, "Generated abnormal LOW heart rate: $it BPM")
                }
                1 -> elevatedHeartRateRange.random().also {
                    Log.d(TAG, "Generated abnormal ELEVATED heart rate: $it BPM")
                }
                2 -> highHeartRateRange.random().also {
                    Log.d(TAG, "Generated abnormal HIGH heart rate: $it BPM")
                }
                else -> criticalHeartRateRange.random().also {
                    Log.d(TAG, "Generated abnormal CRITICAL heart rate: $it BPM")
                }
            }
        } else {
            // Generate a normal heart rate
            Random.nextInt(normalMinHeartRate, normalMaxHeartRate + 1).also {
                Log.d(TAG, "Generated normal heart rate: $it BPM")
            }
        }
    }
} 