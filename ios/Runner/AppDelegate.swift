import UIKit
import Flutter
import MediaPlayer

// ── MediaRemote private API via dlsym ─────────────────────────────────────

private let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)

private typealias MRMediaRemoteSendCommandType =
    @convention(c) (Int, NSDictionary?) -> Void
private typealias MRMediaRemoteGetNowPlayingInfoType =
    @convention(c) (DispatchQueue, @escaping @convention(block) (NSDictionary?) -> Void) -> Void

private let _mrSend: MRMediaRemoteSendCommandType? = {
    let sym = dlsym(RTLD_DEFAULT, "MRMediaRemoteSendCommand")
    if sym == nil { NSLog("[Sedo] dlsym MRMediaRemoteSendCommand → nil"); return nil }
    NSLog("[Sedo] dlsym MRMediaRemoteSendCommand → OK")
    return unsafeBitCast(sym, to: MRMediaRemoteSendCommandType.self)
}()

private let _mrGetNowPlaying: MRMediaRemoteGetNowPlayingInfoType? = {
    let sym = dlsym(RTLD_DEFAULT, "MRMediaRemoteGetNowPlayingInfo")
    if sym == nil { NSLog("[Sedo] dlsym MRMediaRemoteGetNowPlayingInfo → nil"); return nil }
    NSLog("[Sedo] dlsym MRMediaRemoteGetNowPlayingInfo → OK")
    return unsafeBitCast(sym, to: MRMediaRemoteGetNowPlayingInfoType.self)
}()

// ── App Delegate ───────────────────────────────────────────────────────────

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let channelName = "music/bridge"
    private var channel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        application.beginReceivingRemoteControlEvents()

        // Scene-based apps (iOS 13+) don't have window set here.
        // Defer channel setup until the scene activates with a ready view controller.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setupChannel),
            name: UIScene.didActivateNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingDidChange),
            name: NSNotification.Name("MRMediaRemoteNowPlayingInfoDidChangeNotification"),
            object: nil
        )

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    @objc private func setupChannel() {
        guard channel == nil else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let controller = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController as? FlutterViewController
        else { return }

        let chan = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: controller.binaryMessenger
        )
        channel = chan

        chan.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "playPause":  self.handlePlayPause(result: result)
            case "next":       self.handleNext(result: result)
            case "previous":   self.handlePrevious(result: result)
            case "nowPlaying": self.handleNowPlaying(result: result)
            default:           result(FlutterMethodNotImplemented)
            }
        }
    }

    @objc private func nowPlayingDidChange() {
        channel?.invokeMethod("nowPlayingChanged", arguments: nil)
    }

    // ── Playback Controls ───────────────────────────────────────────────────

    private func handlePlayPause(result: @escaping FlutterResult) {
        if let send = _mrSend { send(2, nil) }
        result(nil)
    }

    private func handleNext(result: @escaping FlutterResult) {
        if let send = _mrSend { send(4, nil) }
        result(nil)
    }

    private func handlePrevious(result: @escaping FlutterResult) {
        if let send = _mrSend { send(5, nil) }
        result(nil)
    }

    // ── Now Playing Metadata ───────────────────────────────────────────────

    private func handleNowPlaying(result: @escaping FlutterResult) {
        let fallback = {
            let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
            let title  = info?[MPMediaItemPropertyTitle]  as? String ?? "Unknown"
            let artist = info?[MPMediaItemPropertyArtist] as? String ?? "Unknown"
            let rate   = info?[MPNowPlayingInfoPropertyPlaybackRate] as? Double ?? 0
            NSLog("[Sedo] fallback → title='\(title)' artist='\(artist)' rate=\(rate)")
            result(["title": title, "artist": artist, "isPlaying": rate > 0])
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tryFetchNowPlaying(attempt: 1, result: result, fallback: fallback)
        }
    }

    private func tryFetchNowPlaying(attempt: Int, result: @escaping FlutterResult, fallback: @escaping () -> Void) {
        guard let get = _mrGetNowPlaying else { fallback(); return }

        get(DispatchQueue.main) { dict in
            if let dict = dict {
                let ns = dict as NSDictionary
                let title  = (ns["kMRMediaRemoteNowPlayingInfoTitle"] as? String)
                          ?? (ns[MPMediaItemPropertyTitle] as? String)
                          ?? "Unknown"
                let artist = (ns["kMRMediaRemoteNowPlayingInfoArtist"] as? String)
                          ?? (ns[MPMediaItemPropertyArtist] as? String)
                          ?? "Unknown"
                let rate   = (ns["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double)
                          ?? (ns[MPNowPlayingInfoPropertyPlaybackRate] as? Double)
                          ?? 0
                let artworkData = ns["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data
                var resultMap: [String: Any] = [
                    "title": title,
                    "artist": artist,
                    "isPlaying": rate > 0,
                ]
                if let data = artworkData {
                    resultMap["artwork"] = data.base64EncodedString()
                }
                NSLog("[Sedo] MRMediaRemote → title='\(title)' artist='\(artist)' rate=\(rate)")
                result(resultMap)
            } else if attempt < 2 {
                NSLog("[Sedo] MRMediaRemote → nil (attempt \(attempt)/2), retrying in 1s…")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.tryFetchNowPlaying(attempt: attempt + 1, result: result, fallback: fallback)
                }
            } else {
                NSLog("[Sedo] MRMediaRemote → nil after \(attempt) attempts")
                fallback()
            }
        }
    }
}
