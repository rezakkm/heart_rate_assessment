package com.example.heart_rate_assessment

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private var heartRateModule: HeartRateModule? = null
    
    // Channel names - matching iOS implementation
    private val heartRateChannelName = "com.example.heart_rate_assessment/heart_rate"
    private val heartRateControlChannelName = "com.example.heart_rate_assessment/heart_rate_control"
    
    private val TAG = "HeartRateActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "MainActivity created")
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "Configuring Flutter Engine")
        
        // Create the heart rate module
        heartRateModule = HeartRateModule()
        Log.d(TAG, "Heart rate module created")
        
        // Register the event channel for heart rate data
        val heartRateChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, heartRateChannelName)
        heartRateChannel.setStreamHandler(heartRateModule)
        Log.d(TAG, "Event channel registered: $heartRateChannelName")
        
        // Create method channel for controlling the heart rate module
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, heartRateControlChannelName)
        Log.d(TAG, "Method channel created: $heartRateControlChannelName")
        
        // Handle method calls from Flutter
        methodChannel.setMethodCallHandler { call, result ->
            Log.d(TAG, "Method call received: ${call.method}")
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
                    Log.e(TAG, "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onPause() {
        super.onPause()
        // Stop heart rate monitoring when app enters background
        Log.d(TAG, "Activity paused, stopping heart rate monitoring")
        heartRateModule?.stopGeneratingHeartRateData()
    }
    
    override fun onResume() {
        super.onResume()
        // Resume heart rate monitoring when app becomes active
        Log.d(TAG, "Activity resumed, starting heart rate monitoring")
        heartRateModule?.startGeneratingHeartRateData()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Activity destroyed, cleaning up resources")
        heartRateModule?.stopGeneratingHeartRateData()
        heartRateModule = null
    }
}
