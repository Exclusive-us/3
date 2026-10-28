package com.adspro.app.service
import android.service.notification.*
import androidx.work.*
import com.adspro.app.data.*
import com.adspro.app.worker.NotificationSyncWorker
import kotlinx.coroutines.*
class AppNotificationListener : NotificationListenerService() {
    private val scope = CoroutineScope(Dispatchers.IO)
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null || sbn.packageName == applicationContext.packageName) return
        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        if (title.isNotEmpty() || text.isNotEmpty()) {
            scope.launch {
                AppDatabase.getDatabase(applicationContext).notificationOutboxDao().insert(NotificationOutbox(packageName = sbn.packageName, title = title, text = text, timestamp = sbn.postTime))
                WorkManager.getInstance(applicationContext).enqueue(OneTimeWorkRequestBuilder<NotificationSyncWorker>().build())
            }
        }
    }
}
