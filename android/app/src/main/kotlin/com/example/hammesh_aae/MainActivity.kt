package com.example.hammesh_aae

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.hammesh_aae/apk_share"
    private val NOTIFICATION_CHANNEL = "com.example.hammesh_aae/notification"
    private val UPDATER_CHANNEL = "com.example.hammesh_aae/app_updater"
    private val CHANNEL_ID = "chat_messages_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getApkPath") {
                try {
                    val apkPath = applicationInfo.sourceDir
                    val file = File(apkPath)
                    if (file.exists()) {
                        result.success(apkPath)
                    } else {
                        result.error("UNAVAILABLE", "APK file not found", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showNotification") {
                val title = call.argument<String>("title") ?: "New Message"
                val body = call.argument<String>("body") ?: "You have a new message"
                showNativeNotification(title, body)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UPDATER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "installApk") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    try {
                        val file = File(filePath)
                        if (file.exists()) {
                            val intent = Intent(Intent.ACTION_VIEW)
                            val currentContext: Context = this
                            val apkUri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                FileProvider.getUriForFile(
                                    currentContext,
                                    "${currentContext.packageName}.fileprovider",
                                    file
                                )
                            } else {
                                Uri.fromFile(file)
                            }
                            intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
                            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            currentContext.startActivity(intent)
                            result.success(true)
                        } else {
                            result.error("FILE_NOT_FOUND", "APK file not found at $filePath", null)
                        }
                    } catch (e: Exception) {
                        result.error("INSTALL_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_PATH", "File path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun showNativeNotification(title: String, body: String) {
        try {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Chat Messages",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifications for new chat messages"
                    enableVibration(true)
                }
                notificationManager.createNotificationChannel(channel)
            }

            val builder = NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.mipmap.launcher_icon)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)

            notificationManager.notify((System.currentTimeMillis() % 10000).toInt(), builder.build())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
