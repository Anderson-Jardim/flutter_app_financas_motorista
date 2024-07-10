


import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../models/api_response.dart';
import '../models/gastos_model.dart';
import '../models/infoone_model.dart';
import '../models/user.dart';

// login
Future<ApiResponse> login (String contact, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try{
    final response = await http.post(
      Uri.parse(loginURL),
      headers: {'Accept': 'application/json'},
      body: {'contact': contact, 'password': password}
    );

    switch(response.statusCode){
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  }
  catch(e){
    apiResponse.error = serverError;
  }

  return apiResponse;
}


// Register
Future<ApiResponse> register(String name, String username, String contact, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse(registerURL),
      headers: {'Accept': 'application/json'}, 
      body: {
        'name': name,
        'username': username,
        'contact': contact,
        'password': password,
        'password_confirmation': password
      });

    switch(response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  }
  catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}


// Get User
Future<ApiResponse> getUserDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse(userURL),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

    switch(response.statusCode){
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } 
  catch(e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Get Expenses
Future<ApiResponse> getExpensesDetail() async {
  ApiResponse apiResponse = ApiResponse();
  String token = await getToken();
  try {
    final response = await http.get(
      Uri.parse(expensesURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Decodificar a resposta JSON para uma lista dinâmica
      List<dynamic> data = jsonDecode(response.body);

      // Mapear cada item da lista para um InfooneModel e converter para uma lista tipada
      List<Gastos> gastosList = data.map((item) => Gastos.fromJson(item)).toList();

      // Definir os dados da resposta como a lista de InfooneModel
      apiResponse.data = gastosList;
    } else {
      // Em caso de falha, definir o erro na resposta
      apiResponse.error = 'Falha ao carregar dados';
    }
  } catch (e) {
    apiResponse.error = 'Erro no servidor. Tente novamente mais tarde.';
    apiResponse.errorDetail = e.toString(); // Captura a exceção
  }
  return apiResponse;
}


// Get Infoone
Future<ApiResponse> getInfooneDetail() async {
  ApiResponse apiResponse = ApiResponse();
  String token = await getToken();
  try {
    final response = await http.get(
      Uri.parse(InfooneURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Decodificar a resposta JSON para uma lista dinâmica
      List<dynamic> data = jsonDecode(response.body);

      // Mapear cada item da lista para um InfooneModel e converter para uma lista tipada
      List<InfooneModel> infooneList = data.map((item) => InfooneModel.fromJson(item)).toList();

      // Definir os dados da resposta como a lista de InfooneModel
      apiResponse.data = infooneList;
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





// Update user
Future<ApiResponse> updateUser(String name, String username, String contact, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse(userURL),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }, 
       body: {
        'name': name,
        'username': username,
        'contact': contact,
        'password': password,
        'password_confirmation': password
      });
      // user can update his/her name or name and image

    switch(response.statusCode) {
      case 200:
        apiResponse.data =jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        print(response.body);
        apiResponse.error = somethingWentWrong;
        break;
    }
  }
  catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// get token
Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

// get user id
Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId') ?? 0;
}

// logout
Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');
}

// Get base64 encoded image
String? getStringImage(File? file) {
  if (file == null) return null ;
  return base64Encode(file.readAsBytesSync());
}