import Flutter
import UIKit
import MediaPlayer

public class MusicBridgePlugin: NSObject, FlutterPlugin {

    private let systemPlayer = MPMusicPlayerController.systemMusicPlayer

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "music/bridge",
            binaryMessenger: registrar.messenger()
        )
        let instance = MusicBridgePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "nowPlaying":
            handleNowPlaying(result: result)

        case "playPause":
            systemPlayer.play()
            result(nil)

        case "next":
            systemPlayer.skipToNextItem()
            result(nil)

        case "previous":
            systemPlayer.skipToPreviousItem()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleNowPlaying(result: @escaping FlutterResult) {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo

        if let info = nowPlayingInfo {
            result([
                "title": info[MPMediaItemPropertyTitle] as? String ?? "Unknown",
                "artist": info[MPMediaItemPropertyArtist] as? String ?? "Unknown"
            ])
        } else {
            if let nowPlayingItem = systemPlayer.nowPlayingItem {
                result([
                    "title": nowPlayingItem.title ?? "Unknown",
                    "artist": nowPlayingItem.artist ?? "Unknown"
                ])
            } else {
                result([
                    "title": "Unknown",
                    "artist": "Unknown"
                ])
            }
        }
    }
}
