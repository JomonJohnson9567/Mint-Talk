package com.minttalk.app

import android.content.Intent
import android.content.res.Configuration
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var proximityHandler: ProximityHandler? = null
    private var volumeKeyHandler: VolumeKeyHandler? = null
    private var callBackgroundHandler: CallBackgroundHandler? = null
    private var incomingCallHandler: IncomingCallHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        DeviceSoundModeHandler.register(this, messenger)
        DeviceSecurityHandler.register(this, messenger)
        proximityHandler = ProximityHandler.register(this, messenger)
        volumeKeyHandler = VolumeKeyHandler.register(messenger)
        callBackgroundHandler = CallBackgroundHandler.register(this, messenger)
        incomingCallHandler = IncomingCallHandler.register(this, messenger)
    }

    // dispatchKeyEvent, not onKeyDown: FlutterView sees keys before onKeyDown.
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (volumeKeyHandler?.handle(event) == true) return true
        return super.dispatchKeyEvent(event)
    }

    // Tapped the ongoing-call notification, or the incoming-call
    // notification (Answer / tap / full-screen), while the app was running.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (incomingCallHandler?.onIncomingIntent(intent) == true) return
        if (intent.action == CallBackgroundHandler.ACTION_OPEN_CALL) {
            callBackgroundHandler?.onOpenCallIntent()
        }
    }

    override fun onResume() {
        super.onResume()
        callBackgroundHandler?.syncPipMode()
    }

    override fun onStop() {
        super.onStop()
        callBackgroundHandler?.syncPipMode()
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        callBackgroundHandler?.onUserLeaveHint()
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration,
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        callBackgroundHandler?.onPipModeChanged(isInPictureInPictureMode)
    }

    override fun onDestroy() {
        proximityHandler?.dispose()
        proximityHandler = null
        volumeKeyHandler = null
        callBackgroundHandler?.dispose()
        callBackgroundHandler = null
        incomingCallHandler?.dispose()
        incomingCallHandler = null
        super.onDestroy()
    }
}
