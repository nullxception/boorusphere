package io.chaldeaprjkt.boorusphere

import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channelPath = "${BuildConfig.APPLICATION_ID}/path"
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelPath
        ).setMethodCallHandler { call, result ->
            if (call.method == "getDownload") {
                result.success(downloadPath.absolutePath)
            } else {
                result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private val downloadPath get() =
        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
}
