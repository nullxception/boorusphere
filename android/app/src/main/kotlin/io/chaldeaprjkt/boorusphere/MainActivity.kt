package io.chaldeaprjkt.boorusphere

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        AppEnv.setUp(flutterEngine.dartExecutor.binaryMessenger, AndroidAppEnv())
        StorageUtil.setUp(flutterEngine.dartExecutor.binaryMessenger, AndroidStorageUtil())
    }
}
