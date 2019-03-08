import UIKit
import Flutter
import sqflite

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "com.example.sqflite/backgrounded", binaryMessenger: controller)
    
    methodChannel.setMethodCallHandler { call, result in
        let array = call.arguments as! Array<Any>
        let handle = array[0] as! Int64
        
        // Create it here to avoid registration issue the second time
        // Not sure if that's correct though
        let backgroundEngine = FlutterEngine(name: "BackgroundIsolate", project: nil, allowHeadlessExecution: true)
        
        let callbackInformation = FlutterCallbackCache.lookupCallbackInformation(handle)
        backgroundEngine!.run(withEntrypoint: callbackInformation?.callbackName, libraryURI: callbackInformation?.callbackLibraryPath)
        
        SqflitePlugin.register(with: backgroundEngine!.registrar(forPlugin: "com.tekartik.sqflite.SqflitePlugin"))
        
        result(nil)
    }

    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
