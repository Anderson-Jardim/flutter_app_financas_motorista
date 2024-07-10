import 'dart:convert';
import 'package:app_fingo/screens/register/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/meslucro_model.dart';
import '../../services/meslucro_service.dart';
import '../../services/user_service.dart';
import '../welcome.dart';


class MesLucros extends StatefulWidget {
  @override
  _MesLucrosState createState() => _MesLucrosState();
}

class _MesLucrosState extends State<MesLucros> {

  List<meslucroModel> meslucromodel = [];
  bool loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final MoneyMaskedTextController _meslucrosController = MoneyMaskedTextController(
    leftSymbol: 'R\$',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  

 

  Future<void> _submitMesLucro() async {
    final url = Uri.parse(meslucrosURL); // Substitua com o seu URL de API Laravel
    String token = await getToken();
    
    // Dados para enviar
    final Map<String, dynamic> data = {
      'qtd_mes_lucros': _meslucrosController.numberValue,
      
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
          final updateUrl = Uri.parse('$meslucrosURL/${existingData[0]['id']}');
          final updateResponse = await http.put(
            updateUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          );

          if (updateResponse.statusCode == 200) {
          //  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Classcorridas()), (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mês Lucro atualizado com sucesso')),
            );
          } else {
            print('Falha ao atualizar Mês Lucro: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao atualizar Mês Lucro: ${updateResponse.statusCode}')),
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
           // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Classcorridas()), (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mes Lucros adicionado com sucesso')),
            );
          } else {
            print('Falha ao adicionar Mes Lucros: ${createResponse.statusCode}');
            print('Resposta do servidor: ${createResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao adicionar Mes Lucros: ${createResponse.statusCode}')),
            );
          }
        }
      } else {
        print('Falha ao verificar Mes Lucros: ${checkResponse.statusCode}');
        print('Resposta do servidor: ${checkResponse.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao verificar Mes Lucros: ${checkResponse.statusCode}')),
        );
      }
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição')),
      );
    }
  }

  void getMesLucro() async {
    ApiResponse response = await getMeslucroDetail();
    if(response.error == null) {
      setState(() {
        List<meslucroModel> meslucromodel = response.data as List<meslucroModel>;
        loading = false;

        if(meslucromodel.isNotEmpty){
          meslucroModel firstItem = meslucromodel[0];
        _meslucrosController.text = 'R\$${firstItem.qtd_mes_lucros ?? ''}';
        }
      });
    }
    /* else if(response.error == unauthorized){
      logout().then((value) => {
        //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomeScreen()), (route) => false)
      });
    } */
    else if (response.error == unauthorized) {
    logout().then((value) => {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false)
    });
  } else {
    // Detalhe o erro
    String errorMessage = 'Erro ao obter meslucro: ${response.error}';
    if (response.errorDetail != null) {
      errorMessage += '\nDetalhes do erro: ${response.errorDetail}';
    }

    // Log do erro detalhado (somente no console do desenvolvedor)
    print('Erro detalhado ao obter meslucro: ${response.error}');
    if (response.errorDetail != null) {
      print('Detalhes do erro: ${response.errorDetail}');
    }
    if (response.statusCode != null) {
      print('Código de status HTTP: ${response.statusCode}');
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Erro ao obter meslucro: ${response.error}'),
    ));
  }
  }

 @override
  void initState() {
    getMesLucro();
    super.initState();
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(                   
                        'Vamos\nfalar do\nfuturo?',
                        style: GoogleFonts.poppins(
                          fontSize: 60,
                          height: 1,
                          fontWeight: FontWeight.w800
                        ),
                        textAlign: TextAlign.left,
                      ),

                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.06),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [

                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(                   
                          'Quanto quer lucrar no mês?',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            height: 1,
                            fontWeight: FontWeight.w400
                          ),
                          textAlign: TextAlign.left,

                        ),
                    ),

                      SizedBox(height: height * 0.02),


                      TextFormField(
                      
                  controller: _meslucrosController,
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
                    _submitMesLucro();
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

                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
