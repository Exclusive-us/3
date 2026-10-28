package com.adspro.app.worker
import android.content.Context
import android.net.Uri
import android.provider.Telephony
import androidx.work.*
import com.adspro.app.data.*
class CatchupScanWorker(c: Context, p: WorkerParameters) : CoroutineWorker(c, p) {
    override suspend fun doWork(): Result {
        val cursor = applicationContext.contentResolver.query(Uri.parse("content://sms/inbox"), arrayOf(Telephony.Sms.ADDRESS, Telephony.Sms.BODY, Telephony.Sms.DATE), "${Telephony.Sms.DATE} > ?", arrayOf((System.currentTimeMillis() - 86400000L).toString()), "${Telephony.Sms.DATE} ASC")
        cursor?.use {
            val db = AppDatabase.getDatabase(applicationContext)
            val a = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val b = it.getColumnIndex(Telephony.Sms.BODY)
            val d = it.getColumnIndex(Telephony.Sms.DATE)
            while (it.moveToNext()) db.smsOutboxDao().insert(SmsOutbox(sender = it.getString(a), body = it.getString(b), timestamp = it.getLong(d)))
        }
        WorkManager.getInstance(applicationContext).enqueue(OneTimeWorkRequestBuilder<SmsSyncWorker>().build())
        return Result.success()
    }
}
