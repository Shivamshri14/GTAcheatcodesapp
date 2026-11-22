package com.shivamshri.cheatcodes

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cheatcodes/stickers")
            .setMethodCallHandler { call, result ->
                if (call.method == "addPack") {
                    result.success(addPack(call.argument<String>("id") ?: "1", call.argument<String>("name") ?: "Cheat Codes"))
                } else result.notImplemented()
            }
    }

    private fun installed(pkg: String): Boolean = try {
        packageManager.getPackageInfo(pkg, 0); true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    private fun addPack(id: String, name: String): String {
        val targets = listOf("com.whatsapp", "com.whatsapp.w4b").filter { installed(it) }
        if (targets.isEmpty()) return "not_installed"
        val intent = Intent("com.whatsapp.intent.action.ENABLE_STICKER_PACK").apply {
            putExtra("sticker_pack_id", id)
            putExtra("sticker_pack_authority", "$packageName.stickercontentprovider")
            putExtra("sticker_pack_name", name)
            if (targets.size == 1) setPackage(targets[0])
        }
        return try {
            @Suppress("DEPRECATION")
            startActivityForResult(intent, 200)
            "opened"
        } catch (e: ActivityNotFoundException) {
            "not_installed"
        }
    }
}
