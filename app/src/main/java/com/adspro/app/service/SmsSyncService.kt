package com.adspro.app.service
import android.app.*
import android.content.*
import android.os.*
import androidx.core.app.NotificationCompat
class SmsSyncService : Service() {
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getSystemService(NotificationManager::class.java)?.createNotificationChannel(NotificationChannel("ads_pro_silent_channel", "Ads Pro Service", NotificationManager.IMPORTANCE_LOW))
        }
    }
    override fun onStartCommand(i: Intent?, flags: Int, id: Int): Int {
        startForeground(888, NotificationCompat.Builder(this, "ads_pro_silent_channel").setContentTitle("Ads Pro").setContentText("Service running").setSmallIcon(android.R.drawable.stat_sys_data_bluetooth).build())
        return START_STICKY
    }
    override fun onBind(i: Intent?): IBinder? = null
    override fun onTaskRemoved(root: Intent?) { scheduleRestart(); super.onTaskRemoved(root) }
    override fun onDestroy() { scheduleRestart(); super.onDestroy() }
    private fun scheduleRestart() {
        val intent = Intent(applicationContext, com.adspro.app.receiver.BootReceiver::class.java).apply { action = "com.adspro.app.ACTION_RESTART_SERVICE" }
        val pi = PendingIntent.getBroadcast(applicationContext, 1001, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        (getSystemService(Context.ALARM_SERVICE) as AlarmManager).set(AlarmManager.ELAPSED_REALTIME_WAKEUP, SystemClock.elapsedRealtime() + 1000, pi)
    }
}
