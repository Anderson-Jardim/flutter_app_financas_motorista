package com.example.app_fingo

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.view.WindowManager
import android.graphics.PixelFormat
import android.view.Gravity
import android.widget.TextView
import okhttp3.*
import org.json.JSONArray
import java.io.IOException

class MyAccessibilityService : AccessibilityService() {
    private val client = OkHttpClient()
    private var lastCapturedValue: String? = null
    private var totalDistance = 0.0

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event != null && event.packageName == "com.ubercab.driver") {
            val rootNode = event.source ?: return
            if (event.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED || 
                event.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
                traverseNode(rootNode)
            }
        }
    }

    private fun traverseNode(node: AccessibilityNodeInfo?) {
    if (node == null) return

    if (node.className == "android.widget.TextView") {
        val text = node.text?.toString()

        // Capturando o valor monetário (R$)
        if (text != null && text.contains("R$")) {
            lastCapturedValue = extractMonetaryValue(text)
            if (lastCapturedValue != null) {
                Log.d("AccessibilityService", "Valor monetário capturado: $lastCapturedValue")
                sendDataToApi(lastCapturedValue!!)
            }
        }

        // Capturando a distância em km
        if (text != null && text.contains("km")) {
            val distance = extractDistanceValue(text)
            if (distance != null) {
                totalDistance += distance
                Log.d("AccessibilityService", "Distância capturada: $distance km, Total: $totalDistance km")
            }
        }
    }

    for (i in 0 until node.childCount) {
        traverseNode(node.getChild(i))
    }
}

