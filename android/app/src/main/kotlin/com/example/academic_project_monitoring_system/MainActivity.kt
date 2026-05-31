package com.example.academic_project_monitoring_system

import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.academic/monotonic_clock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getElapsedRealtime" -> {
                        // SystemClock.elapsedRealtime() returns milliseconds since boot,
                        // including time spent in sleep. Not affected by wall clock changes.
                        result.success(SystemClock.elapsedRealtime())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
