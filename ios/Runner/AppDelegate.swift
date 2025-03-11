import Flutter
import UIKit
import os.log

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  // The heart rate module instance
  private var heartRateModule: HeartRateModule?
  private let logger = OSLog(subsystem: "com.example.heart_rate_assessment", category: "AppDelegate")
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Get the Flutter view controller
    let controller = window?.rootViewController as! FlutterViewController
    
    os_log("Setting up Flutter channels", log: logger, type: .info)
    
    // Set up the heart rate event channel
    let heartRateChannel = FlutterEventChannel(
      name: "com.example.heart_rate_assessment/heart_rate",
      binaryMessenger: controller.binaryMessenger
    )
    
    // Set up the heart rate control method channel
    let heartRateControlChannel = FlutterMethodChannel(
      name: "com.example.heart_rate_assessment/heart_rate_control",
      binaryMessenger: controller.binaryMessenger
    )
    
    // Handle method calls from Flutter
    heartRateControlChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      os_log("Received method call: %@", log: self.logger, type: .debug, call.method)
      
      switch call.method {
      case "startHeartRateMonitoring":
        os_log("Starting heart rate monitoring", log: self.logger, type: .debug)
        self.heartRateModule?.startGeneratingHeartRateData()
        result(true)
      case "stopHeartRateMonitoring":
        os_log("Stopping heart rate monitoring", log: self.logger, type: .debug)
        self.heartRateModule?.stopGeneratingHeartRateData()
        result(true)
      default:
        os_log("Unknown method: %@", log: self.logger, type: .error, call.method)
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Create the heart rate module
    heartRateModule = HeartRateModule()
    
    // Register the event channel for heart rate data
    heartRateChannel.setStreamHandler(heartRateModule)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Stop heart rate monitoring when app enters background
  override func applicationDidEnterBackground(_ application: UIApplication) {
    heartRateModule?.stopGeneratingHeartRateData()
    super.applicationDidEnterBackground(application)
  }
  
  // Resume heart rate monitoring when app becomes active
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    os_log("App became active", log: logger, type: .debug)
    heartRateModule?.startGeneratingHeartRateData()
  }
  
  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)
    os_log("App will resign active", log: logger, type: .debug)
    heartRateModule?.stopGeneratingHeartRateData()
  }
}
