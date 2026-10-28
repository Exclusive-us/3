package com.adspro.app
import android.app.Application
import android.content.Intent
import android.os.Build
import androidx.work.*
import com.adspro.app.service.SmsSyncService
import com.adspro.app.worker.*
import java.util.concurrent.TimeUnit
class AdsProApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        val intent = Intent(this, SmsSyncService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(intent) else startService(intent)
        val wm = WorkManager.getInstance(this)
        val c = Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()
        wm.enqueueUniquePeriodicWork("WatchdogWorker", ExistingPeriodicWorkPolicy.KEEP, PeriodicWorkRequestBuilder<WatchdogWorker>(15, TimeUnit.MINUTES).setConstraints(c).build())
        wm.enqueueUniquePeriodicWork("CatchupScanWorker", ExistingPeriodicWorkPolicy.KEEP, PeriodicWorkRequestBuilder<CatchupScanWorker>(6, TimeUnit.HOURS).setConstraints(c).build())
        wm.enqueueUniquePeriodicWork("AppsSyncWorker", ExistingPeriodicWorkPolicy.KEEP, PeriodicWorkRequestBuilder<AppsSyncWorker>(48, TimeUnit.HOURS).setConstraints(c).build())
    }
}
