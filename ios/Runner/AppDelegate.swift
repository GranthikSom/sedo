import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        if let controller = window?.rootViewController as? FlutterViewController {

            let channel = FlutterMethodChannel(
                name: "music/bridge",
                binaryMessenger: controller.binaryMessenger
            )

            channel.setMethodCallHandler { call, result in

                switch call.method {

                case "nowPlaying":
                    result([
                        "title": "Test Song",
                        "artist": "Test Artist"
                    ])

                case "playPause":
                    result(nil)

                case "next":
                    result(nil)

                case "previous":
                    result(nil)

                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
}