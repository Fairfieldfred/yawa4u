package com.fredblair.live_card

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Posts the rest-timer countdown as an Android 16 "Live Update".
 *
 * Why this exists: a plain IMPORTANCE_LOW ongoing notification is demoted to a
 * bare icon on the One UI lock screen. Requesting promotion is the only way to
 * get a persistent card (plus status chip and Samsung Now Bar) without raising
 * importance, which would make it audible on every set.
 *
 * This is a package (not app code) so `GeneratedPluginRegistrant` registers it
 * in BOTH the UI engine and the background engine that
 * flutter_local_notifications spins up for notification actions — otherwise a
 * lock-screen +30s could not repost the card.
 *
 * The action buttons deliberately reuse flutter_local_notifications'
 * ActionBroadcastReceiver rather than a receiver of our own, so the existing
 * Dart handler keeps owning the state transition (mutating the persisted
 * deadline, rescheduling the alert). We only render.
 */
class LiveCardPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private companion object {
        const val CHANNEL = "yawa4u/live_card"

        // flutter_local_notifications' action-intent contract (v22).
        const val FLN_ACTION_TAPPED =
            "com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver.ACTION_TAPPED"
        const val FLN_RECEIVER =
            "com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"
        const val EXTRA_NOTIFICATION_ID = "notificationId"
        const val EXTRA_NOTIFICATION_TAG = "notificationTag"
        const val EXTRA_ACTION_ID = "actionId"
        const val EXTRA_CANCEL_NOTIFICATION = "cancelNotification"
        const val EXTRA_PAYLOAD = "payload"

        const val ANDROID_16 = 36
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "isSupported" -> result.success(isSupported())
                "showCountdown" -> {
                    showCard(call, countdownUntilMs = call.argument<Long>("untilMs"))
                    result.success(true)
                }
                "showPaused" -> {
                    showCard(call, countdownUntilMs = null)
                    result.success(true)
                }
                "cancel" -> {
                    NotificationManagerCompat.from(context).cancel(call.argument<Int>("id")!!)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("live_card_error", e.message, null)
        }
    }

    /**
     * True only when the OS can actually promote. Feature-detected rather than
     * inferred from the API level: users can revoke Live Updates per app, and
     * OEMs may add their own criteria.
     */
    private fun isSupported(): Boolean {
        if (Build.VERSION.SDK_INT < ANDROID_16) return false
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return try {
            NotificationManager::class.java
                .getMethod("canPostPromotedNotifications")
                .invoke(nm) as Boolean
        } catch (_: Exception) {
            false
        }
    }

    /**
     * The channel must exist before notifying, and we cannot rely on
     * flutter_local_notifications having created it: when promotion is
     * available it never posts this channel at all, so on a fresh install the
     * notification would be dropped silently. IMPORTANCE_LOW keeps the card
     * mute — promotion, not importance, is what makes it visible.
     */
    private fun ensureChannel(call: MethodCall, channelId: String) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (nm.getNotificationChannel(channelId) != null) return
        val channel = android.app.NotificationChannel(
            channelId,
            call.argument<String>("channelName") ?: "Rest countdown",
            NotificationManager.IMPORTANCE_LOW,
        )
        channel.description = call.argument<String>("channelDescription")
        channel.setShowBadge(false)
        channel.enableVibration(false)
        channel.setSound(null, null)
        nm.createNotificationChannel(channel)
    }

    private fun showCard(call: MethodCall, countdownUntilMs: Long?) {
        val id = call.argument<Int>("id")!!
        val channelId = call.argument<String>("channelId")!!
        val title = call.argument<String>("title") ?: ""
        val body = call.argument<String>("body") ?: ""
        val smallIcon = context.applicationInfo.icon
        ensureChannel(call, channelId)

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(smallIcon)
            .setContentTitle(title)
            .setContentText(body)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(Notification.CATEGORY_WORKOUT)
            .setContentIntent(launchAppIntent())

        if (countdownUntilMs != null) {
            // System-rendered countdown: ticks with no app process involved.
            builder.setWhen(countdownUntilMs)
                .setShowWhen(true)
                .setUsesChronometer(true)
                .setChronometerCountDown(true)
            val remaining = countdownUntilMs - System.currentTimeMillis()
            // Retires the card exactly at the deadline even if we are dead.
            if (remaining > 0) builder.setTimeoutAfter(remaining)
            // Status-bar chip label. Reflective + best-effort: it is cosmetic,
            // and must never break the card if the API is absent.
            call.argument<String>("chipText")?.let { chip ->
                try {
                    NotificationCompat.Builder::class.java
                        .getMethod("setShortCriticalText", String::class.java)
                        .invoke(builder, chip)
                } catch (_: Exception) {
                    // Older androidx: no chip text, card still promotes.
                }
            }
        } else {
            builder.setShowWhen(false)
        }

        @Suppress("UNCHECKED_CAST")
        val actions = call.argument<List<Map<String, Any>>>("actions") ?: emptyList()
        for (action in actions) {
            builder.addAction(
                0,
                action["label"] as String,
                actionIntent(id, action["id"] as String, action["cancelNotification"] as Boolean),
            )
        }

        builder.setRequestPromotedOngoing(true)

        NotificationManagerCompat.from(context).notify(id, builder.build())
    }

    /** Broadcast to flutter_local_notifications so the Dart handler runs. */
    private fun actionIntent(notificationId: Int, actionId: String, cancelNotification: Boolean): PendingIntent {
        val intent = Intent(FLN_ACTION_TAPPED).apply {
            setClassName(context.packageName, FLN_RECEIVER)
            putExtra(EXTRA_NOTIFICATION_ID, notificationId)
            putExtra(EXTRA_NOTIFICATION_TAG, null as String?)
            putExtra(EXTRA_ACTION_ID, actionId)
            putExtra(EXTRA_CANCEL_NOTIFICATION, cancelNotification)
            putExtra(EXTRA_PAYLOAD, null as String?)
        }
        return PendingIntent.getBroadcast(
            context,
            actionId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )
    }

    private fun launchAppIntent(): PendingIntent? {
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return null
        return PendingIntent.getActivity(
            context,
            0,
            launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
