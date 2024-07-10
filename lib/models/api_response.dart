class ApiResponse {
  dynamic data;
  String? error;
  String? errorDetail; // Novo campo para detalhes do erro
  int? statusCode; // Novo campo para o status da resposta HTTP

  ApiResponse({this.data, this.error, this.errorDetail, this.statusCode});
}
