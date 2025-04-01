package com.example.app_fingo

import android.content.Intent
import android.provider.Settings
import android.os.Bundle
import android.view.accessibility.AccessibilityManager
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app_fingo/accessibility"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Acessando o flutterEngine de maneira segura e utilizando binaryMessenger
        flutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "openAccessibilitySettings" -> {
                        openAccessibilitySettings()
                        result.success(null)
                    }
                    "isAccessibilityEnabled" -> {
                        val isEnabled = isAccessibilityEnabled()
                        result.success(isEnabled)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    // Função para verificar se algum serviço de acessibilidade está ativado
    private fun isAccessibilityEnabled(): Boolean {
        val am = getSystemService(ACCESSIBILITY_SERVICE) as AccessibilityManager
        val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)

        if (TextUtils.isEmpty(enabledServices)) {
            return false
        }

        val colonSeparatedList = enabledServices.split(":")
        for (enabledService in colonSeparatedList) {
            if (enabledService.contains(this.packageName)) {
                return true
            }
        }
        return false
    }
}