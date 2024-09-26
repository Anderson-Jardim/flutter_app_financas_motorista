class lucroCorridaModel {
   int ? id;
   String ? total_lucro;
   
  
  lucroCorridaModel({
     this.id,
     this.total_lucro,
     
  });

  factory lucroCorridaModel.fromJson(Map<String, dynamic> json) {
    return lucroCorridaModel(
      id: json['id'],
      total_lucro: json['total_lucro'],
      
    );
  }
}