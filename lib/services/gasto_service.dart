/* import 'dart:convert';

import 'package:app_fingo/constant.dart';
import 'package:app_fingo/models/api_response.dart';
import 'package:app_fingo/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<ApiResponse> updateDataToAPI(int userId, List<Map<String, dynamic>> expenses, double totalExpense) async {
  ApiResponse apiResponse = ApiResponse();
    try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse('$userURL/$userId/$gastosURL'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'user_id': userId,
        'expenses': expenses,
        'totalExpense': totalExpense,
      }),
    );

    if (response.statusCode == 200) {
      apiResponse.data = jsonDecode(response.body);
    } else {
      apiResponse.error = 'Erro ao atualizar os dados';
    }
  } catch (e) {
    apiResponse.error = 'Erro: $e';
  }

  return apiResponse;
  } */