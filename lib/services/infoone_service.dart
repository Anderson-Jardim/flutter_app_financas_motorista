import 'dart:convert';
import 'dart:ffi';

import 'package:app_fingo/constant.dart';

import '../models/api_response.dart';
import 'package:http/http.dart' as http;

Future<ApiResponse> registerInfoone(Double valor_gasolina, String dias_trab, String qtd_corridas, String km_litro) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse(InfooneURL),
      headers: {'Accept': 'application/json'}, 
      body: {
        'valor_gasolina': valor_gasolina,
        'dias_trab': dias_trab,
        'qtd_corridas': qtd_corridas,
        'km_litro': km_litro,
        
      });

    if (response.statusCode == 200) {
      apiResponse.data = jsonDecode(response.body);
    } else {
      apiResponse.error = 'Erro ao atualizar os dados';
    }
  } catch (e) {
    apiResponse.error = 'Erro: $e';
  }

  return apiResponse;
}