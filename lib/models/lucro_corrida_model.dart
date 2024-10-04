class lucroCorridaModel {
   int ? id;
   String ? total_lucro;
   String ? total_gasto;
   String ? valor_corrida;
   
  
  lucroCorridaModel({
     this.id,
     this.total_lucro,
     this.total_gasto,
     this.valor_corrida,
     
  });

  factory lucroCorridaModel.fromJson(Map<String, dynamic> json) {
    return lucroCorridaModel(
      id: json['id'],
      total_lucro: json['total_lucro'],
      total_gasto: json['total_gasto'],
      valor_corrida: json['valor_corrida'],
      
    );
  }
}