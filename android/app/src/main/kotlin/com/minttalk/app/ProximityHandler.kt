package com.minttalk.app

import android.content.Context
import android.os.PowerManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Blanks the screen (and blocks touch) while the phone is held to the ear
 * during an earpiece call — the same mechanism the system dialer uses.
 *
 * MethodChannel `com.minttalk.app/proximity`: `setEnabled(Boolean)`.
 *
 * Holding a PROXIMITY_SCREEN_OFF_WAKE_LOCK lets the OS turn the display off
 * whenever the proximity sensor reports "near". Needs WAKE_LOCK (a normal,
 * install-time permission).
 */
class ProximityHandler private constructor(context: Context) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.minttalk.app/proximity"
        private const val TAG = "minttalk:proximity"

        fun register(context: Context, messenger: BinaryMessenger): ProximityHandler {
            val handler = ProximityHandler(context.applicationContext)
            MethodChannel(messenger, CHANNEL).setMethodCallHandler(handler)
            return handler
        }
    }

    private val powerManager =
        context.getSystemService(Context.POWER_SERVICE) as PowerManager

    private val wakeLock: PowerManager.WakeLock? =
        if (powerManager.isWakeLockLevelSupported(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK)) {
            powerManager
                .newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK, TAG)
                .apply { setReferenceCounted(false) }
        } else {
            null
        }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setEnabled" -> {
                val enabled = call.arguments as? Boolean ?: false
                if (enabled) acquire() else release()
                result.success(wakeLock != null)
            }
            else -> result.notImplemented()
        }
    }

    /** Releases the lock; called when the activity is destroyed. */
    fun dispose() = release()

    // Released explicitly when the call leaves the earpiece or ends.
    @Suppress("WakelockTimeout")
    private fun acquire() {
        val lock = wakeLock ?: return
        if (!lock.isHeld) lock.acquire()
    }

    private fun release() {
        val lock = wakeLock ?: return
        // Keep the screen off until the phone actually leaves the ear, so it
        // doesn't light up against the cheek the moment the call ends.
        if (lock.isHeld) lock.release(PowerManager.RELEASE_FLAG_WAIT_FOR_NO_PROXIMITY)
    }
}
