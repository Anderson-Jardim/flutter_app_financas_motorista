  class valorKM_Model{
   int ? id;
   String ? ruim;
   String ? bom;
  
  valorKM_Model({
     this.id,
     this.ruim,
     this.bom,
  });

  factory valorKM_Model.fromJson(Map<String, dynamic> json) {
    return valorKM_Model(
      id: json['id'],
      ruim: json['ruim'],
      bom: json['bom'],
    );
  }
}