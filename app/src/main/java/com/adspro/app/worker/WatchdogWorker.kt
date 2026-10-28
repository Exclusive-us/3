package com.adspro.app.worker
import android.app.ActivityManager
import android.content.*
import android.os.Build
import androidx.work.*
import com.adspro.app.service.SmsSyncService
class WatchdogWorker(c: Context, p: WorkerParameters) : Worker(c, p) {
    override fun doWork(): Result {
        @Suppress("DEPRECATION")
        val running = (applicationContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager).getRunningServices(Int.MAX_VALUE).any { it.service.className == SmsSyncService::class.java.name }
        if (!running) {
            val i = Intent(applicationContext, SmsSyncService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) applicationContext.startForegroundService(i) else applicationContext.startService(i)
        }
        return Result.success()
    }
}
