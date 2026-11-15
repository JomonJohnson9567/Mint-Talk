package com.minttalk.app

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Device security checks that gate the whole app (see DeviceSecurityService
 * on the Dart side, which only enforces them in release builds).
 *
 * MethodChannel `com.minttalk.app/device_security`:
 *  - `isDeveloperModeEnabled` → Boolean. USB debugging can't be on without
 *    Developer options, so this covers adb too.
 *  - `openDeveloperSettings` → opens Developer options (falls back to
 *    the main Settings screen).
 */
class DeviceSecurityHandler private constructor(private val context: Context) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.minttalk.app/device_security"

        fun register(context: Context, messenger: BinaryMessenger): DeviceSecurityHandler {
            val handler = DeviceSecurityHandler(context.applicationContext)
            MethodChannel(messenger, CHANNEL).setMethodCallHandler(handler)
            return handler
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isDeveloperModeEnabled" -> result.success(isDeveloperModeEnabled())
            "openDeveloperSettings" -> {
                openDeveloperSettings()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun isDeveloperModeEnabled(): Boolean =
        Settings.Global.getInt(
            context.contentResolver,
            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
            0,
        ) != 0

    private fun openDeveloperSettings() {
        val opened = launch(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
        if (!opened) launch(Settings.ACTION_SETTINGS)
    }

    private fun launch(action: String): Boolean =
        try {
            context.startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
}
