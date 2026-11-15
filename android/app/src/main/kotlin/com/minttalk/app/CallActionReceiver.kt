package com.minttalk.app

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Receives taps on the ongoing-call notification's actions and on the
 * picture-in-picture window's actions, and forwards them to Dart
 * (`CallBackgroundService.actions`). Not exported — only this app's own
 * PendingIntents can reach it.
 */
class CallActionReceiver : BroadcastReceiver() {

    companion object {
        const val HANG_UP = "hangUp"
        const val TOGGLE_MUTE = "toggleMute"
        const val TOGGLE_CAMERA = "toggleCamera"

        private const val EXTRA_ACTION = "callAction"

        fun pendingIntent(context: Context, action: String): PendingIntent {
            val intent = Intent(context, CallActionReceiver::class.java)
                // Distinct Intent actions so the three PendingIntents never collapse into one.
                .setAction("com.minttalk.app.action.CALL_$action")
                .putExtra(EXTRA_ACTION, action)
            return PendingIntent.getBroadcast(
                context,
                action.hashCode(),
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        // Decline on the incoming-call notification: the app stays in the
        // background; Dart rejects the call.
        if (intent.action == IncomingCallNotifier.ACTION_DECLINE) {
            IncomingCallNotifier.hide(context)
            val callId = intent.getStringExtra(IncomingCallNotifier.EXTRA_CALL_ID) ?: return
            IncomingCallHandler.dispatchAction(IncomingCallHandler.DECLINE, callId)
            return
        }
        val action = intent.getStringExtra(EXTRA_ACTION) ?: return
        CallBackgroundHandler.dispatchAction(action)
    }
}
