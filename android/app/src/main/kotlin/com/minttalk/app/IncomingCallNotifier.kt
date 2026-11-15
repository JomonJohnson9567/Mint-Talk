package com.minttalk.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.Person
import androidx.core.graphics.drawable.IconCompat

/** What the incoming-call notification shows. Mirrors Dart's `IncomingCallAlert`. */
data class IncomingCallAlert(
    val callId: String,
    val callerName: String,
    val avatarUrl: String?,
    val isVideo: Boolean,
    /** Ring time left; the notification removes itself after it as a backstop. */
    val timeoutMs: Long,
) {
    companion object {
        fun fromMap(map: Map<*, *>): IncomingCallAlert? {
            val callId = (map["callId"] as? String)?.takeIf { it.isNotBlank() } ?: return null
            return IncomingCallAlert(
                callId = callId,
                callerName = map["callerName"] as? String ?: "",
                avatarUrl = (map["avatarUrl"] as? String)?.takeIf { it.isNotBlank() },
                isVideo = map["isVideo"] as? Boolean ?: false,
                timeoutMs = (map["timeoutMs"] as? Number)?.toLong() ?: 20_000L,
            )
        }
    }
}

/**
 * The heads-up "Incoming call" notification shown while the app is in the
 * background: CallStyle with Decline / Answer, plus a full-screen intent so
 * a locked or sleeping phone wakes straight into the app's ringing screen.
 *
 * The channel is silent on purpose — the Dart ringer (`IncomingRingerService`)
 * plays the tone and vibration, following the device's ringer mode and DND,
 * exactly like in the foreground.
 *
 * - Answer → opens [MainActivity] ([ACTION_ANSWER]): the mic/camera
 *   service may only start from the foreground, and Android 12+ forbids
 *   starting an activity from a broadcast (notification trampoline).
 * - Tap / full-screen → opens [MainActivity] ([ACTION_SHOW]).
 * - Decline → [CallActionReceiver] (the app stays in the background).
 *
 * Main thread only.
 */
object IncomingCallNotifier {
    private const val TAG = "minttalk:incomingCall"
    private const val CHANNEL_ID = "incoming_calls"
    private const val NOTIFICATION_ID = 0x4D55

    const val ACTION_ANSWER = "com.minttalk.app.action.ANSWER_INCOMING"
    const val ACTION_SHOW = "com.minttalk.app.action.SHOW_INCOMING"
    const val ACTION_DECLINE = "com.minttalk.app.action.DECLINE_INCOMING"
    const val EXTRA_CALL_ID = "callId"

    /** The call currently shown, null when none — guards late avatar re-posts. */
    private var current: IncomingCallAlert? = null

    fun show(context: Context, alert: IncomingCallAlert): Boolean {
        val app = context.applicationContext
        val manager = app.getSystemService(NotificationManager::class.java) ?: return false
        createChannel(manager)
        current = alert
        val posted = post(app, manager, alert, avatar = null)
        alert.avatarUrl?.let { url ->
            CallAvatarLoader.load(app, url) { bitmap ->
                if (bitmap != null && current == alert) post(app, manager, alert, bitmap)
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
            !manager.canUseFullScreenIntent()
        ) {
            Log.i(TAG, "Full-screen intent not allowed — heads-up only")
        }
        return posted
    }

    fun hide(context: Context) {
        current = null
        context.applicationContext.getSystemService(NotificationManager::class.java)
            ?.cancel(NOTIFICATION_ID)
    }

    private fun post(
        context: Context,
        manager: NotificationManager,
        alert: IncomingCallAlert,
        avatar: Bitmap?,
    ): Boolean {
        return try {
            manager.notify(NOTIFICATION_ID, build(context, alert, avatar, callStyle = true))
            true
        } catch (e: Exception) {
            // CallStyle can be refused on some builds — fall back to a plain
            // high-priority notification with the same actions.
            Log.w(TAG, "CallStyle incoming notification failed", e)
            try {
                manager.notify(NOTIFICATION_ID, build(context, alert, avatar, callStyle = false))
                true
            } catch (e2: Exception) {
                Log.w(TAG, "Incoming notification failed", e2)
                false
            }
        }
    }

    private fun build(
        context: Context,
        alert: IncomingCallAlert,
        avatar: Bitmap?,
        callStyle: Boolean,
    ): Notification {
        val name = alert.callerName.ifBlank { "Incoming Caller" }
        val kind = if (alert.isVideo) "video" else "audio"
        val answer = activityIntent(context, ACTION_ANSWER, alert.callId)
        val decline = declineIntent(context, alert.callId)
        val show = activityIntent(context, ACTION_SHOW, alert.callId)

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(
                if (alert.isVideo) R.drawable.ic_call_videocam else R.drawable.ic_call_notification,
            )
            .setContentTitle(name)
            .setContentText("Incoming $kind call")
            .setOngoing(true)
            .setAutoCancel(false)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(show)
            .setFullScreenIntent(show, true)
            .setTimeoutAfter(alert.timeoutMs.coerceAtLeast(1_000L))

        avatar?.let { builder.setLargeIcon(it) }

        if (callStyle) {
            val person = Person.Builder()
                .setName(name)
                .setImportant(true)
                .apply { avatar?.let { setIcon(IconCompat.createWithBitmap(it)) } }
                .build()
            builder.setStyle(
                NotificationCompat.CallStyle.forIncomingCall(person, decline, answer)
                    .setIsVideo(alert.isVideo),
            )
        } else {
            builder
                .addAction(R.drawable.ic_call_end, "Decline", decline)
                .addAction(
                    if (alert.isVideo) R.drawable.ic_call_videocam else R.drawable.ic_call_notification,
                    "Answer",
                    answer,
                )
        }
        return builder.build()
    }

    private fun activityIntent(context: Context, action: String, callId: String): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .setAction(action)
            .putExtra(EXTRA_CALL_ID, callId)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(
            context,
            action.hashCode(),
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun declineIntent(context: Context, callId: String): PendingIntent {
        val intent = Intent(context, CallActionReceiver::class.java)
            .setAction(ACTION_DECLINE)
            .putExtra(EXTRA_CALL_ID, callId)
        return PendingIntent.getBroadcast(
            context,
            ACTION_DECLINE.hashCode(),
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun createChannel(manager: NotificationManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Incoming calls",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Rings for incoming calls while MintTalk is in the background"
                // The Dart ringer plays the tone/vibration (ringer mode + DND aware).
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            },
        )
    }
}
