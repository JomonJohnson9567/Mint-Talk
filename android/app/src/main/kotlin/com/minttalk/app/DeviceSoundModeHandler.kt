package com.minttalk.app

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Exposes the ringer mode and Do Not Disturb state to Dart, and plays the
 * incoming-call vibration.
 *
 * - EventChannel `com.minttalk.app/sound_mode`: emits
 *   `{ringerMode: "normal"|"vibrate"|"silent", dnd: Boolean}` on listen and on
 *   every ringer-mode / interruption-filter change.
 * - MethodChannel `com.minttalk.app/sound_mode_control`: `getSoundMode`,
 *   `startVibration`, `stopVibration`.
 *
 * Reading these needs no runtime permission; vibrating needs VIBRATE
 * (a normal, install-time permission).
 */
class DeviceSoundModeHandler private constructor(private val context: Context) :
    EventChannel.StreamHandler, MethodChannel.MethodCallHandler {

    companion object {
        private const val EVENTS = "com.minttalk.app/sound_mode"
        private const val CONTROL = "com.minttalk.app/sound_mode_control"

        // Ring-style pattern: wait, buzz, pause, buzz, long pause — repeated.
        private val RING_PATTERN = longArrayOf(0, 800, 400, 800, 1600)

        fun register(context: Context, messenger: BinaryMessenger) {
            val handler = DeviceSoundModeHandler(context.applicationContext)
            EventChannel(messenger, EVENTS).setStreamHandler(handler)
            MethodChannel(messenger, CONTROL).setMethodCallHandler(handler)
        }
    }

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val notificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private var events: EventChannel.EventSink? = null
    private var receiver: BroadcastReceiver? = null

    // --- EventChannel ------------------------------------------------------

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        events = sink
        sink.success(currentSoundMode())

        val filter = IntentFilter().apply {
            addAction(AudioManager.RINGER_MODE_CHANGED_ACTION)
            addAction(NotificationManager.ACTION_INTERRUPTION_FILTER_CHANGED)
        }
        val r = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                events?.success(currentSoundMode())
            }
        }
        // System broadcasts still reach a non-exported receiver.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(r, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(r, filter)
        }
        receiver = r
    }

    override fun onCancel(arguments: Any?) {
        receiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (_: IllegalArgumentException) {
                // Already unregistered.
            }
        }
        receiver = null
        events = null
    }

    // --- MethodChannel -----------------------------------------------------

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSoundMode" -> result.success(currentSoundMode())
            "startVibration" -> {
                startVibration()
                result.success(null)
            }
            "stopVibration" -> {
                vibrator()?.cancel()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // --- Helpers -----------------------------------------------------------

    private fun currentSoundMode(): Map<String, Any> {
        val ringer = when (audioManager.ringerMode) {
            AudioManager.RINGER_MODE_SILENT -> "silent"
            AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
            else -> "normal"
        }
        val filter = notificationManager.currentInterruptionFilter
        val dnd = filter != NotificationManager.INTERRUPTION_FILTER_ALL &&
            filter != NotificationManager.INTERRUPTION_FILTER_UNKNOWN
        return mapOf("ringerMode" to ringer, "dnd" to dnd)
    }

    private fun vibrator(): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)
                ?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

    private fun startVibration() {
        val v = vibrator() ?: return
        if (!v.hasVibrator()) return
        v.cancel()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            @Suppress("DEPRECATION")
            v.vibrate(RING_PATTERN, 0)
            return
        }
        val effect = VibrationEffect.createWaveform(RING_PATTERN, 0)
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
            .build()
        @Suppress("DEPRECATION")
        v.vibrate(effect, attrs)
    }
}
