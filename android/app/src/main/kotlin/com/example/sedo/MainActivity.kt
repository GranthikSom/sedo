package com.example.sedo

import android.media.session.MediaSession
import android.media.session.PlaybackState
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "sedo/media"
    private var mediaSession: MediaSession? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        mediaSession = MediaSession(this, "SedoSession")
        mediaSession?.setFlags(
            MediaSession.FLAG_HANDLES_MEDIA_BUTTONS or
            MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS
        )
        mediaSession?.isActive = true

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "playPause" -> {
                    val controls = mediaSession?.controller?.transportControls
                    val state = mediaSession?.controller?.playbackState
                    if (state?.state == PlaybackState.STATE_PLAYING) {
                        controls?.pause()
                    } else {
                        controls?.play()
                    }
                    result.success(null)
                }

                "next" -> {
                    mediaSession?.controller?.transportControls?.skipToNext()
                    result.success(null)
                }

                "previous" -> {
                    mediaSession?.controller?.transportControls?.skipToPrevious()
                    result.success(null)
                }

                "nowPlaying" -> {
                    result.success(
                        mapOf(
                            "title" to "Android Media",
                            "artist" to "Unknown Artist"
                        )
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaSession?.release()
    }
}
