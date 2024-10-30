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
import 'finalcad.dart';
import '../login/welcome.dart';
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
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => FinalCad()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dados atualizados com sucesso')),
              );
            }
          } else {
            print('Falha ao atualizar classcorridas: ${updateResponse.statusCode}');
            print('Resposta do servidor: ${updateResponse.body}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha ao atualizar dados: ${updateResponse.statusCode}')),
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
            body: jsonEncode(data),
          );

          if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => FinalCad()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dados adicionados com sucesso')),
              );
            }
          } else {
            print('Falha ao adicionar classcorridas: ${createResponse.statusCode}');
            print('Resposta do servidor: ${createResponse.body}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha ao adicionar dados: ${createResponse.statusCode}')),
              );
            }
          }
        }
      } else {
        print('Falha ao verificar classcorridas: ${checkResponse.statusCode}');
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

  void getClassCorridas() async {
    ApiResponse response = await getclassCorridasDetail();
    if (response.error == null) {
      if (mounted) {
        setState(() {
          List<classCorridasModel> classcorridasmodel = response.data as List<classCorridasModel>;
          loading = false;

          if (classcorridasmodel.isNotEmpty) {
            classCorridasModel firstItem = classcorridasmodel[0];
            corridaBronzeController.text = '${firstItem.corrida_bronze ?? ''}';
            corridaOuroController.text = '${firstItem.corrida_ouro ?? ''}';
            corridaDiamanteController.text = '${firstItem.corrida_diamante ?? ''}';
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao obter ClassCorridas: ${response.error}'),
        ));
      }
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
      backgroundColor: Color(0xFF171f20),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.07),
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
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: height * 0.03),
                      Text(
                        'Digite quanto quer lucrar\nem cada tipo de chamada',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
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
                          color: Colors.grey,
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
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: corridaBronzeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        validator: (val) => val!.isEmpty ? 'Campo vazio' : null,
                        decoration: kInputDecoration('Corridas bronze devem lucrar'),
                      ),
                      SizedBox(height: height * 0.04),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: corridaOuroController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        validator: (val) => val!.isEmpty ? 'Campo vazio' : null,
                        decoration: kInputDecoration('Corridas ouro devem lucrar'),
                      ),
                      SizedBox(height: height * 0.04),
                      TextFormField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        controller: corridaDiamanteController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        validator: (val) => val!.isEmpty ? 'Campo vazio' : null,
                        decoration: kInputDecoration('Corridas diamante devem lucrar'),
                      ),
                      SizedBox(height: height * 0.04),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.05),
                kTextButton(
                  'Próximo',
                  () async {
                    if (_formKey.currentState!.validate()) {
                      _submitClasscorridas();
                    }
                  },
                  EdgeInsets.symmetric(
                    vertical: height * 0.02,
                    horizontal: width * 0.30,
                  ),
                  height * 0.025,
                ),
                SizedBox(height: height * 0.02),
                kButtonAnterior(
                  'Anterior',
                  () {
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MesLucros()),
                        (route) => false,
                      );
                    }
                  },
                  EdgeInsets.symmetric(
                    vertical: height * 0.02,
                    horizontal: width * 0.30,
                  ),
                  height * 0.025,
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
