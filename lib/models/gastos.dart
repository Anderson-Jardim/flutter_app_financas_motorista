import 'user.dart';

class Gastos{
  int? id;
  String? expense;
  int? totalExpense; 
  User? user;

  Gastos({
    this.id,
    this.expense,
    this.totalExpense,
    this.user
  });



  factory Gastos.fromJson(Map<String, dynamic> json){
    return Gastos(
      id: json['id'],
      expense: json['expense'],
      totalExpense: json['totalExpense'],
      user: User(
        id: json['user']['id']
      )
    );
  }
}