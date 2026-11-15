package com.minttalk.app

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.view.WindowManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridge for the host side while the app is minimized: the "online for
 * calls" standby mode of [CallForegroundService], and the incoming-call
 * notification ([IncomingCallNotifier]).
 *
 * MethodChannel `com.minttalk.app/incoming_call`, both directions:
 * - Dart → native: `showStandby(Map)` → Boolean, `hideStandby()`,
 *   `showIncomingCall(Map)` → Boolean, `hideIncomingCall()`,
 *   `clearLockScreenOverride()`.
 * - native → Dart: `incomingAction({action, callId})` where action is
 *   `answer` / `decline` / `open`.
 */
class IncomingCallHandler private constructor(private val activity: Activity) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.minttalk.app/incoming_call"
        const val ANSWER = "answer"
        const val DECLINE = "decline"
        const val OPEN = "open"

        private var channel: MethodChannel? = null

        fun register(activity: Activity, messenger: BinaryMessenger): IncomingCallHandler {
            val handler = IncomingCallHandler(activity)
            val methodChannel = MethodChannel(messenger, CHANNEL)
            methodChannel.setMethodCallHandler(handler)
            handler.ownChannel = methodChannel
            channel = methodChannel
            return handler
        }

        /** Notification action → Dart. Main thread. */
        fun dispatchAction(action: String, callId: String) {
            channel?.invokeMethod("incomingAction", mapOf("action" to action, "callId" to callId))
        }

        /**
         * Lets the activity show above the lock screen and wake the display —
         * only for a ringing / answered call, cleared again once it's over.
         */
        fun setShowOverLockScreen(activity: Activity, enabled: Boolean) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                activity.setShowWhenLocked(enabled)
                activity.setTurnScreenOn(enabled)
            } else {
                @Suppress("DEPRECATION")
                val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                if (enabled) activity.window.addFlags(flags) else activity.window.clearFlags(flags)
            }
        }
    }

    private var ownChannel: MethodChannel? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "showStandby" -> {
                val args = call.arguments as? Map<*, *>
                result.success(
                    args != null &&
                        CallForegroundService.showStandby(activity, HostStandbyInfo.fromMap(args)),
                )
            }
            "hideStandby" -> {
                CallForegroundService.hideStandby()
                result.success(null)
            }
            "showIncomingCall" -> {
                val alert = (call.arguments as? Map<*, *>)?.let(IncomingCallAlert::fromMap)
                result.success(alert != null && IncomingCallNotifier.show(activity, alert))
            }
            "hideIncomingCall" -> {
                IncomingCallNotifier.hide(activity)
                result.success(null)
            }
            "clearLockScreenOverride" -> {
                setShowOverLockScreen(activity, false)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * The incoming-call notification's Answer / tap / full-screen intent
     * brought the activity forward. Returns true when [intent] was one.
     */
    fun onIncomingIntent(intent: Intent): Boolean {
        val action = when (intent.action) {
            IncomingCallNotifier.ACTION_ANSWER -> ANSWER
            IncomingCallNotifier.ACTION_SHOW -> OPEN
            else -> return false
        }
        val callId = intent.getStringExtra(IncomingCallNotifier.EXTRA_CALL_ID) ?: return true
        setShowOverLockScreen(activity, true)
        // Answered: stop the heads-up at once. A tap / full-screen launch
        // keeps it until Dart's ringing screen is up (it hides it on resume).
        if (action == ANSWER) IncomingCallNotifier.hide(activity)
        dispatchAction(action, callId)
        return true
    }

    fun dispose() {
        ownChannel?.setMethodCallHandler(null)
        // A recreated activity may already have registered its own channel.
        if (channel === ownChannel) channel = null
        ownChannel = null
        IncomingCallNotifier.hide(activity)
    }
}
