import 'dart:convert';

import 'package:app_fingo/screens/register/register.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;


import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/classcorridas_model.dart';
import '../../services/classcorridas_service.dart';
import '../../services/user_service.dart';
import '../welcome.dart';
import 'meslucros.dart';

class Classcorridas extends StatefulWidget {
  @override
  _ClasscorridasState createState() => _ClasscorridasState();
}

class _ClasscorridasState extends State<Classcorridas> {
  
  List<classCorridasModel> classcorridasmodel = [];
  bool loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController corridaBronzeController = TextEditingController();
  TextEditingController corridaOuroController = TextEditingController();
  TextEditingController corridaDiamanteController = TextEditingController();

  

  Future<void> _submitClasscorridas() async {
    final url = Uri.parse(classcorridasURL); // Substitua com o seu URL de API Laravel
    String token = await getToken();
    
    // Dados para enviar
    final Map<String, dynamic> data = {
      'corrida_bronze': int.parse(corridaBronzeController.text),
      'corrida_ouro': int.parse(corridaOuroController.text),
      'corrida_diamante': int.parse(corridaDiamanteController.text),
    };

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
          final updateUrl = Uri.parse('$classcorridasURL/${existingData[0]['id']}');
          final updateResponse = await http.put(
            updateUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          );

          if (updateResponse.statusCode == 200) {
          // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> FinalCad()), (route) => false); 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('classcorridas atualizado com sucesso')),
            );
          } else {
            print('Falha ao atualizar classcorridas: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao atualizar classcorridas: ${updateResponse.statusCode}')),
            );
          }
        } else {
          // Crie um novo registro
          final createResponse = await http.post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          );

          if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
         //   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> FinalCad()), (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('classcorridas adicionado com sucesso')),
            );
          } else {
            print('Falha ao adicionar classcorridas: ${createResponse.statusCode}');
            print('Resposta do servidor: ${createResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao adicionar classcorridas: ${createResponse.statusCode}')),
            );
          }
        }
      } else {
        print('Falha ao verificar classcorridas: ${checkResponse.statusCode}');
        print('Resposta do servidor: ${checkResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao verificar classcorridas: ${checkResponse.statusCode}')),
        );
      }
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição')),
      );
    }
  }


   void getClassCorridas() async {
    ApiResponse response = await getclassCorridasDetail();
    if(response.error == null) {
      setState(() {
        List<classCorridasModel> classcorridasmodel = response.data as List<classCorridasModel>;
        loading = false;

        if(classcorridasmodel.isNotEmpty){
          classCorridasModel firstItem = classcorridasmodel[0];
        corridaBronzeController.text = '${firstItem.corrida_bronze ?? ''}';
        corridaOuroController.text = '${firstItem.corrida_ouro ?? ''}';
        corridaDiamanteController.text = '${firstItem.corrida_diamante ?? ''}';
        }
      });
    }
    else if (response.error == unauthorized) {
    logout().then((value) => {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false)
    });
  } else {
    // Detalhe o erro
    String errorMessage = 'Erro ao obter ClassCorridas: ${response.error}';
    if (response.errorDetail != null) {
      errorMessage += '\nDetalhes do erro: ${response.errorDetail}';
    }

    // Log do erro detalhado (somente no console do desenvolvedor)
    print('Erro detalhado ao obter ClassCorridas: ${response.error}');
    if (response.errorDetail != null) {
      print('Detalhes do erro: ${response.errorDetail}');
    }
    if (response.statusCode != null) {
      print('Código de status HTTP: ${response.statusCode}');
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Erro ao obter ClassCorridas: ${response.error}'),
    ));
  }
  }


@override
  void initState() {
    super.initState();
    getClassCorridas();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.05),
                Container(
                  width: width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(                   
                        'Classifique\nsuas corridas',
                        style: GoogleFonts.poppins(
                          fontSize: 45,
                          height: 1,
                          fontWeight: FontWeight.w800
                        ),
                        textAlign: TextAlign.left,
                      ),

                      SizedBox(height: height * 0.03),


                      Text(                   
                        'Digite quanto quer lucrar\nem cada tipo de chamada',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w400
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: height * 0.03),


                      Text(                   
                        '(Exemplo: 10% de lucro na corrida bronze)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.06),


                Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Column(
                    children: [
                    TextFormField(
                  controller: corridaBronzeController,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Corridas bronze devem lucrar',
                    suffixText:"%" ,
                    suffixStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w900),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                      
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: height * 0.04),

                    TextFormField(
                  controller: corridaOuroController,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Corridas ouro devem lucrar',
                    suffixText:"%" ,
                    suffixStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w900),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                      
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),

                SizedBox(height: height * 0.04),
                    TextFormField(
                  controller: corridaDiamanteController,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Corridas diamante devem lucrar',
                    suffixText:"%" ,
                    suffixStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w900),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                      
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.04),
               ],
            ),
         ),

                SizedBox(height: height * 0.05),
             


             ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.02,
                      horizontal: width * 0.30
                      ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(121),
                      ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      
                    _submitClasscorridas();
              
                    }

                  },
                  child: Text(
                    'Próximo',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: height * 0.025,
                        
                        ),
                  ),
                ),
             
                SizedBox(height: height * 0.02),

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
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Register()), (route) => false);
                  },
                  child: Text(
                    'Anterior',
                    style:  GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: height * 0.025,
                        ),
                  ),
                ),
                SizedBox(height: height * 0.05),

                /* ElevatedButton(
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
                SizedBox(height: height * 0.05), */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
