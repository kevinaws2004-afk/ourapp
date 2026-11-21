package com.bonsday.app

import android.accessibilityservice.AccessibilityService
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

/// Focus-mode app blocking (Me → Focus → Block distracting apps). While a
/// focus session runs, opening an app the person chose to block sends them
/// back to Bonsday with a short note. It only looks at which app came to
/// the front (the window-change event's package name); it never reads what's
/// on the screen, and nothing leaves the phone.
class AppBlockerService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val app = event.packageName?.toString() ?: return
        if (app == packageName) return
        val config = AppBlocker.config(this)
        if (!config.active || app !in config.blocked) return
        val label = try {
            packageManager.getApplicationLabel(
                packageManager.getApplicationInfo(app, 0)
            ).toString()
        } catch (_: PackageManager.NameNotFoundException) {
            app
        }
        // Bonsday (the running timer) comes to the front over it. Going
        // home first would land on the launcher instead.
        startActivity(
            Intent(this, MainActivity::class.java).addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            )
        )
        Toast.makeText(
            this,
            getString(R.string.blocker_blocked, label),
            Toast.LENGTH_SHORT,
        ).show()
    }

    override fun onInterrupt() {}
}

/// The blocker's settings, written by the app (daylog/blocker channel) and
/// read by [AppBlockerService].
object AppBlocker {
    private const val PREFS = "daylog_blocker"

    data class Config(val active: Boolean, val blocked: Set<String>)

    fun config(context: Context): Config {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return Config(
            active = prefs.getBoolean("active", false),
            blocked = prefs.getStringSet("blocked", emptySet()) ?: emptySet(),
        )
    }

    fun setBlocked(context: Context, packages: List<String>) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putStringSet("blocked", packages.toSet()).apply()
    }

    fun setActive(context: Context, active: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean("active", active).apply()
    }

    /// Whether the person turned the service on in Accessibility settings.
    fun isEnabled(context: Context): Boolean {
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        val me = ComponentName(context, AppBlockerService::class.java)
        return enabled.split(':').any {
            ComponentName.unflattenFromString(it) == me
        }
    }

    /// Apps with a launcher icon (what someone would open), except this one.
    fun launchableApps(context: Context): List<Map<String, Any>> {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(intent, 0)
            .filter { it.activityInfo.packageName != context.packageName }
            .distinctBy { it.activityInfo.packageName }
            .sortedBy { it.loadLabel(pm).toString().lowercase() }
            .map {
                val app = mutableMapOf<String, Any>(
                    "package" to it.activityInfo.packageName,
                    "label" to it.loadLabel(pm).toString(),
                )
                iconPng(it.loadIcon(pm))?.let { png -> app["icon"] = png }
                // Games, social and video apps: the usual distractions.
                val category = it.activityInfo.applicationInfo.category
                app["distracting"] = category == android.content.pm.ApplicationInfo.CATEGORY_GAME ||
                    category == android.content.pm.ApplicationInfo.CATEGORY_SOCIAL ||
                    category == android.content.pm.ApplicationInfo.CATEGORY_VIDEO
                app
            }
    }

    /// A small PNG of an app's icon, for the app picker.
    private fun iconPng(drawable: android.graphics.drawable.Drawable): ByteArray? = try {
        val size = 72
        val bitmap = android.graphics.Bitmap.createBitmap(size, size, android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bitmap)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(canvas)
        val out = java.io.ByteArrayOutputStream()
        bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, out)
        out.toByteArray()
    } catch (_: Exception) {
        null
    }

    /// Opens this service's own page in Accessibility settings (Android 13+:
    /// one switch, and one Back to return), else the Accessibility list.
    fun openSettings(context: Context) {
        val component = ComponentName(context, AppBlockerService::class.java).flattenToString()
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            try {
                context.startActivity(
                    Intent("android.settings.ACCESSIBILITY_DETAILS_SETTINGS")
                        .putExtra(Intent.EXTRA_COMPONENT_NAME, component)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                )
                return
            } catch (_: Exception) {
            }
        }
        context.startActivity(
            Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
    }
}
