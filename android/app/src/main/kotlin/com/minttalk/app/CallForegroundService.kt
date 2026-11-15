package com.minttalk.app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.Person
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.IconCompat

/**
 * The app's single foreground service, in one of two modes:
 *
 * 1. **Call** — keeps a call running while the app is in the background
 *    and shows it in the notification shade / status bar like a phone call.
 *    - Foreground service of type microphone (+ camera for video calls):
 *      without it Android 11+ cuts the app's mic/camera access shortly
 *      after it leaves the screen.
 *    - Call-style ongoing notification (system call chip on Android 12+):
 *      caller name + avatar, running timer, Hang up / Mute / Camera
 *      actions, tap returns to the call.
 *
 * 2. **Host standby** — while a host is online waiting for calls, keeps the
 *    process (and with it the presence socket) alive when the app is
 *    minimized, so an incoming call can still ring. Without it Android 14+
 *    freezes the cached process within seconds. Type `specialUse`, quiet
 *    "You're online" notification.
 *
 * A call always wins; when it ends the service drops back to standby if
 * the host is still online, otherwise it stops. Driven from Dart through
 * [CallBackgroundHandler] (call) and [IncomingCallHandler] (standby).
 * Main thread only.
 */
class CallForegroundService : Service() {

    companion object {
        private const val TAG = "minttalk:callService"
        private const val CHANNEL_ID = "ongoing_call"
        private const val STANDBY_CHANNEL_ID = "host_online"
        private const val NOTIFICATION_ID = 0x4D54

        /** The running (foreground) service, null while none / stopping. */
        private var instance: CallForegroundService? = null

        /**
         * The single source of truth: what Dart wants shown right now, null
         * once the call is over. Every onStartCommand — including a late,
         * queued one arriving after hide() — acts on this, so a stopped call
         * can never resurrect its notification.
         */
        private var desiredInfo: OngoingCallInfo? = null

        /** Host is online waiting for calls; null when offline. Same rules as [desiredInfo]. */
        private var desiredStandby: HostStandbyInfo? = null

        /**
         * Returns false when the service can't be shown yet — no microphone
         * permission (Android 14 rejects a microphone service without it), or
         * Android 12+ refusing a start from the background. Dart retries.
         */
        fun show(context: Context, info: OngoingCallInfo): Boolean {
            desiredInfo = info
            instance?.let { return it.render(info) }
            val app = context.applicationContext
            if (!isGranted(app, Manifest.permission.RECORD_AUDIO)) return false
            return start(app)
        }

        /** The call is over: back to standby if the host is still online, else stop. */
        fun hide() {
            desiredInfo = null
            instance?.refresh()
        }

        /**
         * Host went online (Ready). Must be called while the app is in the
         * foreground — Android 12+ refuses to start the service from the
         * background. Returns false when it couldn't start.
         */
        fun showStandby(context: Context, standby: HostStandbyInfo): Boolean {
            desiredStandby = standby
            instance?.let {
                // An ongoing call keeps its own notification; standby
                // takes over again when the call ends.
                if (desiredInfo == null) it.renderStandby(standby)
                return true
            }
            return start(context.applicationContext)
        }

        /** Host went offline. Leaves a running call untouched. */
        fun hideStandby() {
            desiredStandby = null
            if (desiredInfo == null) instance?.stopNow()
        }

        /** The Flutter engine is gone — nothing can be in a call or online. */
        fun hideAll() {
            desiredInfo = null
            desiredStandby = null
            instance?.stopNow()
        }

        private fun start(app: Context): Boolean = try {
            ContextCompat.startForegroundService(
                app,
                Intent(app, CallForegroundService::class.java),
            )
            true
        } catch (e: Exception) {
            Log.w(TAG, "Could not start the foreground service", e)
            false
        }

        private fun isGranted(context: Context, permission: String) =
            ContextCompat.checkSelfPermission(context, permission) ==
                PackageManager.PERMISSION_GRANTED
    }

