package com.example.heart_rate_assessment

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var heartRateModule: HeartRateModule? = null
    
    // Channel names - matching iOS implementation
    private val heartRateChannelName = "com.example.heart_rate_assessment/heart_rate"
    private val heartRateControlChannelName = "com.example.heart_rate_assessment/heart_rate_control"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Create the heart rate module
        heartRateModule = HeartRateModule()
        
        // Register the event channel for heart rate data
        val heartRateChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, heartRateChannelName)
        heartRateChannel.setStreamHandler(heartRateModule)
        
        // Create method channel for controlling the heart rate module
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, heartRateControlChannelName)
        
        // Handle method calls from Flutter
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startHeartRateMonitoring" -> {
                    heartRateModule?.startGeneratingHeartRateData()
                    result.success(true)
                }
                "stopHeartRateMonitoring" -> {
                    heartRateModule?.stopGeneratingHeartRateData()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onPause() {
        super.onPause()
        // Stop heart rate monitoring when app enters background
        heartRateModule?.stopGeneratingHeartRateData()
    }
    
    override fun onResume() {
        super.onResume()
        // Resume heart rate monitoring when app becomes active
        heartRateModule?.startGeneratingHeartRateData()
    }
}
