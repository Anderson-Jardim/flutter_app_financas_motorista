class lucroCorridaModel {
   int ? id;
   String ? total_distance;
   String ? valor;
   String ? lucro;
   String ? valor_por_km;
   String ? tipo_corrida;
  
  lucroCorridaModel({
     this.id,
     this.total_distance,
     this.valor,
     this.lucro,
     this.valor_por_km,
     this.tipo_corrida,
  });

  factory lucroCorridaModel.fromJson(Map<String, dynamic> json) {
    return lucroCorridaModel(
      id: json['id'],
      total_distance: json['total_distance'],
      valor: json['valor'],
      lucro: json['lucro'],
      valor_por_km: json['valor_por_km'],
      tipo_corrida: json['tipo_corrida'],
    );
  }
}