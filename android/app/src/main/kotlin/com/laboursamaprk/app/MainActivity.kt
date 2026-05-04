package com.laboursamaprk.app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Move app to background instead of closing it
        moveTaskToBack(true)
    }
}
