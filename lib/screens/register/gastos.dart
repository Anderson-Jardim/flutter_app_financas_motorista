import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/gastos_model.dart';
import '../../services/user_service.dart';
import '../welcome.dart';
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

  try{
    // Verifique se o registro já existe
      final checkResponse = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

    if(checkResponse.statusCode == 200){
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
          // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>MesLucros()), (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gastos atualizado com sucesso')),
            );
          } else {
            print('Falha ao atualizar Gastos: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao atualizar Gastos: ${updateResponse.statusCode}')),
            );
          }
      }else {
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
           // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>MesLucros()), (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gastos adicionado com sucesso')),
            );
          } else {
            print('Falha ao adicionar Gastos: ${createResponse.statusCode}');
            print('Resposta do servidor: ${createResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao adicionar Gastos: ${createResponse.statusCode}')),
            );
          }
        }
    }else {
        print('Falha ao verificar Gastos: ${checkResponse.statusCode}');
        print('Resposta do servidor: ${checkResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao verificar Gastos: ${checkResponse.statusCode}')),
        );
      }

  } catch (e){
    print('Erro ao fazer requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição')),
      );
  }



  /*   final response = _isSubmitted
        ? await http.put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'gastos': _gastos}),
          )
        : await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'gastos': _gastos}),
          );

    if (response.statusCode == 201 || response.statusCode == 200) {
      //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Infoone()), (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gastos enviados com sucesso!')));
      if (!_isSubmitted) {
        final responseData = json.decode(response.body);
        print('Response data: $responseData'); // Adicionar print de depuração
        setState(() {
          _isSubmitted = true;
          _expenseId = responseData['id'];
        });
      }
    } else {
      print('Erro ao enviar gastos: ${response.statusCode}'); // Adicionar print de depuração
      print('Response body: ${response.body}'); // Adicionar print de depuração
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar gastos.')));
    } */
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
    setState(() {
      List<Gastos> getgastos = response.data as List<Gastos>;
      loading = false;

      if(getgastos.isNotEmpty){
        Gastos firstItem = getgastos[0];
       _gastos = List<Map<String, dynamic>>.from(firstItem.gastos ?? []); 
         totalExpense = firstItem.amount != null ? double.tryParse(firstItem.amount.toString()) ?? 0.0 : 0.0;
      }else {
        _gastos = [];
        totalExpense = 0.0;
      }

    });
  } else if (response.error == unauthorized) {
    logout().then((value) => {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false)
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

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Erro ao obter despesas: ${response.error}'),
    ));
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
      
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                SizedBox(height: height * 0.1),

                Text(                   
                          'Precisamos\nconhecer\nseu negócio.',
                          style: GoogleFonts.poppins(
                            fontSize: 45,
                            height: 1,
                            fontWeight: FontWeight.w800
                          ),
                          textAlign: TextAlign.left,
                        ),
              SizedBox(height: height * 0.05,),
              Text(
                'Nos conte seus gastos mensais',
                style: GoogleFonts.inter(
                  fontSize: 19,
                ),
              ),
              SizedBox(height: height * 0.03),
              
              Divider(
                color: Colors.grey,
                thickness: 1,
              ),

              Text(
                'Gastos adicionados',
                style: GoogleFonts.inter(
                  fontSize: 11,
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
                        backgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                        label: Text(
                          '${gasto['name']} - ${currencyFormat.format(gasto['amount'])}',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        color: Colors.black,
                        
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
                    )
                  ),
                  Text(
                    currencyFormat.format(totalExpense),
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w500
                    )
                  ),
                ],
              ),         

              Divider(
                color: Colors.grey,
                thickness: 1,
              ),

              SizedBox(height: height * 0.05,),
             Container(
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        
                        controller: _nameController,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          
                        ),

                        decoration: const InputDecoration(
                          
                          labelText: 'Digite o tipo',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            
                          ),
                         
                            
                           focusedBorder: OutlineInputBorder(
                       
                      borderSide: BorderSide(color: Colors.black87, width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(13.0)),
                      ),
                      

                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
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
                          
                        ),

                        decoration: const InputDecoration(
                          labelText: 'Digite o valor',
                          labelStyle: TextStyle(
                            color: Colors.black,
                            
                          ),
                         
                            
                           focusedBorder: OutlineInputBorder(
                       
                      borderSide: BorderSide(color: Colors.black87, width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(13.0)),
                      ),
                      

                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
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
               /*  TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nome do Gasto'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do gasto';
                    }
                    return null;
                  },
                ), */
                /* TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Valor do Gasto'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o valor do gasto';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, insira um valor válido';
                    }
                    return null;
                  },
                ), */
                ElevatedButton(
                  onPressed: _addGasto,
                  child: Text(
                  'Adicionar aos meus gastos',
                  style: GoogleFonts.poppins(
                    fontSize: 18
                  ),
                  ),
                   style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                ),
                ),
                SizedBox(height: height * 0.05,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                    onPressed: () {
                       Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Register()), (route) => false);
                    },
                    child: Text(
                      'Anterior',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        
                      ),
                      ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: Size(170, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _sendGastos, 
                  
                   child: Text(
                      'Próximo',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        
                      ),
                      ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(170, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                   ),
                  ),
                 ),    
                ],
               ),
               /*  SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _gastos.length,
                    itemBuilder: (context, index) {
                      final gasto = _gastos[index];
                      return ListTile(
                        title: Text(gasto['name']),
                        subtitle: Text(
                            'R\$ ${gasto['amount'].toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ), */
                SizedBox(height: height * 0.05),
                 ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.30
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(121),
                      ),
                  ),
                   onPressed: (){
              logout().then((value) => {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false)
              });
            },
                  child: Text(
                    'Sair',
                    style:  GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: height * 0.025,
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