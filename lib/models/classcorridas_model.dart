class classCorridasModel {
   int ? id;
   int ? corrida_bronze;
   int ? corrida_ouro;
   int ? corrida_diamante;
  
  classCorridasModel({
     this.id,
     this.corrida_bronze,
     this.corrida_ouro,
     this.corrida_diamante,
  });

  factory classCorridasModel.fromJson(Map<String, dynamic> json) {
    return classCorridasModel(
      id: json['id'],
      corrida_bronze: json['corrida_bronze'],
      corrida_ouro: json['corrida_ouro'],
      corrida_diamante: json['corrida_diamante'],
    );
  }
}