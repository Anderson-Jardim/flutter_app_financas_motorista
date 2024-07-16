import 'package:app_fingo/models/user.dart';


class InfooneModel {
   int ? id;
   String ? valorGasolina;
   int? diasTrab;
   int? qtdCorridas;
   User? user;
   String? kmLitro;

  InfooneModel({
     this.id,
     this.valorGasolina,
     this.diasTrab,
     this.qtdCorridas,
     this.user,
     this.kmLitro,
  });

  factory InfooneModel.fromJson(Map<String, dynamic> json) {
    return InfooneModel(
      id: json['id'],
      valorGasolina: json['valor_gasolina'],
      diasTrab: json['dias_trab'],
      qtdCorridas: json['qtd_corridas'],
      kmLitro: json['km_litro'],
      /* user: User(
        id: json['user']['id'],
      ) */
    );
  }

 /*  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'valor_gasolina': valorGasolina,
      'dias_trab': diasTrab,
      'qtd_corridas': qtdCorridas,
      'km_litro': kmLitro,
    };
  } */
}
