import 'user.dart';

class Gastos{
  int? id;
  String ? amount;
  List<dynamic>? gastos;
  User? user;

  Gastos({
    this.id,
    this.amount,
    this.gastos,
    this.user
  });



  factory Gastos.fromJson(Map<String, dynamic> json){
    return Gastos(
      id: json['id'],
      amount: json['amount'],
      gastos: json['gastos'],
    );
  }
}