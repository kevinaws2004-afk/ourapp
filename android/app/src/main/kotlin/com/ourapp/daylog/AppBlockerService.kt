package com.ourapp.daylog

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
/// back to DayCraft with a short note. It only looks at which app came to
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
        // DayCraft (the running timer) comes to the front over it. Going
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
    fun launchableApps(context: Context): List<Map<String, String>> {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(intent, 0)
            .map { it.activityInfo.packageName to it.loadLabel(pm).toString() }
            .filter { it.first != context.packageName }
            .distinctBy { it.first }
            .sortedBy { it.second.lowercase() }
            .map { mapOf("package" to it.first, "label" to it.second) }
    }
}
