import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/gastos_model.dart';
import '../../services/user_service.dart';
import '../login/welcome.dart';
import 'infoone.dart';
import 'register.dart';



class GastosPage extends StatefulWidget {
   

  @override
  _GastosPageState createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  List<Gastos>  getgastos = [];
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _gastos = [];
  final _nameController = TextEditingController();
  final MoneyMaskedTextController  _amountController = MoneyMaskedTextController(
    leftSymbol: 'R\$',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  bool _isSubmitted = false;
  int? _expenseId;
  double totalExpense = 0.0;

  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  
  Future<void> _sendGastos() async {
    final url = Uri.parse(expensesURL);
    String token = await getToken(); // obtenha o token conforme necessário

    try {
      // Verifique se o registro já existe
      final checkResponse = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (checkResponse.statusCode == 200) {
        final List<dynamic> existingData = json.decode(checkResponse.body);
        if (existingData.isNotEmpty) {
          // Atualize o registro existente
          final updateUrl = Uri.parse('$expensesURL/${existingData[0]['id']}');
          final updateResponse = await http.put(
            updateUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'gastos': _gastos}),
          );
          if (updateResponse.statusCode == 200) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Infoone()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dados atualizados com sucesso')),
              );
            }
          } else {
            print('Falha ao atualizar Gastos: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha ao atualizar os gastos, tente novamente')),
              );
            }
          }
        } else {
          // Crie um novo registro
          final createResponse = await http.post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'gastos': _gastos}),
          );

          if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Infoone()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dados adicionados com sucesso')),
              );
            }
          } else {
            print('Falha ao adicionar Gastos: ${createResponse.statusCode}');
            print('Resposta do servidor: ${createResponse.body}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Para continuar, adicione os seus gastos')),
              );
            }
          }
        }
      } else {
        print('Falha ao verificar Gastos: ${checkResponse.statusCode}');
        print('Resposta do servidor: ${checkResponse.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao verificar dados: ${checkResponse.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer requisição')),
        );
      }
    }
  }

  void _addGasto() {
    final String name = _nameController.text;
    final double amount = _amountController.numberValue;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _gastos.add({
          'name': name,
          'amount': amount,
        });
        totalExpense += amount;
        _nameController.clear();
        _amountController.updateValue(0);
      });
    }
  }

  void _removeExpense(int index) {
    setState(() {
      totalExpense -= _gastos[index]['amount'];
      _gastos.removeAt(index);
    });
  }




 void getExpenses() async {
    ApiResponse response = await getExpensesDetail();
    if (response.error == null) {
      if (mounted) {
        setState(() {
          List<Gastos> getgastos = response.data as List<Gastos>;
          loading = false;

          if (getgastos.isNotEmpty) {
            Gastos firstItem = getgastos[0];
            _gastos = List<Map<String, dynamic>>.from(firstItem.gastos ?? []);
            totalExpense = firstItem.amount != null ? double.tryParse(firstItem.amount.toString()) ?? 0.0 : 0.0;
          } else {
            _gastos = [];
            totalExpense = 0.0;
          }
        });
      }
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
        }
      });
    } else {
      // Detalhe o erro
      String errorMessage = 'Erro ao obter despesas: ${response.error}';
      if (response.errorDetail != null) {
        errorMessage += '\nDetalhes do erro: ${response.errorDetail}';
      }

      // Log do erro detalhado (somente no console do desenvolvedor)
      print('Erro detalhado ao obter despesas: ${response.error}');
      if (response.errorDetail != null) {
        print('Detalhes do erro: ${response.errorDetail}');
      }
      if (response.statusCode != null) {
        print('Código de status HTTP: ${response.statusCode}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao obter despesas: ${response.error}'),
        ));
      }
    }
  }


@override
  void initState() {
    super.initState();
    getExpenses();
  }



  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF171f20),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                SizedBox(height: height * 0.1),

                RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 45,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              children: <TextSpan>[
                TextSpan(text: 'Precisamos\nconhecer'),
                TextSpan(
                  text: '\nseu negócio.',
                  style: TextStyle(color: Color(0xFF00ff75)),
                ),
                
              ],
            ),
            textAlign: TextAlign.left,
          ),

              SizedBox(height: height * 0.05,),
              Text(
                'Nos conte seus gastos mensais',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  color: Colors.white
                ),
              ),
              SizedBox(height: height * 0.02),
              
              Divider(
                color: Colors.white,
                thickness: 1,
              ),

              Text(
                'Gastos adicionados',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white
                )
              ),
              SizedBox(height: height * 0.02,),            
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _gastos.asMap().entries.map((entry) {
                  int index = entry.key;
                  var gasto = entry.value;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        backgroundColor: Color(0xFF004D1F),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                        label: Text(
                          '${gasto['name']} - ${currencyFormat.format(gasto['amount'])}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () => _removeExpense(index),
                      ),
                    ],
                  );
                }).toList(),
              ),

               SizedBox(height: height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total mensal',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white
                    )
                  ),
                  Text(
                    currencyFormat.format(totalExpense),
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00ff75)
                    )
                  ),
                ],
              ),         

              Divider(
                color: Colors.white,
                thickness: 1,
              ),

              SizedBox(height: height * 0.05,),
             Container(
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        
                        controller: _nameController,
                        style: GoogleFonts.inter(
                          fontSize: 14,  
                          textStyle: TextStyle(color:Colors.white)
                        ),
                        
                        decoration: const InputDecoration(
                          labelText: 'Digite o tipo',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            
                          ),
                         
                            
                             focusedBorder: OutlineInputBorder(         
                    borderSide: BorderSide(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                    ),
                      

                    enabledBorder: OutlineInputBorder(

                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 3
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                  ),
                        ),
                        inputFormatters: [
                      LengthLimitingTextInputFormatter(15), // Limitar a 10 caracteres
                    ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(

                        controller: _amountController,
                         keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(
                          fontSize: 14,  
                          textStyle: TextStyle(color:Colors.white)
                        ),
                        
                        decoration: const InputDecoration(
                          labelText: 'Digite o valor',
                          labelStyle: TextStyle(

                            color: Colors.white,
                            
                          ),
                         
                        focusedBorder: OutlineInputBorder(         
                    borderSide: BorderSide(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                    ),
                    enabledBorder: OutlineInputBorder(

                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 3
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(13.0)),
                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          SizedBox(height: height * 0.05,),         
               
               

              Container(
                child: Center(
                  child: Column(
                    children: [
                         ElevatedButton(
                  onPressed: _addGasto,
                  child: Text(
                  'Adicionar aos meus gastos',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                  ),
                  ),
                   style: ElevatedButton.styleFrom(
                 
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Color(0xFF004D1F),
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                ),
                ),
                SizedBox(height: height * 0.05,),

              kTextButton('Próximo', () async {
                    if (_formKey.currentState!.validate()) {
                      _sendGastos();
                    }
                  },
                      EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.30
                      ),
                      height * 0.025,
                      
                    ),
                    SizedBox(height: height * 0.02),


              kButtonAnterior('Anterior', (){
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Register()), (route) => false);

                },  EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.30
                      ),
                      height * 0.025,
                      ),
                    ],
                  ),
                  
                ),
              ),

             
                  SizedBox(height: height * 0.05),
             
             
              ],
            ),
          ),
        ),
      ),
    );
  }
}