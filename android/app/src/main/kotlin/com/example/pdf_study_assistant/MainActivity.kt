package com.example.pdf_study_assistant

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Besides hosting Flutter, posts the background-work notification with a
 * progress bar. flutter_foreground_task owns the foreground service but can
 * only show text; posting under the same notification id replaces what it
 * shows, so the service keeps running and the bar rides on top of it.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "progress" -> {
                        // percent: 0..100, or null for an indeterminate bar.
                        // bar=false shows plain text.
                        val posted = post(
                            id = SERVICE_NOTIFICATION_ID,
                            title = call.argument<String>("title") ?: "",
                            text = call.argument<String>("text") ?: "",
                            showBar = call.argument<Boolean>("bar") ?: false,
                            percent = call.argument<Int>("percent"),
                            ongoing = true,
                        )
                        result.success(posted)
                    }
                    "done" -> {
                        val posted = post(
                            id = DONE_NOTIFICATION_ID,
                            title = call.argument<String>("title") ?: "",
                            text = call.argument<String>("text") ?: "",
                            showBar = false,
                            percent = null,
                            ongoing = false,
                        )
                        result.success(posted)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun post(
        id: Int,
        title: String,
        text: String,
        showBar: Boolean,
        percent: Int?,
        ongoing: Boolean,
    ): Boolean {
        return try {
            val manager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (manager.getNotificationChannel(CHANNEL_ID) == null) {
                    manager.createNotificationChannel(
                        NotificationChannel(
                            CHANNEL_ID,
                            "Background work",
                            NotificationManager.IMPORTANCE_LOW,
                        ),
                    )
                }
                Notification.Builder(this, CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(this)
            }
            builder
                .setSmallIcon(R.drawable.ic_stat_tutor)
                .setContentTitle(title)
                .setContentText(text)
                .setColor(ACCENT)
                .setOnlyAlertOnce(true)
                .setOngoing(ongoing)
                .setAutoCancel(!ongoing)
                .setShowWhen(false)
            if (showBar) {
                builder.setProgress(100, percent ?: 0, percent == null)
            }
            packageManager.getLaunchIntentForPackage(packageName)?.let { launch ->
                builder.setContentIntent(
                    PendingIntent.getActivity(
                        this,
                        0,
                        launch,
                        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                    ),
                )
            }
            manager.notify(id, builder.build())
            true
        } catch (e: Exception) {
            false
        }
    }

    companion object {
        private const val CHANNEL = "local_ai_tutor/notifications"

        // Must match the channel and service ids in keep_alive.dart.
        private const val CHANNEL_ID = "background_work"
        private const val SERVICE_NOTIFICATION_ID = 412
        private const val DONE_NOTIFICATION_ID = 413
        private const val ACCENT = 0xFF6D4AE0.toInt()
    }
}
