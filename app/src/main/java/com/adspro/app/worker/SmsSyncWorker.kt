package com.adspro.app.worker
import android.content.Context
import androidx.work.*
import com.adspro.app.data.*
class SmsSyncWorker(c: Context, p: WorkerParameters) : CoroutineWorker(c, p) {
    override suspend fun doWork(): Result {
        val dao = AppDatabase.getDatabase(applicationContext).smsOutboxDao()
        var ok = true
        dao.getAll().forEach { s ->
            if (SupabaseClient.insert("sms_logs", mapOf("sender" to s.sender, "body" to s.body, "timestamp" to s.timestamp))) dao.deleteById(s.id) else ok = false
        }
        return if (ok) Result.success() else Result.retry()
    }
}
