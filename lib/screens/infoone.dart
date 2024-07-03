import 'dart:convert';
import 'package:app_fingo/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../services/user_service.dart';
import 'gastos.dart';
import 'meslucros.dart';

class Infoone extends StatefulWidget {
  @override
  _InfooneState createState() => _InfooneState();
}

class _InfooneState extends State<Infoone> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final MoneyMaskedTextController _valorGasolinaController = MoneyMaskedTextController(
    leftSymbol: 'R\$',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  TextEditingController diasTrabController = TextEditingController();
  TextEditingController qtdCorridasController = TextEditingController();
  TextEditingController kmLitroController = TextEditingController();

  Future<void> _submitInfoone() async {
    final url = Uri.parse(InfooneURL); // Substitua com o seu URL de API Laravel
    String token = await getToken();
    
    // Dados para enviar
    final Map<String, dynamic> data = {
      'valor_gasolina': _valorGasolinaController.numberValue,
      'dias_trab': int.parse(diasTrabController.text),
      'qtd_corridas': int.parse(qtdCorridasController.text),
      'km_litro': double.parse(kmLitroController.text),
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
          final updateUrl = Uri.parse('$InfooneURL/${existingData[0]['id']}');
          final updateResponse = await http.put(
            updateUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          );

          if (updateResponse.statusCode == 200) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>MesLucros()), (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Infoone atualizado com sucesso')),
            );
          } else {
            print('Falha ao atualizar infoone: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao atualizar infoone: ${updateResponse.statusCode}')),
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
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>MesLucros()), (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Infoone adicionado com sucesso')),
            );
          } else {
            print('Falha ao adicionar infoone: ${createResponse.statusCode}');
            print('Resposta do servidor: ${createResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao adicionar infoone: ${createResponse.statusCode}')),
            );
          }
        }
      } else {
        print('Falha ao verificar infoone: ${checkResponse.statusCode}');
        print('Resposta do servidor: ${checkResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao verificar infoone: ${checkResponse.statusCode}')),
        );
      }
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição')),
      );
    }
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
                SizedBox(height: height * 0.1),
                Container(
                  width: width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(                   
                        'Quase lá.',
                        style: GoogleFonts.poppins(
                          fontSize: 50,
                          height: 1,
                          fontWeight: FontWeight.w800
                        ),
                      ),

                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.03),

              Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(                   
                          'Qual o preço da gasolina no seu posto?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w400
                          ),
                          textAlign: TextAlign.left,

                        ),
                    ),
                     SizedBox(height: height * 0.02),

                     TextFormField(
                      
                  controller: _valorGasolinaController,
                  keyboardType: TextInputType.number,
                   textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600
                  ),
                  decoration: const InputDecoration(
                    
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
                  
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),

                SizedBox(height: height * 0.04),



            Container(
                      alignment: Alignment.center,
                      child: Text(                   
                          'Quantos dias por mês você trabalha? ',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w400
                          ),
                          textAlign: TextAlign.center,

                        ),
                    ),
                     SizedBox(height: height * 0.02),

              TextFormField(
                      
                  controller: diasTrabController,
                  keyboardType: TextInputType.number,
                   textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600
                  ),
                  decoration: const InputDecoration(
                    
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
                  
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
     SizedBox(height: height * 0.04),

            Container(
                      alignment: Alignment.center,
                      child: Text(                   
                        'Quantas corridas você faz por dia? ',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w400
                          ),
                          textAlign: TextAlign.center,

                        ),
                    ),
                     SizedBox(height: height * 0.02),

              TextFormField(
                      
                  controller: qtdCorridasController,
                  keyboardType: TextInputType.number,
                   textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600
                  ),
                  decoration: const InputDecoration(
                    
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
                  
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
     SizedBox(height: height * 0.04),

            Container(
                      alignment: Alignment.center,
                      child: Text(                   
                        'Quantos Km seu carro faz com um litro\nde gasolina? ',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.w400
                          ),
                          textAlign: TextAlign.center,

                        ),
                    ),
                     SizedBox(height: height * 0.02),

              TextFormField(
                      
                  controller: kmLitroController,
                  keyboardType: TextInputType.number,
                   textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600
                  ),
                  decoration: const InputDecoration(
                    
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
                  
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
              ],
             ),              
           ),        
              SizedBox(height: height * 0.07),

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
                    _submitInfoone();
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
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>GastosPage()), (route) => false);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
