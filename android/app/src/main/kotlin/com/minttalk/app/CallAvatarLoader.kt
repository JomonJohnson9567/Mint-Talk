package com.minttalk.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Shader
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import java.net.HttpURLConnection
import java.net.URL

/**
 * Loads a caller/host avatar for a call notification: an http(s) URL or a
 * Flutter asset path, subsampled and circle-cropped to [AVATAR_SIZE_PX].
 * Shared by the ongoing-call ([CallForegroundService]) and incoming-call
 * ([IncomingCallNotifier]) notifications.
 */
object CallAvatarLoader {
    private const val TAG = "minttalk:avatar"
    private const val AVATAR_SIZE_PX = 192
    private const val MAX_AVATAR_BYTES = 8L * 1024 * 1024

    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * Decodes [url] off the main thread and hands the result (null on any
     * failure — the avatar is cosmetic) to [onLoaded] on the main thread.
     * Call from the main thread.
     */
    fun load(context: Context, url: String, onLoaded: (Bitmap?) -> Unit) {
        val assets = context.applicationContext.assets
        // Resolve the Flutter asset key on the main thread; decode off it.
        val assetKey = if (url.startsWith("http")) null else
            FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(url)
        Thread {
            val bitmap = try {
                val bytes = if (assetKey != null) {
                    assets.open(assetKey).use { it.readBytes() }
                } else {
                    download(url)
                }
                bytes?.let(::decode)
            } catch (t: Throwable) {
                // Includes OutOfMemoryError.
                Log.w(TAG, "Avatar load failed", t)
                null
            }
            mainHandler.post { onLoaded(bitmap) }
        }.start()
    }

    private fun download(url: String): ByteArray? {
        val connection = URL(url).openConnection() as HttpURLConnection
        connection.connectTimeout = 5000
        connection.readTimeout = 5000
        try {
            if (connection.responseCode !in 200..299) return null
            if (connection.contentLengthLong > MAX_AVATAR_BYTES) return null
            return connection.inputStream.use { it.readBytes() }
        } finally {
            connection.disconnect()
        }
    }

    private fun decode(bytes: ByteArray): Bitmap? {
        if (bytes.isEmpty() || bytes.size > MAX_AVATAR_BYTES) return null

        // Decode bounds first and subsample — a full-size photo would be
        // many MB of pixels for a 192 px icon.
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeByteArray(bytes, 0, bytes.size, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null
        var sample = 1
        while (minOf(bounds.outWidth, bounds.outHeight) / (sample * 2) >= AVATAR_SIZE_PX) {
            sample *= 2
        }
        val raw = BitmapFactory.decodeByteArray(
            bytes,
            0,
            bytes.size,
            BitmapFactory.Options().apply { inSampleSize = sample },
        ) ?: return null
        return circleCrop(raw)
    }

    private fun circleCrop(source: Bitmap): Bitmap {
        val size = AVATAR_SIZE_PX
        val side = minOf(source.width, source.height)
        val square = Bitmap.createBitmap(
            source,
            (source.width - side) / 2,
            (source.height - side) / 2,
            side,
            side,
        )
        val scaled = Bitmap.createScaledBitmap(square, size, size, true)
        val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = BitmapShader(scaled, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        }
        Canvas(output).drawCircle(size / 2f, size / 2f, size / 2f, paint)
        return output
    }
}
