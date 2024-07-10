class meslucroModel {
   int ? id;
   String ? qtd_mes_lucros;
  
  meslucroModel({
     this.id,
     this.qtd_mes_lucros,
  });

  factory meslucroModel.fromJson(Map<String, dynamic> json) {
    return meslucroModel(
      id: json['id'],
      qtd_mes_lucros: json['qtd_mes_lucros'],
    );
  }
}