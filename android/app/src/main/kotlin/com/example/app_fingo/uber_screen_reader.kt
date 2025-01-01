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
import androidx.core.content.ContextCompat
import android.widget.ImageView
import com.bumptech.glide.Glide


class MyAccessibilityService : AccessibilityService() {
    private val client = OkHttpClient()
    private var lastCapturedValue: String? = null
    private var lastCapturedValuee: String? = null
    private var totalDistance = 0.0
    private var distanceValue = 0.0
    private var travelValue = 0.0
    private var lastSentValue: String? = null
    private var lastSentValuee: String? = null

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event != null && event.packageName == "com.ubercab.driver") {
            val rootNode = rootInActiveWindow ?: return
    
            // Verifica se houve alterações na janela ou clique em um botão
            if (event.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED ||
                event.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
    
                traverseNode(rootNode)
    
                // Identifica o texto "Encontrar com" na interface
                if (findTextInNode(rootNode, "Quanto você recebeu em")) {
                    Log.d("AccessibilityService", "Texto 'Quanto você recebeu em' identificado")
                    sendLastCapturedDataToApi() // Envia os últimos dados capturados
                }
            }
        }
    }

    private fun findTextInNode(node: AccessibilityNodeInfo?, textToFind: String): Boolean {
        if (node == null) return false
    
        if (node.text != null && node.text.toString().contains(textToFind, ignoreCase = true)) {
            return true
        }
    
        for (i in 0 until node.childCount) {
            if (findTextInNode(node.getChild(i), textToFind)) {
                return true
            }
        }
    
        return false
    }

    private fun traverseNode(node: AccessibilityNodeInfo?) {
        if (node == null) return
    
        if (node.className == "android.widget.Button") {
            val buttonText = node.text?.toString()
    
            // Verifica se o botão é "Selecionar" ou "Aceitar"
            if (buttonText != null && (buttonText.contains("Selecionar") || buttonText.contains("Aceitar"))) {
                Log.d("AccessibilityService", "Botão $buttonText identificado")
    
                // Percorre os elementos visíveis para capturar os valores necessários
                val rootNode = rootInActiveWindow ?: return // Usando a raiz da janela ativa
                captureValues(rootNode) // Captura os valores a partir do nó raiz
                 captureValuess(rootNode)  // Captura os valores a partir do nó raiz
    
                
            }
        }
    
        for (i in 0 until node.childCount) {
            traverseNode(node.getChild(i))
        }
    }

    private fun sendLastCapturedDataToApi() {
        if (lastCapturedValuee != null && lastCapturedValuee != lastSentValuee) {
            Log.d("AccessibilityService", "Enviando último valor capturado: $lastCapturedValuee")
            sendDataToApi(lastCapturedValuee!!) // Envia o dado capturado para a API
            lastSentValuee = lastCapturedValuee // Atualiza o último valor enviado
        } else {
            Log.d("AccessibilityService", "Nenhum novo dado para enviar")
            
        }
    }

    private fun sendLastCapturedDataToApiCard() {
        if (lastCapturedValue != null && lastCapturedValue != lastSentValue) {
            Log.d("AccessibilityService", "Enviando último valor capturado: $lastCapturedValue")
            sendDataToApiCard(lastCapturedValue!!) // Envia o dado capturado para a API
            lastSentValue = lastCapturedValue // Atualiza o último valor enviado
        } else {
            Log.d("AccessibilityService", "Nenhum novo dado para enviar")
        }
    }

    private fun captureValues(node: AccessibilityNodeInfo?) {
        if (node == null) return
    
        if (node.className == "android.widget.TextView") {
            val text = node.text?.toString()

            // Verifica se o texto contém a palavra "incluído" para bloquear a captura do valor monetário
        if (text != null && text.contains("incluído", ignoreCase = true)) {
            Log.d("AccessibilityService", "Valor monetário ao lado de 'incluído' bloqueado")
            return // Ignora a captura desse valor
        }

    
            // Captura o valor monetário (R$)
            if (text != null && text.contains("R$")) {
                lastCapturedValue = extractMonetaryValue(text)
                if (lastCapturedValue != null) {
                    Log.d("AccessibilityService", "Valor monetário capturado: $lastCapturedValue")
                    
                }
            }
    
            // Captura a distância em km
            if (text != null && text.contains("km")) {
                val distance = extractDistanceValue(text)
                if (distance != null) {
                    if (text.contains("distância")) {
                        distanceValue = distance
                    } else if (text.contains("Viagem")) {
                        travelValue = distance
                    }
    
                    totalDistance = distanceValue + travelValue
                    Log.d("AccessibilityService", "Distância total capturada: $totalDistance km")
                    
                }
            }
        }
    
        for (i in 0 until node.childCount) {
            captureValues(node.getChild(i))
        }
    }

    private fun captureValuess(node: AccessibilityNodeInfo?) {
        if (node == null) return
    
        if (node.className == "android.widget.TextView") {
            val text = node.text?.toString()
    
            // Captura o valor monetário (R$)
            if (text != null && text.contains("R$")) {
                lastCapturedValuee = extractMonetaryValue(text)
                if (lastCapturedValuee != null) {
                    Log.d("AccessibilityService", "Valor monetário capturado: $lastCapturedValuee")
                    sendLastCapturedDataToApiCard()
                }
            }
    
            // Captura a distância em km
            if (text != null && text.contains("km")) {
                val distance = extractDistanceValue(text)
                if (distance != null) {
                    if (text.contains("distância")) {
                        distanceValue = distance
                    } else if (text.contains("Viagem")) {
                        travelValue = distance
                    }
    
                    totalDistance = distanceValue + travelValue
                    Log.d("AccessibilityService", "Distância total capturada: $totalDistance km")
                    sendLastCapturedDataToApiCard()
                }
            }
        }
    
        for (i in 0 until node.childCount) {
            captureValuess(node.getChild(i))
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





//ENVIO DE DADOS CARD
    private fun sendDataToApiCard(monetaryValue: String) {

    val decimalValue = monetaryValue.replace(".", "").replace(",", ".").toDoubleOrNull()

    if (decimalValue != null) {
        val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val token = sharedPreferences.getString("flutter.token", null)

        if (token != null) {
            val urlGastosMensais = "http://192.168.0.118:8000/api/expenses"
            val urlInfoones = "http://192.168.0.118:8000/api/infoone"
            val urlClasscorridas = "http://192.168.0.118:8000/api/classcorridas"
            val urlApi = "http://192.168.0.118:8000/api/lercorridacard"
            /* val urlApilucro = "http://192.168.0.118:8000/api/monthly-earnings" */

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
                                                val valorPorKm = totalDistance / totalLucro

                                                // Defina o valor de corridaTipo aqui
                                                val corridaTipo: String = when {
                                                    valorKm <= corridaBronze -> "Corrida Bronze"
                                                    valorKm <= corridaOuro -> "Corrida Ouro"
                                                    else -> "Corrida Diamante"
                                                }

                                                // Chamando o método que exibe o card com o tipo de corrida e valor por km
                                                Handler(Looper.getMainLooper()).post {
                                                     Log.d("AccessibilityService", "Chamando showCustomCard com tipo: $corridaTipo e lucro: $totalLucro")
                                                    showCustomCard(corridaTipo, totalLucro)
                                                }

                                                // Montando o request body para enviar os dados à API
                                                val requestBody = FormBody.Builder()
                                                    .add("total_distance", totalDistance.toString())
                                                    .add("valor", decimalValue.toString())
                                                    .add("lucro", totalLucro.toString())
                                                    .add("total_custo", totalCusto.toString())
                                                    .add("valor_por_km", valorPorKm.toString())
                                                    .add("tipo_corrida", corridaTipo)  // Usando corridaTipo aqui
                                                    .build()

                                                val requestLerCorrida = Request.Builder()
                                                    .url(urlApi)
                                                    .addHeader("Authorization", "Bearer $token")
                                                    .post(requestBody)
                                                    .build()

                                                client.newCall(requestLerCorrida).enqueue(object : Callback {
                                                    override fun onFailure(call: Call, e: IOException) {
                                                        Log.e("API_ERROR", "Failed to send data: $e")
                                                    }

                                                    override fun onResponse(call: Call, response: Response) {
                                                        if (response.isSuccessful) {
                                                            Log.d("API_SUCCESS", "Data sent successfully")
                                                        } else {
                                                            Log.e("API_ERROR", "Failed to send data: ${response.message}")
                                                        }
                                                    }
                                                })

                                               /*  val requestBodyLucro = FormBody.Builder()
                                                    .add("total_lucro", totalLucro.toString())
                                                    .add("total_gasto", totalCusto.toString())
                                                    .add("valor_corrida", decimalValue.toString())
                                                    .build()

                                                val requestLucro = Request.Builder()
                                                    .url(urlApilucro)
                                                    .addHeader("Authorization", "Bearer $token")
                                                    .post(requestBodyLucro)
                                                    .build()


                                                    client.newCall(requestLucro).enqueue(object : Callback {
                                                    override fun onFailure(call: Call, e: IOException) {
                                                        Log.e("API_ERROR", "Failed to send data: $e")
                                                    }

                                                    override fun onResponse(call: Call, response: Response) {
                                                        if (response.isSuccessful) {
                                                            Log.d("API_SUCCESS", "Data sent successfully")
                                                        } else {
                                                            Log.e("API_ERROR", "Failed to send data: ${response.message}")
                                                        }
                                                    }
                                                }) */

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


//ENVIO DE DADOS CORRIDA
    private fun sendDataToApi(monetaryValue: String) {

    val decimalValue = monetaryValue.replace(".", "").replace(",", ".").toDoubleOrNull()

    if (decimalValue != null) {
        val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val token = sharedPreferences.getString("flutter.token", null)

        if (token != null) {
            val urlGastosMensais = "http://192.168.0.118:8000/api/expenses"
            val urlInfoones = "http://192.168.0.118:8000/api/infoone"
            val urlClasscorridas = "http://192.168.0.118:8000/api/classcorridas"
            val urlApi = "http://192.168.0.118:8000/api/lercorrida"
            val urlApilucro = "http://192.168.0.118:8000/api/monthly-earnings"

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
                                                val valorPorKm = totalDistance / totalLucro

                                                // Defina o valor de corridaTipo aqui
                                                val corridaTipo: String = when {
                                                    valorKm <= corridaBronze -> "Corrida Bronze"
                                                    valorKm <= corridaOuro -> "Corrida Ouro"
                                                    else -> "Corrida Diamante"
                                                }

                                                /* // Chamando o método que exibe o card com o tipo de corrida e valor por km
                                                Handler(Looper.getMainLooper()).post {
                                                    showCustomCard(corridaTipo, totalLucro)
                                                } */

                                                // Montando o request body para enviar os dados à API
                                                val requestBody = FormBody.Builder()
                                                    .add("total_distance", totalDistance.toString())
                                                    .add("valor", decimalValue.toString())
                                                    .add("lucro", totalLucro.toString())
                                                    .add("total_custo", totalCusto.toString())
                                                    .add("valor_por_km", valorPorKm.toString())
                                                    .add("tipo_corrida", corridaTipo)  // Usando corridaTipo aqui
                                                    .build()

                                                val requestLerCorrida = Request.Builder()
                                                    .url(urlApi)
                                                    .addHeader("Authorization", "Bearer $token")
                                                    .post(requestBody)
                                                    .build()

                                                client.newCall(requestLerCorrida).enqueue(object : Callback {
                                                    override fun onFailure(call: Call, e: IOException) {
                                                        Log.e("API_ERROR", "Failed to send data: $e")
                                                    }

                                                    override fun onResponse(call: Call, response: Response) {
                                                        if (response.isSuccessful) {
                                                            Log.d("API_SUCCESS", "Data sent successfully")
                                                        } else {
                                                            Log.e("API_ERROR", "Failed to send data: ${response.message}")
                                                        }
                                                    }
                                                })

                                                val requestBodyLucro = FormBody.Builder()
                                                    .add("total_lucro", totalLucro.toString())
                                                    .add("total_gasto", totalCusto.toString())
                                                    .add("valor_corrida", decimalValue.toString())
                                                    .build()

                                                val requestLucro = Request.Builder()
                                                    .url(urlApilucro)
                                                    .addHeader("Authorization", "Bearer $token")
                                                    .post(requestBodyLucro)
                                                    .build()


                                                    client.newCall(requestLucro).enqueue(object : Callback {
                                                    override fun onFailure(call: Call, e: IOException) {
                                                        Log.e("API_ERROR", "Failed to send data: $e")
                                                    }

                                                    override fun onResponse(call: Call, response: Response) {
                                                        if (response.isSuccessful) {
                                                            Log.d("API_SUCCESS", "Data sent successfully")
                                                        } else {
                                                            Log.e("API_ERROR", "Failed to send data: ${response.message}")
                                                        }
                                                    }
                                                })

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

   private fun showCustomCard(corridaTipo: String, totalLucro: Double) {
    try {
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val layoutParams = WindowManager.LayoutParams(
            850,
            350,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        layoutParams.gravity = Gravity.TOP
        layoutParams.x = 0
        layoutParams.y = 0

        val view = LayoutInflater.from(this).inflate(R.layout.custom_dialog, null)
        val textViewDistancia: TextView = view.findViewById(R.id.text_view_distancia)
        val textViewGanhoKM: TextView = view.findViewById(R.id.text_view_ganhoKM) 
        val imageViewCorrida = view.findViewById<ImageView>(R.id.image_view_corrida)

        

        // Definir o texto conforme os valores capturados
        imageViewCorrida
        textViewGanhoKM.text
        textViewDistancia.text = "Lucro da Corrida R$ ${"%.2f".format(totalLucro)}"
        
     val imageUrl =   when (corridaTipo) {
    "Corrida Bronze" -> R.drawable.bandeirabronze
    "Corrida Ouro" -> R.drawable.bandeiraouro
    else-> R.drawable.bandeiradiamante
}

    Glide.with(this) // ou 'context' dependendo do escopo
    .load(imageUrl) // URL ou caminho da imagem local
    .into(imageViewCorrida)

        val customGreen = ContextCompat.getColor(this, R.color.custom_green)
        textViewDistancia.setTextColor(customGreen)
       
       windowManager.addView(view, layoutParams)

        // Remover a notificação após 4 segundos
        Handler(Looper.getMainLooper()).postDelayed({
            windowManager.removeView(view)
        }, 5000)
    } catch (e: Exception) {
        Log.e("TAG", "Erro: ${e.message}")
    }
}

}