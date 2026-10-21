package com.ourapp.daylog

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager

/// The home-screen icon follows the color theme: each theme has a launcher
/// alias (AndroidManifest.xml, `.Icon<Theme>`), and only the chosen one is
/// enabled. The launcher picks the change up on its own, usually within a
/// few seconds.
object IconSwitcher {
    private val themes = listOf(
        "lavender", "rose", "papaya", "ocean", "matcha", "lilac", "sky",
        "honey", "slate", "mint", "cherry", "forest", "midnight", "mocha",
        "roseGold",
    )

    private fun alias(context: Context, theme: String) =
        ComponentName(context, "${context.packageName}.Icon${theme.replaceFirstChar { it.uppercase() }}")

    /// Shows [theme]'s icon. Does nothing if it already shows (switching
    /// can make some launchers redraw or drop a home-screen shortcut).
    fun set(context: Context, theme: String) {
        val wanted = if (theme in themes) theme else "lavender"
        val pm = context.packageManager
        fun enabled(t: String): Boolean = when (pm.getComponentEnabledSetting(alias(context, t))) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED -> false
            else -> t == "lavender" // the manifest default
        }
        if (enabled(wanted) && themes.none { it != wanted && enabled(it) }) return
        // The new one first, so there's never a moment with no icon.
        pm.setComponentEnabledSetting(
            alias(context, wanted),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        for (t in themes) {
            if (t == wanted || !enabled(t)) continue
            pm.setComponentEnabledSetting(
                alias(context, t),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }
}