// Método para extrair o valor de km
private fun extractDistanceValue(text: String): Double? {
    val distancePattern = Regex("""(\d+(\.\d+)?)\s?km""") // Padrão para capturar o número antes de "km"
    val matchResult = distancePattern.find(text)
    return matchResult?.groups?.get(1)?.value?.toDoubleOrNull()
}

    private fun extractMonetaryValue(text: String): String? {
        val balancePattern = Regex("""R\$\s?(\d+([.,]\d{2})?)""")
        val matchResult = balancePattern.find(text)
        return matchResult?.groups?.get(1)?.value
    }

    private fun sendDataToApi(monetaryValue: String) {
        val decimalValue = monetaryValue.replace(".", "").replace(",", ".").toDoubleOrNull()

        if (decimalValue != null) {
            val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val token = sharedPreferences.getString("flutter.token", null)

            if (token != null) {
                val urlGastosMensais = "http://192.168.0.118:8000/api/expenses"
                val urlInfoones = "http://192.168.0.118:8000/api/infoone"
                val urlClasscorridas = "http://192.168.0.118:8000/api/classcorridas"

                val requestGastos = Request.Builder()
                    .url(urlGastosMensais)
                    .addHeader("Authorization", "Bearer $token")
                    .build()

                client.newCall(requestGastos).enqueue(object : Callback {
                    override fun onFailure(call: Call, e: IOException) {
                        Log.e("API_ERROR", "Failed to fetch monthly expenses: $e")
                    }

                    override fun onResponse(call: Call, response: Response) {
                        if (response.isSuccessful) {
                            val responseData = response.body?.string()
                            val jsonArray = JSONArray(responseData)
                            var monthlyExpenses = 0.0

                            for (i in 0 until jsonArray.length()) {
                                val item = jsonArray.getJSONObject(i)
                                monthlyExpenses += item.getDouble("amount")
                            }

                            val requestInfoones = Request.Builder()
                                .url(urlInfoones)
                                .addHeader("Authorization", "Bearer $token")
                                .build()

                            client.newCall(requestInfoones).enqueue(object : Callback {
                                override fun onFailure(call: Call, e: IOException) {
                                    Log.e("API_ERROR", "Failed to fetch infoones data: $e")
                                }

                                override fun onResponse(call: Call, response: Response) {
                                    if (response.isSuccessful) {
                                        val infoonesData = response.body?.string()
                                        val infoonesArray = JSONArray(infoonesData)
                                        val infoonesItem = infoonesArray.getJSONObject(0)
                                        val diasTrabalhados = infoonesItem.getInt("dias_trab")
                                        val qtdCorridas = infoonesItem.getInt("qtd_corridas")

                                        val requestClasscorridas = Request.Builder()
                                            .url(urlClasscorridas)
                                            .addHeader("Authorization", "Bearer $token")
                                            .build()

                                        client.newCall(requestClasscorridas).enqueue(object : Callback {
                                            override fun onFailure(call: Call, e: IOException) {
                                                Log.e("API_ERROR", "Failed to fetch classcorridas data: $e")
                                            }

                                            override fun onResponse(call: Call, response: Response) {
                                                if (response.isSuccessful) {
                                                    val classcorridasData = response.body?.string()
                                                    val classcorridasArray = JSONArray(classcorridasData)
                                                    val classcorridasItem = classcorridasArray.getJSONObject(0)

                                                    val corridaBronze = classcorridasItem.getInt("corrida_bronze")
                                                    val corridaOuro = classcorridasItem.getInt("corrida_ouro")
                                                    val corridaDiamante = classcorridasItem.getInt("corrida_diamante")

                                                    val totalCusto = (monthlyExpenses / diasTrabalhados) / qtdCorridas
                                                    val totalLucro = decimalValue - totalCusto
                                                    val valorKm = (totalLucro / decimalValue) * 100
                                                    /* val valorKmResult = valorKm * 100 */
                                                     /* val tipoCorrida = (totalLucro / decimalValue) * 100  */

                                                    val corridaTipo: String = when {
                                                        valorKm <= corridaBronze -> "Corrida Bronze"
                                                        valorKm <= corridaOuro -> "Corrida Ouro"
                                                        else -> "Corrida Diamante"
                                                    }

                                                    Handler(Looper.getMainLooper()).post {
    
                                                        showCustomCard( corridaTipo, /* totalDistance */ valorKm)
                                                    }
                                                } else {
                                                    Log.e("API_ERROR", "Failed to fetch classcorridas data: ${response.message}")
                                                }
                                            }
                                        })
                                    } else {
                                        Log.e("API_ERROR", "Failed to fetch infoones data: ${response.message}")
                                    }
                                }
                            })
                        } else {
                            Log.e("API_ERROR", "Failed to fetch monthly expenses: ${response.message}")
                        }
                    }
                })
            } else {
                Log.e("API_ERROR", "Token is null, cannot authenticate")
            }
        } else {
            Log.e("API_ERROR", "Failed to convert monetary value to decimal")
        }
    }

    override fun onInterrupt() {}

   private fun showCustomCard( corridaTipo: String,/*totalDistance: Double, valorKm: Double */ valorKm: Double) {
    try {
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        layoutParams.gravity = Gravity.TOP /* or Gravity.CENTER */
        layoutParams.x = 0
        layoutParams.y = 0

        /* val view = LayoutInflater.from(this).inflate(R.layout.custom_dialog, null) */
        val view = LayoutInflater.from(this).inflate(R.layout.custom_dialog, null)
        val textViewTipoCorrida: TextView = view.findViewById(R.id.text_view_tipo_corrida) 
        val textViewDistancia: TextView = view.findViewById(R.id.text_view_distancia)

        // Definir o texto conforme os valores capturados
         textViewTipoCorrida.text = corridaTipo 
        textViewDistancia.text = /* "Distância total: ${"%.2f".format(totalDistance)} km / R$ ${"%.2f".format(valorKm)}" */ "Total Lucro: R$ ${"%.2f".format(valorKm)}"

        windowManager.addView(view, layoutParams)

        // Remover a notificação após 4 segundos
        Handler(Looper.getMainLooper()).postDelayed({
            windowManager.removeView(view)
        }, 4000)
    } catch (e: Exception) {
        Log.e("TAG", "Erro: ${e.message}")
    }
}

}
