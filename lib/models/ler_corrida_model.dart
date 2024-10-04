class LerCorridaModel {
   int ? id;
   String ? total_distance;
   String ? valor;
   String ? lucro;
   String ? total_custo;
   String ? valor_por_km;
   String ? tipo_corrida;
   String ? createdAt;
   
  
  LerCorridaModel({
     this.id,
     this.total_distance,
     this.valor,
     this.lucro,
     this.total_custo,
     this.valor_por_km,
     this.tipo_corrida,
     this.createdAt,
     
  });

  factory LerCorridaModel.fromJson(Map<String, dynamic> json) {
    return LerCorridaModel(
      id: json['id'],
      total_distance: json['total_distance'],
      valor: json['valor'],
      lucro: json['lucro'],
      total_custo: json['total_custo'],
      valor_por_km: json['valor_por_km'],
      tipo_corrida: json['tipo_corrida'],
      createdAt: json['created_at'],
      
    );
  }
}