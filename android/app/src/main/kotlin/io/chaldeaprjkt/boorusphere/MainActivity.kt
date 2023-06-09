package io.chaldeaprjkt.boorusphere

import StorageUtil
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        StorageUtil.setUp(flutterEngine.dartExecutor.binaryMessenger, AndroidStorageUtil())
    }
}
