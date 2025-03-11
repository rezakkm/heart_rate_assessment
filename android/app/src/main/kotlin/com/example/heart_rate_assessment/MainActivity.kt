package com.example.heart_rate_assessment

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val TAG = "MainActivity"
    
    // Channel names
    private val HEART_RATE_CHANNEL = "com.example.heart_rate_assessment/heart_rate"
    private val HEART_RATE_CONTROL_CHANNEL = "com.example.heart_rate_assessment/heart_rate_control"
    
    // Module instance
    private var heartRateModule: HeartRateModule? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "Configuring Flutter Engine")
        
        // Create the heart rate module
        heartRateModule = HeartRateModule()
        
        // Set up event channel for streaming heart rate data
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, HEART_RATE_CHANNEL)
            .setStreamHandler(heartRateModule)
        
        // Set up method channel for controlling heart rate monitoring
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEART_RATE_CONTROL_CHANNEL)
            .setMethodCallHandler { call, result ->
                Log.d(TAG, "Received method call: ${call.method}")
                
                when (call.method) {
                    "startHeartRateMonitoring" -> {
                        Log.d(TAG, "Starting heart rate monitoring")
                        heartRateModule?.startGeneratingHeartRateData()
                        result.success(true)
                    }
                    "stopHeartRateMonitoring" -> {
                        Log.d(TAG, "Stopping heart rate monitoring")
                        heartRateModule?.stopGeneratingHeartRateData()
                        result.success(true)
                    }
                    else -> {
                        Log.e(TAG, "Unknown method: ${call.method}")
                        result.notImplemented()
                    }
                }
            }
    }
    
    override fun onResume() {
        super.onResume()
        Log.d(TAG, "Activity resumed")
        heartRateModule?.startGeneratingHeartRateData()
    }
    
    override fun onPause() {
        super.onPause()
        Log.d(TAG, "Activity paused")
        heartRateModule?.stopGeneratingHeartRateData()
    }
}
