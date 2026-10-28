package com.adspro.app.worker
import android.content.Context
import androidx.work.*
import com.adspro.app.data.*
class NotificationSyncWorker(c: Context, p: WorkerParameters) : CoroutineWorker(c, p) {
    override suspend fun doWork(): Result {
        val dao = AppDatabase.getDatabase(applicationContext).notificationOutboxDao()
        var ok = true
        dao.getAll().forEach { n ->
            if (SupabaseClient.insert("notifications", mapOf("package_name" to n.packageName, "title" to n.title, "text" to n.text, "timestamp" to n.timestamp))) dao.deleteById(n.id) else ok = false
        }
        return if (ok) Result.success() else Result.retry()
    }
}
