package com.ourapp.daylog

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// A FragmentActivity: the system biometric prompt (app lock) and the
// Health Connect permission screen need one.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "daylog/dnd")
            .setMethodCallHandler { call, result ->
                val dnd = DoNotDisturb(applicationContext)
                when (call.method) {
                    "hasAccess" -> result.success(dnd.hasAccess())
                    "requestAccess" -> {
                        startActivity(
                            Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                        )
                        result.success(null)
                    }
                    "set" -> result.success(dnd.set(call.argument<Boolean>("on") == true))
                    else -> result.notImplemented()
                }
            }
        // Focus-mode app blocking (AppBlockerService).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "daylog/blocker")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isEnabled" -> result.success(AppBlocker.isEnabled(this))
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    }
                    "apps" -> result.success(AppBlocker.launchableApps(this))
                    "setBlocked" -> {
                        AppBlocker.setBlocked(this, call.argument<List<String>>("packages") ?: emptyList())
                        result.success(null)
                    }
                    "setActive" -> {
                        AppBlocker.setActive(this, call.argument<Boolean>("active") == true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        // Focus mode: the phone stays on the timer (Android's app pinning,
        // which the person can always leave), with the screen kept on.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "daylog/focusmode")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        try {
                            startLockTask()
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }
                    "stop" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        try {
                            stopLockTask()
                        } catch (_: Exception) {
                        }
                        result.success(null)
                    }
                    "isPinned" -> {
                        val am = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
                        result.success(am.lockTaskModeState != android.app.ActivityManager.LOCK_TASK_MODE_NONE)
                    }
                    else -> result.notImplemented()
                }
            }
        // The home-screen icon follows the color theme (IconSwitcher).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "daylog/icon")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "set" -> {
                        IconSwitcher.set(applicationContext, call.argument<String>("theme") ?: "lavender")
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        // With app lock on, the recents thumbnail mustn't show your day.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "daylog/privacy")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hideInRecents" -> {
                        val hide = call.argument<Boolean>("hide") == true
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            setRecentsScreenshotEnabled(!hide)
                        } else if (hide) {
                            // Older Android has no thumbnail-only switch.
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

/// Do Not Disturb while a focus timer runs: turns on "priority only" and
/// later puts back whatever the person had before (kept on disk, so a
/// restart in between still restores it). Never touches a setting it didn't
/// change.
class DoNotDisturb(private val context: Context) {
    private val manager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val prefs = context.getSharedPreferences("daylog_dnd", Context.MODE_PRIVATE)

    fun hasAccess(): Boolean = manager.isNotificationPolicyAccessGranted

    fun set(on: Boolean): Boolean {
        if (!hasAccess()) return false
        if (on) {
            if (!prefs.contains(KEY_PREVIOUS)) {
                val current = manager.currentInterruptionFilter
                // Already silent: nothing to do or undo.
                if (current != NotificationManager.INTERRUPTION_FILTER_ALL) return true
                prefs.edit().putInt(KEY_PREVIOUS, current).apply()
            }
            manager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_PRIORITY)
        } else if (prefs.contains(KEY_PREVIOUS)) {
            manager.setInterruptionFilter(
                prefs.getInt(KEY_PREVIOUS, NotificationManager.INTERRUPTION_FILTER_ALL)
            )
            prefs.edit().remove(KEY_PREVIOUS).apply()
        }
        return true
    }

    companion object {
        private const val KEY_PREVIOUS = "previous_filter"
    }
}
