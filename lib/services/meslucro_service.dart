//get meslucro
import 'dart:convert';


import 'package:app_fingo/services/user_service.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';
import '../models/api_response.dart';
import '../models/meslucro_model.dart';

Future<ApiResponse> getMeslucroDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse(meslucrosURL),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

   if (response.statusCode == 200) {
      // Decodificar a resposta JSON para uma lista dinâmica
      List<dynamic> data = jsonDecode(response.body);

      // Mapear cada item da lista para um InfooneModel e converter para uma lista tipada
      List<meslucroModel> meslucromodel = data.map((item) => meslucroModel.fromJson(item)).toList();

      // Definir os dados da resposta como a lista de InfooneModel
      apiResponse.data = meslucromodel;
    } else {
      // Em caso de falha, definir o erro na resposta
      apiResponse.error = 'Falha ao carregar dados';
    }
  } catch (e) {
    // Em caso de exceção, definir o erro na resposta
    apiResponse.error = 'Erro no servidor. Tente novamente mais tarde.';
  }
  return apiResponse;
}