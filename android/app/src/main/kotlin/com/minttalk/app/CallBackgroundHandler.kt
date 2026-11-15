package com.minttalk.app

import android.app.Activity
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.pm.PackageManager
import android.graphics.Rect
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Log
import android.util.Rational
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridge for keeping a call alive and visible while the app is in the
 * background: the ongoing-call foreground service ([CallForegroundService])
 * and picture-in-picture for video calls.
 *
 * MethodChannel `com.minttalk.app/call_background`, both directions:
 * - Dart → native: `show(Map)` → Boolean, `hide()`, `setPipEnabled(Boolean)`.
 * - native → Dart: `pipModeChanged(Boolean)`, `action(String)` where the
 *   action is `hangUp` / `toggleMute` / `toggleCamera` / `openCall`.
 */
class CallBackgroundHandler private constructor(private val activity: Activity) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.minttalk.app/call_background"
        private const val TAG = "minttalk:callBackground"
        const val ACTION_OPEN_CALL = "com.minttalk.app.action.OPEN_CALL"
        const val OPEN_CALL = "openCall"

        private var channel: MethodChannel? = null

        fun register(activity: Activity, messenger: BinaryMessenger): CallBackgroundHandler {
            val handler = CallBackgroundHandler(activity)
            val methodChannel = MethodChannel(messenger, CHANNEL)
            methodChannel.setMethodCallHandler(handler)
            handler.ownChannel = methodChannel
            channel = methodChannel
            return handler
        }

        /** Notification / PiP action → Dart. Main thread. */
        fun dispatchAction(action: String) {
            channel?.invokeMethod("action", action)
        }
    }

    private var ownChannel: MethodChannel? = null
    private var pipEnabled = false
    private var info: OngoingCallInfo? = null
    private var lastReportedPip = false

    private val supportsPip: Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "show" -> {
                val args = call.arguments as? Map<*, *>
                if (args == null) {
                    result.success(false)
                    return
                }
                val next = OngoingCallInfo.fromMap(args)
                val actionsChanged = next.isMuted != info?.isMuted ||
                    next.isVideoMuted != info?.isVideoMuted ||
                    next.isVideo != info?.isVideo
                info = next
                if (pipEnabled && actionsChanged) updatePipParams()
                result.success(CallForegroundService.show(activity, next))
            }
            "hide" -> {
                info = null
                CallForegroundService.hide()
                // The call is over: stop showing above the lock screen (set
                // when it was answered from the incoming-call notification).
                IncomingCallHandler.setShowOverLockScreen(activity, false)
                result.success(null)
            }
            "setPipEnabled" -> {
                setPipEnabled(call.arguments == true)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Android 8–11: no auto-enter, so enter PiP by hand when the user leaves (Home / recents). */
    fun onUserLeaveHint() {
        if (!pipEnabled || !supportsPip) return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
        ) {
            return
        }
        try {
            activity.enterPictureInPictureMode(buildPipParams())
        } catch (e: Exception) {
            Log.w(TAG, "enterPictureInPictureMode failed", e)
        }
    }

    fun onPipModeChanged(isInPip: Boolean) {
        lastReportedPip = isInPip
        ownChannel?.invokeMethod("pipModeChanged", isInPip)
    }

    /**
     * Re-reports the real PiP state on resume/stop, in case a mode-change
     * callback was missed (e.g. the window closed via moveTaskToBack) —
     * Dart must never stay stuck in its compact PiP layout.
     */
    fun syncPipMode() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val actual = activity.isInPictureInPictureMode
        if (actual != lastReportedPip) onPipModeChanged(actual)
    }

    fun onOpenCallIntent() = dispatchAction(OPEN_CALL)

    fun dispose() {
        ownChannel?.setMethodCallHandler(null)
        // A recreated activity may already have registered its own channel.
        if (channel === ownChannel) channel = null
        ownChannel = null
        // The Flutter engine (and the call and the socket with it) goes away
        // with the activity — nothing left to keep alive.
        CallForegroundService.hideAll()
    }

    private fun setPipEnabled(enabled: Boolean) {
        if (pipEnabled == enabled) return
        pipEnabled = enabled
        updatePipParams()
        // Call ended (or stopped being video) while floating: close the
        // window; the call summary is waiting when the user comes back.
        if (!enabled && supportsPip && activity.isInPictureInPictureMode) {
            activity.moveTaskToBack(false)
        }
    }

    private fun updatePipParams() {
        if (!supportsPip || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        try {
            activity.setPictureInPictureParams(buildPipParams())
        } catch (e: Exception) {
            Log.w(TAG, "setPictureInPictureParams failed", e)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun buildPipParams(): PictureInPictureParams {
        val builder = PictureInPictureParams.Builder()
            // The app is portrait-locked; matches the call screen.
            .setAspectRatio(Rational(9, 16))
            .setActions(if (pipEnabled) pipActions() else emptyList())
        // The whole call screen shrinks into the window — a smooth
        // shrink animation instead of a fade.
        val bounds = Rect()
        if (activity.window.decorView.getGlobalVisibleRect(bounds)) {
            builder.setSourceRectHint(bounds)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(pipEnabled).setSeamlessResizeEnabled(false)
        }
        return builder.build()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun pipActions(): List<RemoteAction> {
        val current = info
        val isMuted = current?.isMuted ?: false
        val isVideoMuted = current?.isVideoMuted ?: false
        val mute = remoteAction(
            if (isMuted) R.drawable.ic_call_mic_off else R.drawable.ic_call_mic,
            if (isMuted) "Unmute" else "Mute",
            CallActionReceiver.TOGGLE_MUTE,
        )
        val camera = remoteAction(
            if (isVideoMuted) R.drawable.ic_call_videocam_off else R.drawable.ic_call_videocam,
            if (isVideoMuted) "Camera on" else "Camera off",
            CallActionReceiver.TOGGLE_CAMERA,
        )
        val hangUp = remoteAction(R.drawable.ic_call_end, "Hang up", CallActionReceiver.HANG_UP)

        val max = activity.maxNumPictureInPictureActions
        return when {
            max >= 3 -> listOf(mute, camera, hangUp)
            max == 2 -> listOf(mute, hangUp)
            max == 1 -> listOf(hangUp)
            else -> emptyList()
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun remoteAction(iconRes: Int, title: String, action: String) = RemoteAction(
        Icon.createWithResource(activity, iconRes),
        title,
        title,
        CallActionReceiver.pendingIntent(activity, action),
    )
}
