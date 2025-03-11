import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  // The heart rate module instance
  private var heartRateModule: HeartRateModule?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Create the heart rate module
    heartRateModule = HeartRateModule()
    
    // Get the Flutter view controller
    let controller = window?.rootViewController as! FlutterViewController
    
    // Register the event channel for heart rate data
    let heartRateChannel = FlutterEventChannel(
      name: "com.example.heart_rate_assessment/heart_rate",
      binaryMessenger: controller.binaryMessenger
    )
    
    // Set the event handler for the channel
    heartRateChannel.setStreamHandler(heartRateModule)
    
    // Optional: Add method channel for controlling the heart rate module
    let methodChannel = FlutterMethodChannel(
      name: "com.example.heart_rate_assessment/heart_rate_control",
      binaryMessenger: controller.binaryMessenger
    )
    
    // Handle method calls from Flutter
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "startHeartRateMonitoring":
        self.heartRateModule?.startGeneratingHeartRateData()
        result(true)
      case "stopHeartRateMonitoring":
        self.heartRateModule?.stopGeneratingHeartRateData()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
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
    heartRateModule?.startGeneratingHeartRateData()
    super.applicationDidBecomeActive(application)
  }
}
