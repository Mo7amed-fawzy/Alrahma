package com.example.alrahma

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.media.MediaScannerConnection
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val IMAGE_CHANNEL = "save_image_util"
    private val UPDATE_CHANNEL = "alrahma/install_apk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Image scanner channel (كما كان)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IMAGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "scanFile") {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        MediaScannerConnection.scanFile(this, arrayOf(path), null, null)
                        result.success(true)
                    } else {
                        result.error("NO_PATH", "Path is null", null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        // Update installer channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UPDATE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canRequestInstall" -> {
                        val canInstall = canRequestPackageInstalls()
                        result.success(canInstall)
                    }
                    "requestInstallPermission" -> {
                        try {
                            requestInstallPermission()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("REQUEST_FAILED", e.message, null)
                        }
                    }
                    "installApk" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("NO_PATH", "path is null", null)
                            return@setMethodCallHandler
                        }
                        try {
                            // If Android O+ and not allowed -> throw special error back to Dart
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !canRequestPackageInstalls()) {
                                result.error("INSTALL_PERMISSION_REQUIRED", "User must enable install-from-unknown-sources for this app", null)
                                return@setMethodCallHandler
                            }
                            installApk(path)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INSTALL_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun canRequestPackageInstalls(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
        } else {
            true // older versions don't require permission
        }
    }

    private fun requestInstallPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName"))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun installApk(path: String) {
        val file = File(path)
        if (!file.exists()) throw Exception("APK file not found: $path")

        val uri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            FileProvider.getUriForFile(this, "${applicationContext.packageName}.fileprovider", file)
        } else {
            Uri.fromFile(file)
        }

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }
}
