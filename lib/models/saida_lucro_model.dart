class saidaLucroModel {
   int ? id;
   String ? nome_saida;
   String ? saida_lucro;
   String ? tipo;
   String ? createdAt;
  
  saidaLucroModel({
     this.id,
     this.nome_saida,
     this.saida_lucro,
     this.tipo,
     this.createdAt,
  });

  factory saidaLucroModel.fromJson(Map<String, dynamic> json) {
    return saidaLucroModel(
      id: json['id'],
      nome_saida: json['nome_saida'],
      saida_lucro: json['saida_lucro'],
      tipo: json['tipo'],
      createdAt: json['created_at'],
    );
  }
}