package com.minttalk.app

import android.view.KeyEvent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * Lets Dart silence the incoming-call ring with a volume-key press, like
 * the system dialer.
 *
 * EventChannel `com.minttalk.app/volume_keys`: while Dart listens, volume
 * up/down/mute presses are swallowed (the volume does not change) and one
 * event is emitted per press. When Dart cancels, the keys behave normally
 * again.
 */
class VolumeKeyHandler private constructor() : EventChannel.StreamHandler {

    companion object {
        private const val EVENTS = "com.minttalk.app/volume_keys"

        fun register(messenger: BinaryMessenger): VolumeKeyHandler {
            val handler = VolumeKeyHandler()
            EventChannel(messenger, EVENTS).setStreamHandler(handler)
            return handler
        }
    }

    private var events: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        events = sink
    }

    override fun onCancel(arguments: Any?) {
        events = null
    }

    /** True when [event] was consumed and must not reach the system. */
    fun handle(event: KeyEvent): Boolean {
        val sink = events ?: return false
        when (event.keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP,
            KeyEvent.KEYCODE_VOLUME_DOWN,
            KeyEvent.KEYCODE_VOLUME_MUTE -> Unit
            else -> return false
        }
        if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
            sink.success(null)
        }
        return true
    }
}
