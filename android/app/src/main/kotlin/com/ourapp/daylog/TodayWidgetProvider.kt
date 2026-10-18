package com.ourapp.daylog

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// The Today widget: the day's progress, what's next, and a button that
/// opens Quick start. The app writes the text (lib/app/home_widget_sync.dart);
/// this only draws it, so the widget works without the app running.
class TodayWidgetProvider : HomeWidgetProvider() {
    /// An app update cancels the taps the widget was drawn with, leaving it
    /// dead until the app next runs: redraw it right away.
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, TodayWidgetProvider::class.java),
            )
            if (ids.isNotEmpty()) onUpdate(context, manager, ids)
            return
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.today_widget).apply {
                setTextViewText(
                    R.id.widget_title,
                    widgetData.getString("title", null) ?: context.getString(R.string.widget_today),
                )
                setTextViewText(
                    R.id.widget_progress,
                    widgetData.getString("progress", null)
                        ?: context.getString(R.string.widget_open_app),
                )
                val detail = widgetData.getString("detail", null)
                setTextViewText(R.id.widget_detail, detail ?: "")
                setViewVisibility(
                    R.id.widget_detail,
                    if (detail.isNullOrEmpty()) View.GONE else View.VISIBLE,
                )
                val next = widgetData.getString("next", null)
                setTextViewText(R.id.widget_next, next ?: "")
                setViewVisibility(
                    R.id.widget_next,
                    if (next.isNullOrEmpty()) View.GONE else View.VISIBLE,
                )
                setTextViewText(
                    R.id.widget_button,
                    widgetData.getString("button", null)
                        ?: context.getString(R.string.widget_start),
                )
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("daylog://today"),
                    ),
                )
                setOnClickPendingIntent(
                    R.id.widget_button,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("daylog://quickstart"),
                    ),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
