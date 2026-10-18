package com.ourapp.daylog

import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.service.quicksettings.TileService
import es.antonborri.home_widget.HomeWidgetLaunchIntent

/// The "Start" tile in Quick Settings: opens Daylog on Quick start, to
/// begin something with one tap from anywhere.
class FocusTileService : TileService() {
    override fun onClick() {
        super.onClick()
        val intent = Intent(this, MainActivity::class.java).apply {
            action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
            data = Uri.parse("daylog://quickstart")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        if (Build.VERSION.SDK_INT >= 34) {
            val pending = PendingIntent.getActivity(
                this,
                1,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            startActivityAndCollapse(pending)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }
}
