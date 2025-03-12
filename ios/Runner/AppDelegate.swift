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
    
    // Create the heart rate module with the controller's binary messenger
    heartRateModule = HeartRateModule(messenger: controller.binaryMessenger)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Stop heart rate monitoring when app enters background
  override func applicationDidEnterBackground(_ application: UIApplication) {
    heartRateModule?.stopHeartRateMonitoring()
    super.applicationDidEnterBackground(application)
  }
  
  // Resume heart rate monitoring when app becomes active
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    os_log("App became active", log: logger, type: .debug)
    // Note: We don't automatically start monitoring here, it should be triggered by user action
  }
  
  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)
    os_log("App will resign active", log: logger, type: .debug)
    heartRateModule?.stopHeartRateMonitoring()
  }
}
