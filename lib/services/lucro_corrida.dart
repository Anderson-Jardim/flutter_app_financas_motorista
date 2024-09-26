//get meslucro
import 'dart:convert';


import 'package:app_fingo/services/user_service.dart';
import 'package:http/http.dart' as http;
import '../constant.dart';
import '../models/api_response.dart';
import '../models/lucro_corrida_model.dart';

Future<ApiResponse> getlucroCorridaDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse(lucroCorridaURL),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

   if (response.statusCode == 200) {
      // Decodificar a resposta JSON para uma lista dinâmica
      List<dynamic> data = jsonDecode(response.body);

      // Mapear cada item da lista para um InfooneModel e converter para uma lista tipada
      List<lucroCorridaModel> lucroCorridamodel = data.map((item) => lucroCorridaModel.fromJson(item)).toList();

      // Definir os dados da resposta como a lista de InfooneModel
      apiResponse.data = lucroCorridamodel;
    } else {
      // Em caso de falha, definir o erro na resposta
      apiResponse.error = 'Falha ao carregar dados';
    }
  } catch (e, stacktrace) {
    // Em caso de exceção, definir o erro na resposta
    apiResponse.error = 'Erro no servidor. Tente novamente mais tarde.';
    print('Exceção capturada: $e'); // Log da exceção
    print('Stacktrace: $stacktrace'); // Log do stacktrace para depuração
  }
  return apiResponse;
}