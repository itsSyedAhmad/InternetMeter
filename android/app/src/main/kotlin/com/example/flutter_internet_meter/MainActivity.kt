package com.example.flutter_internet_meter

import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.graphics.*
import androidx.core.app.NotificationCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
 import android.graphics.Typeface

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_internet_meter/speed_icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "updateIcon") {
                val speed = call.argument<String>("speed") ?: "0 KB/s"
                updateNotificationIcon(speed)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun updateNotificationIcon(speedText: String) {
        val iconBitmap = createBitmapWithSpeedText(speedText,0f)
        val icon = IconCompat.createWithBitmap(iconBitmap)

        val context = applicationContext
        val notificationManager = context.getSystemService(Service.NOTIFICATION_SERVICE) as NotificationManager

        val notification = NotificationCompat.Builder(context, "speed_monitor_channel")
            .setContentTitle("Speed Monitor Running")
            .setContentText("Speed: $speedText")
            .setSmallIcon(icon)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()

        notificationManager.notify(999, notification)
    }

  

private fun createBitmapWithSpeedText(speed: String, verticalOffset: Float): Bitmap {
    val size = 196
    val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    
     canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)

    val paint = Paint().apply {
        color = Color.WHITE
        isAntiAlias = true
        typeface = Typeface.DEFAULT_BOLD
        textAlign = Paint.Align.CENTER
    }

   val parts = speed.split(" ")
    val numberText = parts[0]
    val unitText = if (parts.size > 1) parts[1] else "KB/s"

    val padding = 0f

    // Initial text sizes
    var numberTextSize = size * 0.7f
    var unitTextSize = size * 0.5f
    paint.letterSpacing = 0.0f

    // Measure text bounds
    paint.textSize = numberTextSize
    val numberWidth = paint.measureText(numberText)
    val numberBounds = Rect()
    paint.getTextBounds(numberText, 0, numberText.length, numberBounds)

    // Measure unit text bounds
    paint.textSize = unitTextSize
    val unitWidth = paint.measureText(unitText)
    val unitBounds = Rect()
    paint.getTextBounds(unitText, 0, unitText.length, unitBounds)

    // Calculate maximum text width and height
    val maxTextWidth = maxOf(numberWidth, unitWidth)
    val maxTextHeight = numberBounds.height() + unitBounds.height()

    // Aggressive scaling to prevent clipping
    var scale = 1f
    if (maxTextWidth + 2 * padding > size || maxTextHeight + 2 * padding > size) {
        val widthScale = (size - 2 * padding) / maxTextWidth
        val heightScale = (size - 2 * padding) / maxTextHeight
        scale = minOf(widthScale, heightScale)
    }

    // Apply scaling
    numberTextSize *= scale
    unitTextSize *= scale
    paint.letterSpacing *= scale

    // Final safety check: Reduce text size if still clipping (extreme cases)
    if (numberTextSize < 5 || unitTextSize < 5) {
        numberTextSize = 5f
        unitTextSize = 5f
        paint.letterSpacing = 0f
    }

    // Apply final text sizes and RE-MEASURE BOUNDS
    paint.textSize = numberTextSize
    paint.getTextBounds(numberText, 0, numberText.length, numberBounds)
    paint.textSize = unitTextSize
    paint.getTextBounds(unitText, 0, unitText.length, unitBounds)

    // Adjust baseline calculation to align with visual top
    val numberBaseline = size / 2f - numberBounds.height() / 2f - numberBounds.top + numberBounds.top / 4f // Adjust this value

    // Adjust vertical offset to minimize padding
    val adjustedVerticalOffset = verticalOffset - 2f // Adjust this value

    val numberY = numberBaseline + adjustedVerticalOffset
    val unitY = numberBaseline + numberBounds.height() + adjustedVerticalOffset

    // Draw text
    paint.textSize = numberTextSize
    canvas.drawText(numberText, size / 2f, numberY, paint)
    paint.textSize = unitTextSize
    canvas.drawText(unitText, size / 2f, unitY, paint)

    paint.letterSpacing = 0f

    return bitmap
}

}