    private var lastInfo: OngoingCallInfo? = null
    private var isForeground = false
    private var currentTypes = -1
    private var avatarUrl: String? = null
    private var avatar: Bitmap? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        createChannels()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val info = desiredInfo
        val standby = desiredStandby
        // Also covers a start delivered to a service object that was
        // already stopping (no new onCreate).
        if (info != null) {
            instance = this
            render(info)
        } else if (standby != null) {
            instance = this
            renderStandby(standby)
        } else {
            // startForegroundService() obliges a startForeground() call even
            // when the call already ended — satisfy it, then stop at once.
            // A standby-only start may have no microphone permission, and
            // Android 14 rejects a microphone service without it.
            val types = if (isGranted(this, Manifest.permission.RECORD_AUDIO)) {
                micServiceType()
            } else {
                standbyServiceType()
            }
            startForegroundSafely(buildNotification(placeholderInfo()), types, null)
            stopNow()
        }
        return START_NOT_STICKY
    }

    /** App swiped away from recents: end any call and go offline rather than leave either running. */
    override fun onTaskRemoved(rootIntent: Intent?) {
        if (desiredInfo != null) CallBackgroundHandler.dispatchAction(CallActionReceiver.HANG_UP)
        IncomingCallNotifier.hide(this)
        desiredInfo = null
        desiredStandby = null
        stopNow()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        if (instance === this) instance = null
        isForeground = false
        super.onDestroy()
    }

    /** True when the service is (still) in the foreground showing [info]. */
    fun render(info: OngoingCallInfo): Boolean {
        try {
            lastInfo = info
            loadAvatarIfNeeded(info.avatarUrl)
            val notification = buildNotification(info)
            val types = serviceTypesFor(info)
            if (!isForeground || types != currentTypes) {
                startForegroundSafely(notification, types, micServiceType())
            } else {
                getSystemService(NotificationManager::class.java)
                    ?.notify(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            // A notification problem must never take the call (or app) down.
            Log.w(TAG, "Updating the call notification failed", e)
        }
        return isForeground
    }

    fun renderStandby(standby: HostStandbyInfo) {
        try {
            lastInfo = null
            avatarUrl = null
            avatar = null
            val notification = buildStandbyNotification(standby)
            val types = standbyServiceType()
            if (!isForeground || types != currentTypes) {
                startForegroundSafely(notification, types, null)
            } else {
                getSystemService(NotificationManager::class.java)
                    ?.notify(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Showing the online notification failed", e)
        }
    }

    /** Re-applies what Dart wants now that the call is gone. */
    private fun refresh() {
        if (desiredInfo != null) return
        val standby = desiredStandby
        if (standby != null) renderStandby(standby) else stopNow()
    }

    fun stopNow() {
        if (instance === this) instance = null
        lastInfo = null
        avatarUrl = null
        avatar = null
        try {
            ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        } catch (e: Exception) {
            Log.w(TAG, "stopForeground failed", e)
        }
        isForeground = false
        stopSelf()
    }

    /** Microphone service type; 0 before Android 11, which has no per-type checks. */
    private fun micServiceType(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
        } else {
            0
        }

    /** `specialUse` on Android 14+, where a type is mandatory; none before. */
    private fun standbyServiceType(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        } else {
            0
        }

    private fun serviceTypesFor(info: OngoingCallInfo): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return 0
        var types = ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
        if (info.isVideo && isGranted(this, Manifest.permission.CAMERA)) {
            types = types or ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA
        }
        return types
    }

    /**
     * Starts (or re-types) the foreground service. On failure retries once
     * with [fallbackTypes] when given, and stops if still not in the
     * foreground.
     */
    private fun startForegroundSafely(
        notification: android.app.Notification,
        types: Int,
        fallbackTypes: Int?,
    ) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                ServiceCompat.startForeground(this, NOTIFICATION_ID, notification, types)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            isForeground = true
            currentTypes = types
        } catch (e: Exception) {
            // Typically adding the camera type from the background on
            // Android 14+. Keep the microphone-only service if possible.
            Log.w(TAG, "startForeground(types=$types) failed", e)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
                fallbackTypes != null &&
                types != fallbackTypes
            ) {
                try {
                    ServiceCompat.startForeground(this, NOTIFICATION_ID, notification, fallbackTypes)
                    isForeground = true
                    currentTypes = fallbackTypes
                    return
                } catch (e2: Exception) {
                    Log.w(TAG, "startForeground(types=$fallbackTypes) failed", e2)
                }
            }
            if (!isForeground) stopNow()
        }
    }

    private fun placeholderInfo() = OngoingCallInfo(
        displayName = "MintTalk",
        avatarUrl = null,
        isVideo = false,
        isMuted = false,
        isVideoMuted = false,
        statusText = "",
        chronometerBaseEpochMs = null,
    )

    private fun buildNotification(info: OngoingCallInfo): android.app.Notification {
        val person = Person.Builder()
            .setName(info.displayName.ifBlank { "MintTalk" })
            .setImportant(true)
            .apply { avatar?.let { setIcon(IconCompat.createWithBitmap(it)) } }
            .build()

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(
                if (info.isVideo) R.drawable.ic_call_videocam else R.drawable.ic_call_notification,
            )
            .setContentText(info.statusText)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(openAppIntent(CallBackgroundHandler.ACTION_OPEN_CALL))
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setStyle(
                NotificationCompat.CallStyle.forOngoingCall(
                    person,
                    CallActionReceiver.pendingIntent(this, CallActionReceiver.HANG_UP),
                ),
            )
            .addAction(
                NotificationCompat.Action.Builder(
                    if (info.isMuted) R.drawable.ic_call_mic_off else R.drawable.ic_call_mic,
                    if (info.isMuted) "Unmute" else "Mute",
                    CallActionReceiver.pendingIntent(this, CallActionReceiver.TOGGLE_MUTE),
                ).build(),
            )

        if (info.isVideo) {
            builder.addAction(
                NotificationCompat.Action.Builder(
                    if (info.isVideoMuted) R.drawable.ic_call_videocam else R.drawable.ic_call_videocam_off,
                    if (info.isVideoMuted) "Camera on" else "Camera off",
                    CallActionReceiver.pendingIntent(this, CallActionReceiver.TOGGLE_CAMERA),
                ).build(),
            )
        }

        avatar?.let { builder.setLargeIcon(it) }

        val base = info.chronometerBaseEpochMs
        if (base != null) {
            builder.setWhen(base).setShowWhen(true).setUsesChronometer(true)
        } else {
            builder.setShowWhen(false)
        }
        return builder.build()
    }

    private fun buildStandbyNotification(standby: HostStandbyInfo): android.app.Notification {
        val kinds = when {
            standby.audio && standby.video -> "audio & video"
            standby.video -> "video"
            else -> "audio"
        }
        return NotificationCompat.Builder(this, STANDBY_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_call_notification)
            .setContentTitle("You're online")
            .setContentText("Ready for $kinds calls")
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(openAppIntent(Intent.ACTION_MAIN))
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    private fun openAppIntent(action: String): PendingIntent {
        val intent = Intent(this, MainActivity::class.java)
            .setAction(action)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(
            this,
            action.hashCode(),
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Ongoing calls",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = "Shows your call while MintTalk is in the background"
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
            },
        )
        manager.createNotificationChannel(
            NotificationChannel(
                STANDBY_CHANNEL_ID,
                "Online for calls",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Keeps you reachable for calls while MintTalk is minimized"
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
            },
        )
    }

    private fun loadAvatarIfNeeded(url: String?) {
        if (url == avatarUrl) return
        avatarUrl = url
        avatar = null
        if (url == null) return
        CallAvatarLoader.load(this, url) { bitmap ->
            if (bitmap == null || avatarUrl != url || instance !== this) return@load
            avatar = bitmap
            lastInfo?.let { render(it) }
        }
    }
}

/** What the host-standby notification shows. Mirrors Dart's `startHostStandby`. */
data class HostStandbyInfo(val audio: Boolean, val video: Boolean) {
    companion object {
        fun fromMap(map: Map<*, *>) = HostStandbyInfo(
            audio = map["audio"] as? Boolean ?: false,
            video = map["video"] as? Boolean ?: false,
        )
    }
}
